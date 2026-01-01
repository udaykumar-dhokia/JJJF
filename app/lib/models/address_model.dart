class Address {
  final String lineOne;
  final String lineTwo;
  final String city;
  final String state;
  final int zipCode;

  Address({
    required this.lineOne,
    required this.lineTwo,
    required this.city,
    required this.state,
    required this.zipCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      lineOne: json['lineOne'] ?? '',
      lineTwo: json['lineTwo'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zipCode: json['zipCode'] ?? '',
    );
  }
}
