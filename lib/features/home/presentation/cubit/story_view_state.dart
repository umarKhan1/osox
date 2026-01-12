import 'package:equatable/equatable.dart';

class StoryViewState extends Equatable {
  const StoryViewState({
    this.currentIndex = 0,
    this.progress = 0.0,
    this.isViewerSheetVisible = false,
  });

  final int currentIndex;
  final double progress; // 0.0 to 1.0
  final bool isViewerSheetVisible;

  @override
  List<Object?> get props => [currentIndex, progress, isViewerSheetVisible];

  StoryViewState copyWith({
    int? currentIndex,
    double? progress,
    bool? isViewerSheetVisible,
  }) {
    return StoryViewState(
      currentIndex: currentIndex ?? this.currentIndex,
      progress: progress ?? this.progress,
      isViewerSheetVisible: isViewerSheetVisible ?? this.isViewerSheetVisible,
    );
  }
}
