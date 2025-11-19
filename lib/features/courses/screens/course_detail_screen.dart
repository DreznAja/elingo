import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/providers/language_provider.dart';
import '../../../core/providers/progress_provider.dart';
import '../../../core/theme/app_theme.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailScreen({
    super.key,
    required this.courseId,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LanguageProvider>(context, listen: false)
          .loadLessons(widget.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.moreVertical),
            onPressed: () {
              // TODO: Show course options
            },
          ),
        ],
      ),
      body: Consumer2<LanguageProvider, ProgressProvider>(
        builder: (context, languageProvider, progressProvider, _) {
          final course = languageProvider.courses
              .where((c) => c.id == widget.courseId)
              .firstOrNull;

          if (course == null) {
            return const Center(
              child: Text('Course not found'),
            );
          }

          if (languageProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final lessons = languageProvider.lessons;
          final progress = progressProvider.getCourseProgress(course.id);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (course.description != null)
                        Text(
                          course.description!,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatChip(
                            icon: LucideIcons.bookOpen,
                            label: '${course.totalLessons} lessons',
                          ),
                          const SizedBox(width: 12),
                          _buildStatChip(
                            icon: LucideIcons.clock,
                            label: '${course.totalLessons * 5} min',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Progress Section
                Row(
                  children: [
                    Text(
                      'Progress',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$progress/${course.totalLessons}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress / course.totalLessons,
                    backgroundColor: AppTheme.borderColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    minHeight: 8,
                  ),
                ),

                const SizedBox(height: 32),

                // Lessons Section
                Text(
                  'Lessons',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 16),

                if (lessons.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Icon(
                            LucideIcons.bookOpen,
                            size: 48,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No lessons available',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: lessons.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final lesson = lessons[index];
                      final isCompleted = progressProvider.isLessonCompleted(lesson.id);
                      final isLocked = index > progress;

                      return _buildLessonCard(
                        lesson: lesson,
                        index: index,
                        isCompleted: isCompleted,
                        isLocked: isLocked,
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard({
    required lesson,
    required int index,
    required bool isCompleted,
    required bool isLocked,
  }) {
    return GestureDetector(
      onTap: isLocked ? null : () {
        context.go('/lesson/${lesson.id}');
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isLocked 
              ? AppTheme.surfaceColor.withOpacity(0.5)
              : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted 
                ? AppTheme.successColor
                : isLocked 
                    ? AppTheme.borderColor.withOpacity(0.5)
                    : AppTheme.borderColor,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppTheme.successColor
                    : isLocked
                        ? AppTheme.textSecondary.withOpacity(0.3)
                        : AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCompleted
                    ? LucideIcons.checkCircle
                    : isLocked
                        ? LucideIcons.lock
                        : LucideIcons.play,
                color: isCompleted
                    ? Colors.white
                    : isLocked
                        ? AppTheme.textSecondary
                        : AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isLocked 
                          ? AppTheme.textSecondary
                          : AppTheme.textPrimary,
                    ),
                  ),
                  if (lesson.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      lesson.description!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isLocked 
                            ? AppTheme.textSecondary.withOpacity(0.7)
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!isLocked) ...[
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.zap,
                    size: 16,
                    color: AppTheme.accentColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${lesson.xpReward}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentColor,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}