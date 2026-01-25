import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osox/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:osox/features/profile/presentation/cubit/profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  String? _pickedImagePath;

  @override
  void initState() {
    super.initState();
    final state = context.read<ProfileCubit>().state;
    if (state is ProfileLoaded) {
      _nameController = TextEditingController(text: state.fullName);
      _bioController = TextEditingController(text: state.bio);
      _locationController = TextEditingController(text: state.location);
    } else {
      _nameController = TextEditingController();
      _bioController = TextEditingController();
      _locationController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImagePath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 16.sp,
            ),
          ),
        ),
        leadingWidth: 80.w,
        title: Text(
          'Edit profile',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              context.read<ProfileCubit>().updateProfile(
                fullName: _nameController.text,
                bio: _bioController.text,
                location: _locationController.text,
                avatarPath: _pickedImagePath,
              );
              Navigator.pop(context);
            },
            child: Text(
              'Done',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 24.h),
            _buildAvatarSection(state: context.read<ProfileCubit>().state),
            SizedBox(height: 24.h),
            _buildEditField(label: 'Name', controller: _nameController),
            _buildEditField(
              label: 'Pronouns',
              controller: TextEditingController(),
            ), // Placeholder
            _buildEditField(label: 'Bio', controller: _bioController),
            _buildEditField(
              label: 'Location',
              controller: _locationController,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection({required ProfileState state}) {
    String? profileUrl;
    if (state is ProfileLoaded) profileUrl = state.profilePicUrl;

    return Column(
      children: [
        CircleAvatar(
          radius: 45.r,
          backgroundColor: Colors.grey[200],
          backgroundImage: _pickedImagePath != null
              ? FileImage(File(_pickedImagePath!))
              : (profileUrl != null && profileUrl.isNotEmpty
                    ? NetworkImage(profileUrl) as ImageProvider
                    : null),
          child:
              (_pickedImagePath == null &&
                  (profileUrl == null || profileUrl.isEmpty))
              ? Icon(Icons.person, size: 50.r, color: Colors.grey)
              : null,
        ),
        SizedBox(height: 10.h),
        TextButton(
          onPressed: _pickImage,
          child: Text(
            'Change profile photo',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditField({
    required String label,
    required TextEditingController controller,
    bool isLast = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[900]! : Colors.grey[200]!,
            width: 0.5,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: label == 'Bio' ? null : 1,
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
              ),
              style: TextStyle(
                fontSize: 15.sp,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
