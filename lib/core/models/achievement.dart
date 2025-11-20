class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String requirementType;
  final int requirementValue;
  final int xpReward;
  final DateTime createdAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.requirementType,
    required this.requirementValue,
    required this.xpReward,
    required this.createdAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      requirementType: json['requirement_type'],
      requirementValue: json['requirement_value'],
      xpReward: json['xp_reward'] ?? 50,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'requirement_type': requirementType,
      'requirement_value': requirementValue,
      'xp_reward': xpReward,
      'created_at': createdAt.toIso8601String(),
    };
  }
}