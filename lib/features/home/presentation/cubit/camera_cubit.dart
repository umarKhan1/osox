import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osox/features/home/presentation/cubit/camera_state.dart';

class CameraCubit extends Cubit<CameraState> {
  CameraCubit() : super(CameraInitial());

  CameraController? _controller;

  Future<void> initialize() async {
    emit(CameraLoading());
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        emit(CameraError('No cameras found'));
        return;
      }

      _controller = CameraController(cameras[0], ResolutionPreset.high);

      await _controller!.initialize();
      emit(CameraReady(controller: _controller!));
    } catch (e) {
      emit(CameraError(e.toString()));
    }
  }

  Future<void> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final image = await _controller!.takePicture();
      emit(CameraCaptured(path: image.path, isVideo: false));
    } catch (e) {
      emit(CameraError(e.toString()));
    }
  }

  Future<void> startVideoRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      await _controller!.startVideoRecording();
      emit(CameraCapturing(controller: _controller!, isRecording: true));
    } catch (e) {
      emit(CameraError(e.toString()));
    }
  }

  Future<void> stopVideoRecording() async {
    if (_controller == null || !_controller!.value.isRecordingVideo) return;

    try {
      final video = await _controller!.stopVideoRecording();
      emit(CameraCaptured(path: video.path, isVideo: true));
    } catch (e) {
      emit(CameraError(e.toString()));
    }
  }

  void reset() {
    if (_controller != null && _controller!.value.isInitialized) {
      emit(CameraReady(controller: _controller!));
    } else {
      initialize();
    }
  }

  @override
  Future<void> close() {
    _controller?.dispose();
    return super.close();
  }
}
