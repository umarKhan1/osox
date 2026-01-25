import 'package:equatable/equatable.dart';

class LocationModel extends Equatable {
  const LocationModel({
    required this.latitude,
    required this.longitude,
    required this.name,
    this.address,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      name: json['name'] as String,
      address: json['address'] as String?,
    );
  }

  final double latitude;
  final double longitude;
  final String name; // e.g., "Central Park"
  final String? address; // Full address

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
      'address': address,
    };
  }

  @override
  List<Object?> get props => [latitude, longitude, name, address];
}
