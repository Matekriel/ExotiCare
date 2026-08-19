class ParcelLocker {
  final int id;
  final String code;
  final String name;
  final String city;
  final String street;
  final double latitude;
  final double longitude;

  ParcelLocker({
    required this.id,
    required this.code,
    required this.name,
    required this.city,
    required this.street,
    required this.latitude,
    required this.longitude,
  });

  factory ParcelLocker.fromJson(Map<String, dynamic> json) {
    return ParcelLocker(
      id: json["id"],
      code: json["code"],
      name: json["name"],
      city: json["city"],
      street: json["street"],
      latitude: json["latitude"].toDouble(),
      longitude: json["longitude"].toDouble(),
    );
  }
}