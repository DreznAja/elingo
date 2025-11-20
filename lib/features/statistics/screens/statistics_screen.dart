import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/progress_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/stats_period_selector.dart';
import '../widgets/stats_chart_widget.dart';
import '../widgets/stats_summary_card.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedPeriod = 'Weekly';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.infoColor.withOpacity(0.05),
              Colors.white,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modern Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.infoColor, AppTheme.primaryColor],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        LucideIcons.barChart3,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Statistics',
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Track your learning progress',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Period Selector
              StatsPeriodSelector(
                selectedPeriod: _selectedPeriod,
                onPeriodChanged: (period) {
                  setState(() {
                    _selectedPeriod = period;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Summary Cards
              Consumer2<AuthProvider, ProgressProvider>(
                builder: (context, authProvider, progressProvider, _) {
                  final profile = authProvider.profile;
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: StatsSummaryCard(
                              title: 'Lessons Completed',
                              value: _getLessonsCompletedForPeriod(_selectedPeriod),
                              icon: LucideIcons.bookOpen,
                              color: AppTheme.primaryColor,
                              trend: '+12%',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatsSummaryCard(
                              title: 'XP Earned',
                              value: _getXpEarnedForPeriod(_selectedPeriod),
                              icon: LucideIcons.zap,
                              color: AppTheme.accentColor,
                              trend: '+8%',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: StatsSummaryCard(
                              title: 'Study Time',
                              value: _getStudyTimeForPeriod(_selectedPeriod),
                              icon: LucideIcons.clock,
                              color: AppTheme.infoColor,
                              trend: '+15%',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatsSummaryCard(
                              title: 'Accuracy',
                              value: _getAccuracyForPeriod(_selectedPeriod),
                              icon: LucideIcons.target,
                              color: AppTheme.successColor,
                              trend: '+3%',
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // Chart Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.trendingUp,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Learning Progress',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    StatsChartWidget(period: _selectedPeriod),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Achievement Progress
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.trophy,
                          color: AppTheme.warningColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Recent Achievements',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildAchievementItem(
                      '🎯',
                      'First Lesson',
                      'Completed your first lesson',
                      '2 days ago',
                    ),
                    const SizedBox(height: 12),
                    _buildAchievementItem(
                      '🔥',
                      'Week Streak',
                      '7 days in a row',
                      '1 week ago',
                    ),
                    const SizedBox(height: 12),
                    _buildAchievementItem(
                      '⚡',
                      'Quick Learner',
                      'Perfect score on 5 lessons',
                      '2 weeks ago',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementItem(String emoji, String title, String description, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _getLessonsCompletedForPeriod(String period) {
    // Mock data - replace with actual data from provider
    switch (period) {
      case 'Daily':
        return '3';
      case 'Weekly':
        return '18';
      case 'Monthly':
        return '72';
      default:
        return '0';
    }
  }

  String _getXpEarnedForPeriod(String period) {
    // Mock data - replace with actual data from provider
    switch (period) {
      case 'Daily':
        return '45';
      case 'Weekly':
        return '270';
      case 'Monthly':
        return '1080';
      default:
        return '0';
    }
  }

  String _getStudyTimeForPeriod(String period) {
    // Mock data - replace with actual data from provider
    switch (period) {
      case 'Daily':
        return '15m';
      case 'Weekly':
        return '1h 45m';
      case 'Monthly':
        return '7h 20m';
      default:
        return '0m';
    }
  }

  String _getAccuracyForPeriod(String period) {
    // Mock data - replace with actual data from provider
    switch (period) {
      case 'Daily':
        return '92%';
      case 'Weekly':
        return '88%';
      case 'Monthly':
        return '85%';
      default:
        return '0%';
    }
  }
}