import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:osox/features/posts/domain/models/location_model.dart';
import 'package:osox/features/posts/presentation/cubit/location_picker_state.dart';

class LocationPickerCubit extends Cubit<LocationPickerState> {
  LocationPickerCubit() : super(LocationPickerInitial());

  Future<void> getCurrentLocation() async {
    emit(LocationPickerLoading());
    try {
      // Check permission
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied ||
            requested == LocationPermission.deniedForever) {
          emit(LocationPickerError('Location permission denied'));
          return;
        }
      }

      // Get current position with timeout
      final position =
          await Geolocator.getCurrentPosition(
            // ignore: deprecated_member_use
            desiredAccuracy: LocationAccuracy.high,
            // ignore: deprecated_member_use
            timeLimit: const Duration(seconds: 10),
          ).timeout(
            const Duration(seconds: 15),
            onTimeout: () async {
              // Fallback to last known position
              final lastPosition = await Geolocator.getLastKnownPosition();
              if (lastPosition != null) {
                return lastPosition;
              }
              // Default to a location if all else fails
              throw Exception('Unable to get location. Please try again.');
            },
          );

      emit(
        LocationPickerReady(
          currentLatitude: position.latitude,
          currentLongitude: position.longitude,
        ),
      );
    } catch (e) {
      emit(LocationPickerError(e.toString()));
    }
  }

  Future<void> selectLocation(double latitude, double longitude) async {
    try {
      // Get address from coordinates
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final name =
            placemark.name ?? placemark.locality ?? 'Selected Location';
        final address =
            '${placemark.street}, ${placemark.locality}, ${placemark.country}';

        final location = LocationModel(
          latitude: latitude,
          longitude: longitude,
          name: name,
          address: address,
        );

        final currentState = state;
        if (currentState is LocationPickerReady) {
          emit(
            LocationPickerReady(
              currentLatitude: currentState.currentLatitude,
              currentLongitude: currentState.currentLongitude,
              selectedLocation: location,
            ),
          );
        }
      }
    } catch (e) {
      emit(LocationPickerError(e.toString()));
    }
  }

  Future<List<LocationModel>> searchLocation(String query) async {
    try {
      final locations = await locationFromAddress(query);
      final results = <LocationModel>[];

      for (final location in locations) {
        final placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          results.add(
            LocationModel(
              latitude: location.latitude,
              longitude: location.longitude,
              name: placemark.name ?? query,
              address:
                  // ignore: lines_longer_than_80_chars
                  '${placemark.street}, ${placemark.locality}, ${placemark.country}',
            ),
          );
        }
      }

      return results;
    } catch (e) {
      return [];
    }
  }
}
