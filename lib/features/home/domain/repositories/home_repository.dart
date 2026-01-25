import 'package:osox/features/home/domain/models/story_model.dart';

abstract class IHomeRepository {
  Future<List<UserStoriesModel>> getStories();
  Future<void> addStory({
    required String filePath,
    required StoryType type,
    bool isLive = false,
  });
  Future<void> deleteStory(String storyId);
  Future<void> viewStory(String storyId);
  Future<List<UserModel>> getStoryViewers(String storyId);
}
