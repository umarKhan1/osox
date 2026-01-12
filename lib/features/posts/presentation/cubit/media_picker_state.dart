import 'package:photo_manager/photo_manager.dart';

enum MediaType { all, image, video }

abstract class MediaPickerState {}

class MediaPickerInitial extends MediaPickerState {}

class MediaPickerLoading extends MediaPickerState {}

class MediaPickerLoaded extends MediaPickerState {
  MediaPickerLoaded({
    required this.mediaAssets,
    required this.selectedAssetIds,
    this.currentMediaType = MediaType.all,
  });

  final List<AssetEntity> mediaAssets;
  final Set<String> selectedAssetIds; // Changed from indices to asset IDs
  final MediaType currentMediaType;

  Set<int> get selectedIndices {
    final indices = <int>{};
    for (var i = 0; i < mediaAssets.length; i++) {
      if (selectedAssetIds.contains(mediaAssets[i].id)) {
        indices.add(i);
      }
    }
    return indices;
  }

  List<AssetEntity> get selectedAssets => mediaAssets
      .where((asset) => selectedAssetIds.contains(asset.id))
      .toList();
}

class MediaPickerError extends MediaPickerState {
  MediaPickerError(this.message);
  final String message;
}
