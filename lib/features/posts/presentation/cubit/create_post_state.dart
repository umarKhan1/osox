import 'package:image_picker/image_picker.dart';
import 'package:osox/features/posts/domain/models/location_model.dart';

abstract class CreatePostState {}

class CreatePostInitial extends CreatePostState {}

class CreatePostEditing extends CreatePostState {
  CreatePostEditing({
    required this.selectedMedia,
    required this.caption,
    this.location,
  });

  final List<XFile> selectedMedia;
  final String caption;
  final LocationModel? location;
}

class CreatePostSubmitting extends CreatePostState {}

class CreatePostSuccess extends CreatePostState {}

class CreatePostError extends CreatePostState {
  CreatePostError(this.message);
  final String message;
}
