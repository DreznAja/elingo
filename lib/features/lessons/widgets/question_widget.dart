import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/models/lesson.dart';

class QuestionWidget extends StatelessWidget {
  final Question question;
  final String? selectedAnswer;
  final bool showResult;
  final VoidCallback? onAnswerSelected;
  final Function(String) onOptionTap;

  const QuestionWidget({
    super.key,
    required this.question,
    this.selectedAnswer,
    required this.showResult,
    this.onAnswerSelected,
    required this.onOptionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question Type Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getQuestionTypeColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getQuestionTypeIcon(),
                size: 16,
                color: _getQuestionTypeColor(),
              ),
              const SizedBox(width: 6),
              Text(
                _getQuestionTypeText(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getQuestionTypeColor(),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Question Text
        Text(
          question.question,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            height: 1.3,
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Options
        ...question.options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isSelected = selectedAnswer == option;
          final isCorrect = option == question.correct;
          
          Color? backgroundColor;
          Color? borderColor;
          Color? textColor;
          IconData? trailingIcon;
          
          if (showResult) {
            if (isCorrect) {
              backgroundColor = AppTheme.successColor.withOpacity(0.1);
              borderColor = AppTheme.successColor;
              textColor = AppTheme.successColor;
              trailingIcon = LucideIcons.checkCircle;
            } else if (isSelected && !isCorrect) {
              backgroundColor = AppTheme.errorColor.withOpacity(0.1);
              borderColor = AppTheme.errorColor;
              textColor = AppTheme.errorColor;
              trailingIcon = LucideIcons.xCircle;
            }
          } else if (isSelected) {
            backgroundColor = AppTheme.primaryColor.withOpacity(0.1);
            borderColor = AppTheme.primaryColor;
            textColor = AppTheme.primaryColor;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: showResult ? null : () => onOptionTap(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: backgroundColor ?? AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: borderColor ?? AppTheme.borderColor,
                    width: 2,
                  ),
                  boxShadow: isSelected && !showResult
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    // Option Letter
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: textColor?.withOpacity(0.2) ?? AppTheme.borderColor.withOpacity(0.3),
                        border: Border.all(
                          color: textColor ?? AppTheme.borderColor,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + index), // A, B, C, D
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textColor ?? AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Option Text
                    Expanded(
                      child: Text(
                        option,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textColor ?? AppTheme.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                    
                    // Trailing Icon
                    if (trailingIcon != null) ...[
                      const SizedBox(width: 12),
                      Icon(
                        trailingIcon,
                        color: textColor,
                        size: 24,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Color _getQuestionTypeColor() {
    switch (question.type) {
      case 'multiple-choice':
        return AppTheme.primaryColor;
      case 'translation':
        return AppTheme.secondaryColor;
      case 'vocabulary':
        return AppTheme.accentColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getQuestionTypeIcon() {
    switch (question.type) {
      case 'multiple-choice':
        return LucideIcons.checkSquare;
      case 'translation':
        return LucideIcons.languages;
      case 'vocabulary':
        return LucideIcons.bookOpen;
      default:
        return LucideIcons.helpCircle;
    }
  }

  String _getQuestionTypeText() {
    switch (question.type) {
      case 'multiple-choice':
        return 'Multiple Choice';
      case 'translation':
        return 'Translation';
      case 'vocabulary':
        return 'Vocabulary';
      default:
        return 'Question';
    }
  }
}