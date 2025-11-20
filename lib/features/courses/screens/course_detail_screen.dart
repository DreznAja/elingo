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
  String _searchQuery = '';
  String? _selectedFilter;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LanguageProvider>(context, listen: false)
          .loadLessons(widget.courseId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _filterLessons(List<dynamic> lessons, ProgressProvider progressProvider) {
    return lessons.where((lesson) {
      final matchesSearch = lesson.title
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      
      final lessonIndex = lessons.indexOf(lesson);
      final progress = progressProvider.getCourseProgress(widget.courseId);
      final isCompleted = progressProvider.isLessonCompleted(lesson.id);
      final isLocked = lessonIndex > progress;
      
      bool matchesFilter = true;
      if (_selectedFilter == 'completed') {
        matchesFilter = isCompleted;
      } else if (_selectedFilter == 'in_progress') {
        matchesFilter = !isCompleted && !isLocked;
      } else if (_selectedFilter == 'locked') {
        matchesFilter = isLocked;
      }
      
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<LanguageProvider, ProgressProvider>(
        builder: (context, languageProvider, progressProvider, _) {
          final course = languageProvider.courses
              .where((c) => c.id == widget.courseId)
              .firstOrNull;

          if (course == null) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(LucideIcons.arrowLeft),
                  onPressed: () => context.pop(),
                ),
              ),
              body: const Center(
                child: Text('Course not found'),
              ),
            );
          }

          if (languageProvider.isLoading) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(LucideIcons.arrowLeft),
                  onPressed: () => context.pop(),
                ),
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          final lessons = languageProvider.lessons;
          final filteredLessons = _filterLessons(lessons, progressProvider);
          final progress = progressProvider.getCourseProgress(course.id);
          final progressPercentage = lessons.isEmpty ? 0.0 : progress / course.totalLessons;

          return SafeArea(
            child: Column(
              children: [
                // Header with Course Info
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Navigation Row
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                            onPressed: () => context.pop(),
                          ),
                          Expanded(
                            child: Text(
                              course.title,
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.moreVertical, color: Colors.white),
                            onPressed: () {
                              // TODO: Show course options
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Course Description
                      if (course.description != null)
                        Text(
                          course.description!,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      
                      const SizedBox(height: 20),
                      
                      // Stats Row
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
                          const SizedBox(width: 12),
                          _buildStatChip(
                            icon: LucideIcons.checkCircle,
                            label: '$progress/${course.totalLessons}',
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Progress Bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Course Progress',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              Text(
                                '${(progressPercentage * 100).toInt()}%',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progressPercentage,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Search and Filter Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Search Bar
                      TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search lessons...',
                          hintStyle: GoogleFonts.inter(
                            color: AppTheme.textSecondary,
                          ),
                          prefixIcon: const Icon(
                            LucideIcons.search,
                            color: AppTheme.textSecondary,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    LucideIcons.x,
                                    color: AppTheme.textSecondary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: AppTheme.backgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(
                              label: 'All Lessons',
                              value: null,
                              icon: LucideIcons.list,
                              count: lessons.length,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              label: 'In Progress',
                              value: 'in_progress',
                              icon: LucideIcons.playCircle,
                              count: lessons.where((l) {
                                final index = lessons.indexOf(l);
                                final prog = progressProvider.getCourseProgress(widget.courseId);
                                return !progressProvider.isLessonCompleted(l.id) && index <= prog;
                              }).length,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              label: 'Completed',
                              value: 'completed',
                              icon: LucideIcons.checkCircle2,
                              count: lessons.where((l) => 
                                progressProvider.isLessonCompleted(l.id)
                              ).length,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              label: 'Locked',
                              value: 'locked',
                              icon: LucideIcons.lock,
                              count: lessons.where((l) {
                                final index = lessons.indexOf(l);
                                final prog = progressProvider.getCourseProgress(widget.courseId);
                                return index > prog;
                              }).length,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Lessons List
                Expanded(
                  child: filteredLessons.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _searchQuery.isNotEmpty 
                                      ? LucideIcons.search 
                                      : LucideIcons.bookOpen,
                                  size: 48,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty 
                                      ? 'No lessons found'
                                      : 'No lessons available',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _searchQuery.isNotEmpty 
                                      ? 'Try adjusting your search or filters'
                                      : 'Check back later for new lessons',
                                  style: GoogleFonts.inter(
                                    color: AppTheme.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredLessons.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final lesson = filteredLessons[index];
                            final originalIndex = lessons.indexOf(lesson);
                            final isCompleted = progressProvider.isLessonCompleted(lesson.id);
                            final isLocked = originalIndex > progress;

                            return _buildLessonCard(
                              lesson: lesson,
                              index: originalIndex,
                              isCompleted: isCompleted,
                              isLocked: isLocked,
                            );
                          },
                        ),
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
            size: 14,
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

  Widget _buildFilterChip({
    required String label,
    required String? value,
    required IconData icon,
    required int count,
  }) {
    final isSelected = _selectedFilter == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.primaryColor 
              : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? AppTheme.primaryColor 
                : AppTheme.borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected 
                  ? Colors.white 
                  : AppTheme.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected 
                    ? Colors.white 
                    : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.white.withOpacity(0.2)
                    : AppTheme.borderColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected 
                      ? Colors.white 
                      : AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
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
        padding: const EdgeInsets.all(16),
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
            width: 2,
          ),
          boxShadow: isLocked ? null : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Status Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppTheme.successColor
                    : isLocked
                        ? AppTheme.textSecondary.withOpacity(0.2)
                        : AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCompleted
                    ? LucideIcons.checkCircle
                    : isLocked
                        ? LucideIcons.lock
                        : LucideIcons.playCircle,
                color: isCompleted
                    ? Colors.white
                    : isLocked
                        ? AppTheme.textSecondary
                        : AppTheme.primaryColor,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Lesson Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Lesson ${index + 1}',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      if (isCompleted) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.check,
                                size: 10,
                                color: AppTheme.successColor,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Completed',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.successColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
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
                        fontSize: 13,
                        color: isLocked 
                            ? AppTheme.textSecondary.withOpacity(0.7)
                            : AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.fileQuestion,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${lesson.content.length} questions',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        LucideIcons.clock,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '~5 min',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // XP Badge
            if (!isLocked)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.zap,
                      size: 14,
                      color: AppTheme.accentColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${lesson.xpReward}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentColor,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}