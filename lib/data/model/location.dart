class Location {
  String name;
  String status;
  List<Ward> wards;

  Location({
    required this.name,
    required this.status,
    required this.wards,
  });

  // Hàm factory để ánh xạ từ JSON
  factory Location.fromJson(Map<String, dynamic> map) {
    return Location(
      name: map['name'] ?? '',
      status: map['status'] ?? '',
      wards: (map['wards'] as List<dynamic>)
          .map((wardJson) => Ward.fromJson(wardJson))
          .toList(),
    );
  }

  @override
  String toString() {
    return 'Location{name: $name, status: $status, wards: $wards}';
  }
}

class District {
  String name;
  String id;
  List<Ward> wards;

  District({
    required this.name,
    required this.id,
    required this.wards,
  });

  // Hàm factory để ánh xạ từ JSON
  factory District.fromJson(Map<String, dynamic> map) {
    return District(
      name: map['Name'] ?? '',
      id: map['_id'] ?? '',
      wards: (map['Wards'] as List<dynamic>)
          .map((wardJson) => Ward.fromJson(wardJson))
          .toList(),
    );
  }

  @override
  String toString() {
    return 'District{name: $name, id: $id, wards: $wards}';
  }
}

class Ward {
  String name;

  Ward({
    required this.name,
  });

  // Hàm factory để ánh xạ từ JSON
  factory Ward.fromJson(Map<String, dynamic> map) {
    return Ward(
      name: map['name'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Ward{name: $name}';
  }
}
