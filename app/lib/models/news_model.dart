class News {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String authorName;
  final String? image;
  final String createdAt;

  News({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.authorName,
    this.image,
    required this.createdAt,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['_id'],
      userId: json['userId'],
      title: json['title'],
      content: json['content'],
      authorName: json['authorName'] ?? 'Unknown',
      image: json['image'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'image': image,
      'createdAt': createdAt,
    };
  }
}
