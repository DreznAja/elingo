import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/providers/progress_provider.dart';
import '../../../core/theme/app_theme.dart';

class DailyGoalCard extends StatelessWidget {
  const DailyGoalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressProvider>(
      builder: (context, progressProvider, _) {
        final dailyGoal = progressProvider.dailyGoal;
        
        if (dailyGoal == null) {
          return const SizedBox.shrink();
        }
        
        final currentValue = dailyGoal['current_value'] ?? 0;
        final targetValue = dailyGoal['target_value'] ?? 5;
        final progress = currentValue / targetValue;
        final isCompleted = dailyGoal['completed'] ?? false;
        
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isCompleted 
                  ? [AppTheme.successColor, AppTheme.successColor.withOpacity(0.8)]
                  : [AppTheme.primaryColor, AppTheme.secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isCompleted ? LucideIcons.checkCircle : LucideIcons.target,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isCompleted ? 'Daily Goal Complete!' : 'Daily Goal',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    '$currentValue/$targetValue',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Text(
                isCompleted 
                    ? 'Amazing! You\'ve completed your daily goal.'
                    : 'Complete ${targetValue - currentValue} more lessons today',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              
              const SizedBox(height: 16),
              
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}