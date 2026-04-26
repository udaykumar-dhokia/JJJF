class JobData {
  final String id;
  final String title;
  final String description;
  final String type; // "vacancy" or "seeker"
  final String role;
  final String city;
  final String state;
  final String contactName;
  final String contactPhone;
  final String? contactEmail;
  final String? link;
  final DateTime createdAt;

  JobData({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.role,
    required this.city,
    required this.state,
    required this.contactName,
    required this.contactPhone,
    this.contactEmail,
    this.link,
    required this.createdAt,
  });

  factory JobData.fromJson(Map<String, dynamic> json) {
    return JobData(
      id: (json['_id'] ?? json['id'] ?? '') as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? 'vacancy',
      role: json['role'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      contactName: json['contactName'] as String? ?? '',
      contactPhone: json['contactPhone'] as String? ?? '',
      contactEmail: json['contactEmail'] as String?,
      link: json['link'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
