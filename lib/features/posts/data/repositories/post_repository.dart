import 'package:osox/features/posts/domain/models/location_model.dart';
import 'package:osox/features/posts/domain/models/post_model.dart';

class PostRepository {
  final List<PostModel> _userPosts = [];

  // Mock data for demonstration
  final List<PostModel> _mockPosts = [
    PostModel(
      id: 'mock_1',
      userId: 'user_joshua',
      userName: 'joshua_l',
      userProfileUrl: 'https://i.pravatar.cc/150?u=joshua',
      mediaPaths: const [
        'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&w=800&q=80',
      ],
      caption: 'The game in Japan was amazing and I want to share some photos',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      location: const LocationModel(
        latitude: 35.6762,
        longitude: 139.6503,
        name: 'Tokyo, Japan',
      ),
      likes: 44687,
    ),
    PostModel(
      id: 'mock_2',
      userId: 'user_traveler',
      userName: 'global_explorer',
      userProfileUrl: 'https://i.pravatar.cc/150?u=traveler',
      mediaPaths: const [
        'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80',
      ],
      caption: 'Exploring the heights of the Swiss Alps 🏔️',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      location: const LocationModel(
        latitude: 46.8182,
        longitude: 8.2275,
        name: 'Swiss Alps, Switzerland',
      ),
      likes: 1243,
      isLiked: true,
    ),
    PostModel(
      id: 'mock_3',
      userId: 'user_foodie',
      userName: 'urban_eats',
      userProfileUrl: 'https://i.pravatar.cc/150?u=foodie',
      mediaPaths: const [
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80',
      ],
      caption: 'Best pizza in town found at this hidden gem! 🍕✨',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      likes: 856,
    ),
  ];

  Future<void> createPost(PostModel post) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _userPosts.insert(0, post); // Add to beginning (newest first)
  }

  Future<List<PostModel>> getFeedPosts() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    // Combine user posts with mock posts
    return List.unmodifiable([..._userPosts, ..._mockPosts]);
  }
}
