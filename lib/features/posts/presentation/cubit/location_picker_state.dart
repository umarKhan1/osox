import 'package:osox/features/posts/domain/models/location_model.dart';

abstract class LocationPickerState {}

class LocationPickerInitial extends LocationPickerState {}

class LocationPickerLoading extends LocationPickerState {}

class LocationPickerReady extends LocationPickerState {
  LocationPickerReady({
    required this.currentLatitude,
    required this.currentLongitude,
    this.selectedLocation,
  });

  final double currentLatitude;
  final double currentLongitude;
  final LocationModel? selectedLocation;
}

class LocationPickerError extends LocationPickerState {
  LocationPickerError(this.message);
  final String message;
}
