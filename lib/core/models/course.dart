class Course {
  final String id;
  final String languageId;
  final String title;
  final String? description;
  final int difficultyLevel;
  final int totalLessons;
  final int orderIndex;
  final DateTime createdAt;

  Course({
    required this.id,
    required this.languageId,
    required this.title,
    this.description,
    required this.difficultyLevel,
    required this.totalLessons,
    required this.orderIndex,
    required this.createdAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      languageId: json['language_id'],
      title: json['title'],
      description: json['description'],
      difficultyLevel: json['difficulty_level'] ?? 1,
      totalLessons: json['total_lessons'] ?? 0,
      orderIndex: json['order_index'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'language_id': languageId,
      'title': title,
      'description': description,
      'difficulty_level': difficultyLevel,
      'total_lessons': totalLessons,
      'order_index': orderIndex,
      'created_at': createdAt.toIso8601String(),
    };
  }
}