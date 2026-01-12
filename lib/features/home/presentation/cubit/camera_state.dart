import 'package:camera/camera.dart';

abstract class CameraState {}

class CameraInitial extends CameraState {}

class CameraLoading extends CameraState {}

class CameraReady extends CameraState {
  CameraReady({required this.controller});
  final CameraController controller;
}

class CameraError extends CameraState {
  CameraError(this.message);
  final String message;
}

class CameraCapturing extends CameraState {
  CameraCapturing({required this.controller, this.isRecording = false});
  final CameraController controller;
  final bool isRecording;
}

class CameraCaptured extends CameraState {
  CameraCaptured({required this.path, required this.isVideo});
  final String path;
  final bool isVideo;
}
