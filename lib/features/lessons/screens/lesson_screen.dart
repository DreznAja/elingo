import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/providers/language_provider.dart';
import '../../../core/providers/progress_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/question_widget.dart';
import '../widgets/lesson_completion_widget.dart';

class LessonScreen extends StatefulWidget {
  final String lessonId;

  const LessonScreen({
    super.key,
    required this.lessonId,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  bool _showResult = false;
  bool _isCorrect = false;
  int _score = 0;
  int _correctAnswers = 0;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => _showExitDialog(),
        ),
        title: Consumer<LanguageProvider>(
          builder: (context, languageProvider, _) {
            final lesson = languageProvider.lessons
                .where((l) => l.id == widget.lessonId)
                .firstOrNull;
            return Text(lesson?.title ?? 'Lesson');
          },
        ),
        actions: [
          Consumer<LanguageProvider>(
            builder: (context, languageProvider, _) {
              final lesson = languageProvider.lessons
                  .where((l) => l.id == widget.lessonId)
                  .firstOrNull;
              
              if (lesson == null) return const SizedBox.shrink();
              
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    '${_currentQuestionIndex + 1}/${lesson.content.length}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<LanguageProvider>(
        builder: (context, languageProvider, _) {
          final lesson = languageProvider.lessons
              .where((l) => l.id == widget.lessonId)
              .firstOrNull;

          if (lesson == null) {
            return const Center(
              child: Text('Lesson not found'),
            );
          }

          if (_currentQuestionIndex >= lesson.content.length) {
            final accuracy = _correctAnswers / lesson.content.length;
            final timeSpent = DateTime.now().difference(_startTime!).inSeconds;
            
            return LessonCompletionWidget(
              score: _score,
              accuracy: accuracy,
              timeSpent: timeSpent,
              xpReward: lesson.xpReward,
              onContinue: () => _completeLesson(lesson, accuracy, timeSpent),
            );
          }

          final question = lesson.content[_currentQuestionIndex];
          final progress = (_currentQuestionIndex + 1) / lesson.content.length;

          return Column(
            children: [
              // Progress Bar
              Container(
                padding: const EdgeInsets.all(24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppTheme.borderColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    minHeight: 8,
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question
                      Text(
                        question.question,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Options
                      Expanded(
                        child: SingleChildScrollView(
                          child: QuestionWidget(
                            question: question,
                            selectedAnswer: _selectedAnswer,
                            showResult: _showResult,
                            onOptionTap: (option) {
                              setState(() {
                                _selectedAnswer = option;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectedAnswer == null ? null : () {
                            if (_showResult) {
                              _nextQuestion();
                            } else {
                              _checkAnswer(question.correct);
                            }
                          },
                          child: Text(
                            _showResult ? 'Continue' : 'Check Answer',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _checkAnswer(String correctAnswer) {
    final isCorrect = _selectedAnswer == correctAnswer;
    
    setState(() {
      _showResult = true;
      _isCorrect = isCorrect;
      if (isCorrect) {
        _correctAnswers++;
        _score += 10;
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestionIndex++;
      _selectedAnswer = null;
      _showResult = false;
      _isCorrect = false;
    });
  }

  void _completeLesson(lesson, double accuracy, int timeSpent) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      await progressProvider.completeLesson(
        userId: authProvider.user!.id,
        lessonId: lesson.id,
        courseId: lesson.courseId,
        score: _score,
        accuracy: accuracy,
        timeSpent: timeSpent,
        xpReward: lesson.xpReward,
        context: context,
      );
    }
    
    if (mounted) {
      context.go('/home');
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Exit Lesson?',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Your progress will be lost if you exit now.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/home');
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}