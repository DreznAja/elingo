class UserProfile {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final int level;
  final int totalXp;
  final int currentStreak;
  final int longestStreak;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    required this.level,
    required this.totalXp,
    required this.currentStreak,
    required this.longestStreak,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      level: json['level'] ?? 1,
      totalXp: json['total_xp'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'level': level,
      'total_xp': totalXp,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? fullName,
    String? avatarUrl,
    int? level,
    int? totalXp,
    int? currentStreak,
    int? longestStreak,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      totalXp: totalXp ?? this.totalXp,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}