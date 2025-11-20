import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';

class LessonCompletionWidget extends StatelessWidget {
  final int score;
  final double accuracy;
  final int timeSpent;
  final int xpReward;
  final VoidCallback onContinue;

  const LessonCompletionWidget({
    super.key,
    required this.score,
    required this.accuracy,
    required this.timeSpent,
    required this.xpReward,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success Animation Container
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.successColor.withOpacity(0.2),
                  AppTheme.successColor.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.trophy,
              size: 60,
              color: AppTheme.successColor,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Completion Message
          Text(
            'Congratulations! 🎉',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'You have completed this lesson successfully!',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          // Stats Grid
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        icon: LucideIcons.target,
                        label: 'Accuracy',
                        value: '${(accuracy * 100).round()}%',
                        color: _getAccuracyColor(accuracy),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 60,
                      color: AppTheme.borderColor,
                    ),
                    Expanded(
                      child: _buildStatItem(
                        icon: LucideIcons.zap,
                        label: 'XP Earned',
                        value: '+$xpReward',
                        color: AppTheme.accentColor,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                Container(
                  height: 1,
                  color: AppTheme.borderColor,
                ),
                
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        icon: LucideIcons.clock,
                        label: 'Time',
                        value: _formatTime(timeSpent),
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 60,
                      color: AppTheme.borderColor,
                    ),
                    Expanded(
                      child: _buildStatItem(
                        icon: LucideIcons.star,
                        label: 'Score',
                        value: '$score',
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Motivational Message
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.1),
                  AppTheme.secondaryColor.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.lightbulb,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getMotivationalMessage(accuracy),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Continue Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Continue'),
                  const SizedBox(width: 8),
                  const Icon(
                    LucideIcons.arrowRight,
                    size: 20,
                  ),
                ],
              ),
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
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 28,
          color: color,
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

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 0.8) return AppTheme.successColor;
    if (accuracy >= 0.6) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  String _formatTime(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return '${minutes}m ${remainingSeconds}s';
    }
  }

  String _getMotivationalMessage(double accuracy) {
    if (accuracy >= 0.9) {
      return 'Excellent! You have mastered this material perfectly! 🌟';
    } else if (accuracy >= 0.8) {
      return 'Great job! Keep up your learning spirit! 💪';
    } else if (accuracy >= 0.7) {
      return 'Good! A little more to achieve perfect results! 📚';
    } else if (accuracy >= 0.6) {
      return 'It\'s okay, keep practicing and you will definitely get better! 🎯';
    } else {
      return 'Don\'t give up! Every mistake is a step towards success! 🚀';
    }
  }
}