class Customer {
  List<Points> points;
  String phone;
  String name;
  String email;
  String password;
  List<Addresses> addresses;

  Customer({
    required this.addresses,
    required this.points,
    required this.phone,
    required this.name,
    required this.password,
    required this.email,
  });

  factory Customer.fromJson(Map<String, dynamic> map) {
    return Customer(
      addresses: (map['addresses'] as List<dynamic>?)
          ?.map((e) => Addresses.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      points: (map['points'] as List<dynamic>?)
          ?.map((e) => Points.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      phone: map['phone'] ?? '',
      name: map['fullName'] ?? '',
      password: map['password'] ?? '',
      email: map['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addresses': addresses.map((address) => address.toJson()).toList(),
      'points': points.map((point) => point.toJson()).toList(),
      'phone': phone,
      'fullName': name,
      'password': password,
      'email': email,
    };
  }

  @override
  String toString() {
    return 'Customer{name: $name, phone: $phone, email: $email, password: $password, points: $points, addresses: $addresses}';
  }
}

class Points {
  String id;
  int point;

  Points({required this.point, required this.id});

  factory Points.fromJson(Map<String, dynamic> map) {
    return Points(point: map['point'], id: map['_id']);
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'point': point,
    };
  }

  @override
  String toString() {
    return 'Points{id: $id, point: $point}';
  }
}

class Addresses {
  String province;
  String ward;
  String detailedAddress;

  Addresses({
    required this.province,
    required this.ward,
    required this.detailedAddress,
  });

  factory Addresses.fromJson(Map<String, dynamic> map) {
    return Addresses(
      province: map['province'] is String
          ? map['province'] ?? ''
          : (map['province'] is Map ? map['province']['name'] ?? '' : ''),
      ward: map['ward'] is String
          ? map['ward'] ?? ''
          : (map['ward'] is Map ? map['ward']['name'] ?? '' : ''),
      detailedAddress: map['detailAddress'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'province': province,
      'ward': ward,
      'detailAddress': detailedAddress,
    };
  }

  @override
  String toString() {
    return '$detailedAddress, $ward, $province';
  }
}
