// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class MapLocation {
  final double longitude;
  final double latitude;
  final String? name;
  final String? displayName; // Full address 
  final String? type; 
  
  MapLocation({
    required this.longitude,
    required this.latitude,
    this.name,
    this.displayName,
    this.type,
  });

  MapLocation copyWith({
    double? longitude,
    double? latitude,
    String? name,
    String? displayName,
    String? type,
  }) {
    return MapLocation(
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'longitude': longitude,
      'latitude': latitude,
      'name': name,
      'display_name': displayName,
      'type': type,
    };
  }

  // For parsing Nominatim API response
  factory MapLocation.fromNominatimMap(Map<String, dynamic> map) {
    return MapLocation(
      longitude: double.parse(map['lon'].toString()),
      latitude: double.parse(map['lat'].toString()),
      name: map['name'] as String?,
      displayName: map['display_name'] as String?,
      type: map['type'] as String?,
    );
  }

  factory MapLocation.fromMap(Map<String, dynamic> map) {
    return MapLocation(
      longitude: map['longitude'] as double,
      latitude: map['latitude'] as double,
      name: map['name'] as String?,
      displayName: map['display_name'] as String?,
      type: map['type'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory MapLocation.fromJson(String source) =>
      MapLocation.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'MapLocation(longitude: $longitude, latitude: $latitude, name: $name, displayName: $displayName)';

  @override
  bool operator ==(covariant MapLocation other) {
    if (identical(this, other)) return true;

    return other.longitude == longitude &&
        other.latitude == latitude &&
        other.name == name &&
        other.displayName == displayName &&
        other.type == type;
  }

  @override
  int get hashCode =>
      longitude.hashCode ^
      latitude.hashCode ^
      name.hashCode ^
      displayName.hashCode ^
      type.hashCode;
}