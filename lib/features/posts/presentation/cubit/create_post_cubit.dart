import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osox/features/posts/domain/models/location_model.dart';
import 'package:osox/features/posts/domain/models/post_model.dart';
import 'package:osox/features/posts/domain/repositories/post_repository.dart';
import 'package:osox/features/posts/presentation/cubit/create_post_state.dart';

class CreatePostCubit extends Cubit<CreatePostState> {
  CreatePostCubit(this._repository, List<XFile> selectedMedia)
    : super(CreatePostEditing(selectedMedia: selectedMedia, caption: ''));

  final IPostRepository _repository;

  void updateCaption(String caption) {
    final currentState = state;
    if (currentState is CreatePostEditing) {
      emit(
        CreatePostEditing(
          selectedMedia: currentState.selectedMedia,
          caption: caption,
          location: currentState.location,
        ),
      );
    }
  }

  void setLocation(LocationModel location) {
    final currentState = state;
    if (currentState is CreatePostEditing) {
      emit(
        CreatePostEditing(
          selectedMedia: currentState.selectedMedia,
          caption: currentState.caption,
          location: location,
        ),
      );
    }
  }

  Future<void> submitPost({
    required String userId,
    required String userName,
    required String userProfileUrl,
  }) async {
    final currentState = state;
    if (currentState is! CreatePostEditing) return;

    emit(CreatePostSubmitting());

    try {
      final post = PostModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        userName: userName,
        userProfileUrl: userProfileUrl,
        mediaPaths: currentState.selectedMedia.map((e) => e.path).toList(),
        caption: currentState.caption,
        location: currentState.location,
        createdAt: DateTime.now(),
      );

      await _repository.createPost(post, post.mediaPaths);
      if (!isClosed) emit(CreatePostSuccess());
    } catch (e) {
      if (!isClosed) emit(CreatePostError(e.toString()));
    }
  }
}
