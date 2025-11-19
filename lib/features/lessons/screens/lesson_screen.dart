import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/providers/language_provider.dart';
import '../../../core/providers/progress_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

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
            return _buildCompletionScreen(lesson);
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
                        child: ListView.separated(
                          itemCount: question.options.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final option = question.options[index];
                            final isSelected = _selectedAnswer == option;
                            final isCorrect = option == question.correct;
                            
                            Color? backgroundColor;
                            Color? borderColor;
                            Color? textColor;
                            
                            if (_showResult) {
                              if (isCorrect) {
                                backgroundColor = AppTheme.successColor.withOpacity(0.1);
                                borderColor = AppTheme.successColor;
                                textColor = AppTheme.successColor;
                              } else if (isSelected && !isCorrect) {
                                backgroundColor = AppTheme.errorColor.withOpacity(0.1);
                                borderColor = AppTheme.errorColor;
                                textColor = AppTheme.errorColor;
                              }
                            } else if (isSelected) {
                              backgroundColor = AppTheme.primaryColor.withOpacity(0.1);
                              borderColor = AppTheme.primaryColor;
                              textColor = AppTheme.primaryColor;
                            }

                            return GestureDetector(
                              onTap: _showResult ? null : () {
                                setState(() {
                                  _selectedAnswer = option;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: backgroundColor ?? AppTheme.surfaceColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: borderColor ?? AppTheme.borderColor,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: textColor?.withOpacity(0.2),
                                        border: Border.all(
                                          color: textColor ?? AppTheme.borderColor,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          String.fromCharCode(65 + index), // A, B, C, D
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: textColor ?? AppTheme.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        option,
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: textColor ?? AppTheme.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (_showResult && isCorrect)
                                      const Icon(
                                        LucideIcons.checkCircle,
                                        color: AppTheme.successColor,
                                        size: 24,
                                      ),
                                    if (_showResult && isSelected && !isCorrect)
                                      const Icon(
                                        LucideIcons.xCircle,
                                        color: AppTheme.errorColor,
                                        size: 24,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
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

  Widget _buildCompletionScreen(lesson) {
    final accuracy = _correctAnswers / lesson.content.length;
    final timeSpent = DateTime.now().difference(_startTime!).inSeconds;
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.trophy,
              size: 60,
              color: AppTheme.successColor,
            ),
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'Lesson Complete!',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Great job! You\'ve completed this lesson.',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                icon: LucideIcons.target,
                label: 'Accuracy',
                value: '${(accuracy * 100).round()}%',
              ),
              _buildStatItem(
                icon: LucideIcons.zap,
                label: 'XP Earned',
                value: '${lesson.xpReward}',
              ),
              _buildStatItem(
                icon: LucideIcons.clock,
                label: 'Time',
                value: '${timeSpent}s',
              ),
            ],
          ),
          
          const SizedBox(height: 48),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _completeLesson(lesson, accuracy, timeSpent),
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
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