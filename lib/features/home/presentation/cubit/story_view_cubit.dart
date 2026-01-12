import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osox/features/home/presentation/cubit/story_view_state.dart';

class StoryViewCubit extends Cubit<StoryViewState> {
  StoryViewCubit() : super(const StoryViewState());

  void updateProgress(double progress) {
    emit(state.copyWith(progress: progress));
  }

  void nextStory(int totalStories) {
    if (state.currentIndex < totalStories - 1) {
      emit(state.copyWith(currentIndex: state.currentIndex + 1, progress: 0));
    }
  }

  void previousStory() {
    if (state.currentIndex > 0) {
      emit(state.copyWith(currentIndex: state.currentIndex - 1, progress: 0));
    }
  }

  void setViewerSheetVisible({required bool visible}) {
    emit(state.copyWith(isViewerSheetVisible: visible));
  }
}
