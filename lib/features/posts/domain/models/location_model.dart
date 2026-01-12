import 'package:equatable/equatable.dart';

class LocationModel extends Equatable {
  const LocationModel({
    required this.latitude,
    required this.longitude,
    required this.name,
    this.address,
  });

  final double latitude;
  final double longitude;
  final String name; // e.g., "Central Park"
  final String? address; // Full address

  @override
  List<Object?> get props => [latitude, longitude, name, address];
}
