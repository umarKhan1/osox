import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osox/features/posts/presentation/cubit/media_picker_state.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaPickerCubit extends Cubit<MediaPickerState> {
  MediaPickerCubit() : super(MediaPickerInitial());

  Future<void> loadMedia({MediaType type = MediaType.all}) async {
    final currentState = state;
    // Preserve selected asset IDs
    final selectedIds = currentState is MediaPickerLoaded
        ? currentState.selectedAssetIds
        : <String>{};

    emit(MediaPickerLoading());
    try {
      // Request permission
      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.isAuth) {
        emit(MediaPickerError('Permission denied'));
        return;
      }

      // Get albums
      final albums = await PhotoManager.getAssetPathList(
        type: type == MediaType.image
            ? RequestType.image
            : type == MediaType.video
            ? RequestType.video
            : RequestType.common,
      );

      if (albums.isEmpty) {
        emit(MediaPickerError('No media found'));
        return;
      }

      // Get assets from first album (recent)
      final recentAlbum = albums.first;
      final assets = await recentAlbum.getAssetListRange(
        start: 0,
        end: 100, // Load first 100 items
      );

      emit(
        MediaPickerLoaded(
          mediaAssets: assets,
          selectedAssetIds: selectedIds, // Preserve selection
          currentMediaType: type,
        ),
      );
    } catch (e) {
      emit(MediaPickerError(e.toString()));
    }
  }

  void toggleSelection(int index) {
    final currentState = state;
    if (currentState is MediaPickerLoaded) {
      final asset = currentState.mediaAssets[index];
      final newSelected = Set<String>.from(currentState.selectedAssetIds);

      if (newSelected.contains(asset.id)) {
        newSelected.remove(asset.id);
      } else {
        newSelected.add(asset.id);
      }

      emit(
        MediaPickerLoaded(
          mediaAssets: currentState.mediaAssets,
          selectedAssetIds: newSelected,
          currentMediaType: currentState.currentMediaType,
        ),
      );
    }
  }

  void changeMediaType(MediaType type) {
    loadMedia(type: type);
  }

  void clearSelection() {
    final currentState = state;
    if (currentState is MediaPickerLoaded) {
      emit(
        MediaPickerLoaded(
          mediaAssets: currentState.mediaAssets,
          selectedAssetIds: {},
          currentMediaType: currentState.currentMediaType,
        ),
      );
    }
  }
}
