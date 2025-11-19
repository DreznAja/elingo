class Language {
  final String id;
  final String name;
  final String code;
  final String flagEmoji;
  final int difficultyLevel;
  final int totalLessons;
  final DateTime createdAt;

  Language({
    required this.id,
    required this.name,
    required this.code,
    required this.flagEmoji,
    required this.difficultyLevel,
    required this.totalLessons,
    required this.createdAt,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      flagEmoji: json['flag_emoji'],
      difficultyLevel: json['difficulty_level'] ?? 1,
      totalLessons: json['total_lessons'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'flag_emoji': flagEmoji,
      'difficulty_level': difficultyLevel,
      'total_lessons': totalLessons,
      'created_at': createdAt.toIso8601String(),
    };
  }
}