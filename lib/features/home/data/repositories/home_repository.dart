import 'package:osox/features/home/domain/models/story_model.dart';

class HomeRepository {
  final List<UserStoriesModel> _mockStories = [
    const UserStoriesModel(
      user: UserModel(
        id: 'u1',
        name: 'Your Story',
        profileUrl:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
      ),
      stories: [
        StoryModel(
          id: 's1_1',
          contentUrl:
              'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800',
          type: StoryType.image,
          viewers: [
            UserModel(
              id: 'v1',
              name: 'Alvaro',
              profileUrl:
                  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
            ),
            UserModel(
              id: 'v2',
              name: 'Sofia',
              profileUrl:
                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
            ),
            UserModel(
              id: 'v3',
              name: 'Marco',
              profileUrl:
                  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
            ),
          ],
        ),
      ],
    ),
    const UserStoriesModel(
      user: UserModel(
        id: 'u2',
        name: 'karennne',
        profileUrl:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200',
      ),
      stories: [
        StoryModel(
          id: 's2_1',
          contentUrl:
              'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800',
          type: StoryType.image,
          isLive: true,
        ),
      ],
    ),
  ];

  Future<List<UserStoriesModel>> getStories() async {
    // Simulate API delay
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return List.from(_mockStories);
  }

  Future<void> addStory(StoryModel story) async {
    final myStoriesIndex = _mockStories.indexWhere(
      (u) => u.user.name == 'Your Story',
    );
    if (myStoriesIndex != -1) {
      final current = _mockStories[myStoriesIndex];
      _mockStories[myStoriesIndex] = UserStoriesModel(
        user: current.user,
        stories: [story, ...current.stories],
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }
}
