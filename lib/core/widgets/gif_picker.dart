import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class GifPickerSheet extends StatefulWidget {
  const GifPickerSheet({super.key});

  @override
  State<GifPickerSheet> createState() => _GifPickerSheetState();
}

class _GifPickerSheetState extends State<GifPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _gifs = [];
  bool _isLoading = false;

  // IMPORTANT: User should provide their own Giphy API Key
  // This is a placeholder public beta key
  static const String _giphyApiKey = 'dc6zaTOxFJmzC';

  @override
  void initState() {
    super.initState();
    _fetchTrending();
  }

  Future<void> _fetchTrending() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.giphy.com/v1/gifs/trending?api_key=$_giphyApiKey&limit=20&rating=g',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        setState(() => _gifs = data['data'] as List<dynamic>);
      }
    } catch (e) {
      debugPrint('Error fetching GIFs: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchGifs(String query) async {
    if (query.isEmpty) {
      _fetchTrending();
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.giphy.com/v1/gifs/search?api_key=$_giphyApiKey&q=$query&limit=20&rating=g',
        ),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        setState(() => _gifs = data['data'] as List<dynamic>);
      }
    } catch (e) {
      debugPrint('Error searching GIFs: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 0.85.sh,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            height: 4.h,
            width: 40.w,
            margin: EdgeInsets.symmetric(vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Search Bar
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[100],
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _searchGifs,
                decoration: InputDecoration(
                  icon: const Icon(Icons.search, color: Colors.grey),
                  hintText: 'Search GIPHY',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
                ),
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          ),

          // GIF Grid
          Expanded(
            child: _isLoading && _gifs.isEmpty
                ? _buildShimmerGrid()
                : GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.2,
                        ),
                    itemCount: _gifs.length,
                    itemBuilder: (context, index) {
                      final gif = _gifs[index] as Map<String, dynamic>;
                      final images = gif['images'] as Map<String, dynamic>;
                      final fixedHeight =
                          images['fixed_height'] as Map<String, dynamic>;
                      final url = fixedHeight['url'] as String;
                      return GestureDetector(
                        onTap: () => Navigator.pop(context, url),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(color: Colors.grey[300]);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Bottom Tabs (Visual only to match screenshot)
          Padding(
            padding: EdgeInsets.only(bottom: 24.h, top: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.face,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : Colors.black,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'GIF',
                    style: TextStyle(
                      color: isDark ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.2,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      },
    );
  }
}
