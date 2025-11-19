class Lesson {
  final String id;
  final String courseId;
  final String title;
  final String? description;
  final String lessonType;
  final List<Question> content;
  final int orderIndex;
  final int xpReward;
  final DateTime createdAt;

  Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    required this.lessonType,
    required this.content,
    required this.orderIndex,
    required this.xpReward,
    required this.createdAt,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final contentList = json['content'] as List<dynamic>;
    final questions = contentList.map((q) => Question.fromJson(q)).toList();

    return Lesson(
      id: json['id'],
      courseId: json['course_id'],
      title: json['title'],
      description: json['description'],
      lessonType: json['lesson_type'] ?? 'multiple-choice',
      content: questions,
      orderIndex: json['order_index'] ?? 0,
      xpReward: json['xp_reward'] ?? 10,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'description': description,
      'lesson_type': lessonType,
      'content': content.map((q) => q.toJson()).toList(),
      'order_index': orderIndex,
      'xp_reward': xpReward,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Question {
  final String type;
  final String question;
  final List<String> options;
  final String correct;

  Question({
    required this.type,
    required this.question,
    required this.options,
    required this.correct,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      type: json['type'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correct: json['correct'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'question': question,
      'options': options,
      'correct': correct,
    };
  }
}