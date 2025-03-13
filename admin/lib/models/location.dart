
class SlotLocation {
  double latitude;
  double longitude;

  SlotLocation({
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      "latitude": latitude,
      "longitude": longitude,
    };
  }

  factory SlotLocation.fromJson(Map<String, dynamic> json) {
    return SlotLocation(
      latitude: json["latitude"] ?? 0.0,
      longitude: json["longitude"] ?? 0.0,
    );
  }
}