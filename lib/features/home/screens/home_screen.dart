import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/progress_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/daily_goal_card.dart';
import '../widgets/streak_card.dart';
import '../widgets/quick_stats_card.dart';
import '../widgets/continue_learning_card.dart';
import '../../statistics/screens/statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _bannerController = PageController();
  int _currentBannerPage = 0;
  
  // For Languages tab
  String _searchQuery = '';
  String? _selectedDifficulty;
  final TextEditingController _searchController = TextEditingController();

  // Data iklan/banner
  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Learn Vocabulary Daily',
      'subtitle': 'Master 10 new words every day',
      'gradient': [Color(0xFF667eea), Color(0xFF764ba2)],
      'icon': LucideIcons.bookOpen,
    },
    {
      'title': 'Practice Speaking',
      'subtitle': 'Improve your pronunciation skills',
      'gradient': [Color(0xFFf093fb), Color(0xFFf5576c)],
      'icon': LucideIcons.mic,
    },
    {
      'title': 'Grammar Lessons',
      'subtitle': 'Build strong language foundation',
      'gradient': [Color(0xFF4facfe), Color(0xFF00f2fe)],
      'icon': LucideIcons.bookMarked,
    },
    {
      'title': 'Cultural Insights',
      'subtitle': 'Understand language through culture',
      'gradient': [Color(0xFF43e97b), Color(0xFF38f9d7)],
      'icon': LucideIcons.globe,
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _loadData();
    _startBannerAutoScroll();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _startBannerAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _bannerController.hasClients) {
        int nextPage = _currentBannerPage + 1;
        if (nextPage >= _banners.length) {
          nextPage = 0;
        }
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        _startBannerAutoScroll();
      }
    });
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      languageProvider.loadLanguages();
      progressProvider.loadUserProgress(authProvider.user!.id);
    }
  }

  List<dynamic> _filterLanguages(List<dynamic> languages) {
    return languages.where((language) {
      final matchesSearch = language.name
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      
      final matchesDifficulty = _selectedDifficulty == null ||
          language.difficultyLevel.toString() == _selectedDifficulty;
      
      return matchesSearch && matchesDifficulty;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          _buildLanguagesTab(),
          const StatisticsScreen(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondary,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.languages),
            label: 'Languages',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.barChart3),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.user),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor.withOpacity(0.05),
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
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  final profile = authProvider.profile;
                  return Container(
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
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white,
                            child: Text(
                              profile?.fullName.substring(0, 1).toUpperCase() ?? 'U',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, ${profile?.fullName ?? 'User'}! 👋',
                                style: GoogleFonts.inter(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ready to continue your learning journey?',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            LucideIcons.bell,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Banner Carousel
              _buildBannerCarousel(),
              
              const SizedBox(height: 24),
              
              // Daily Goal Card
              const DailyGoalCard(),
              
              const SizedBox(height: 20),
              
              // Stats Row
              const Row(
                children: [
                  Expanded(child: StreakCard()),
                  SizedBox(width: 12),
                  Expanded(child: QuickStatsCard()),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Continue Learning Section
              _buildSectionHeader('Continue Learning', LucideIcons.play),
              const SizedBox(height: 12),
              const ContinueLearningCard(),
              
              const SizedBox(height: 24),
              
              // Quick Actions Section
              _buildSectionHeader('Quick Actions', LucideIcons.zap),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildModernQuickActionCard(
                      icon: LucideIcons.languages,
                      title: 'Browse Languages',
                      subtitle: 'Explore new languages',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                      onTap: () => setState(() => _selectedIndex = 1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildModernQuickActionCard(
                      icon: LucideIcons.trophy,
                      title: 'Achievements',
                      subtitle: 'View your progress',
                      gradient: const LinearGradient(
                        colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                      ),
                      onTap: () => context.go('/achievements'),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Banner Carousel
  Widget _buildBannerCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: (index) {
              setState(() {
                _currentBannerPage = index;
              });
            },
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildBannerCard(
                  title: banner['title'],
                  subtitle: banner['subtitle'],
                  gradient: banner['gradient'],
                  icon: banner['icon'],
                  onTap: () {
                    // Navigate or show dialog
                    // context.go(banner['action']);
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentBannerPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentBannerPage == index
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerCard({
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.arrowRight,
              color: Colors.white.withOpacity(0.8),
              size: 32,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagesTab() {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Choose a Language',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Start your learning journey',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search languages...',
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
                
                const SizedBox(height: 16),
                
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'All Levels',
                        value: null,
                        icon: LucideIcons.layers,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Beginner',
                        value: '1',
                        icon: LucideIcons.smile,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Intermediate',
                        value: '2',
                        icon: LucideIcons.trendingUp,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Advanced',
                        value: '3',
                        icon: LucideIcons.zap,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Language List
          Expanded(
            child: Consumer<LanguageProvider>(
              builder: (context, languageProvider, _) {
                if (languageProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (languageProvider.error != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.alertCircle,
                            size: 48,
                            color: AppTheme.errorColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading languages',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            languageProvider.error!,
                            style: GoogleFonts.inter(
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => languageProvider.loadLanguages(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final filteredLanguages = _filterLanguages(languageProvider.languages);

                if (filteredLanguages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.search,
                            size: 48,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No languages found',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search or filters',
                            style: GoogleFonts.inter(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: filteredLanguages.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final language = filteredLanguages[index];
                    return _buildLanguageCard(language, languageProvider);
                  },
                );
              },
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
  }) {
    final isSelected = _selectedDifficulty == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDifficulty = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected 
                    ? Colors.white 
                    : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard(language, LanguageProvider languageProvider) {
    return GestureDetector(
      onTap: () async {
        languageProvider.selectLanguage(language);
        
        // Load courses for this language
        await languageProvider.loadCourses(language.id);
        
        // Navigate to the first course if available
        if (languageProvider.courses.isNotEmpty) {
          final firstCourse = languageProvider.courses.first;
          if (mounted) {
            context.go('/course/${firstCourse.id}');
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No courses available for ${language.name}'),
                backgroundColor: AppTheme.warningColor,
              ),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Flag Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  language.flagEmoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Language Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          language.name,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(language.difficultyLevel)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getDifficultyText(language.difficultyLevel),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getDifficultyColor(language.difficultyLevel),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Icon(
                        LucideIcons.bookOpen,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${language.totalLessons} lessons',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        LucideIcons.clock,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '~${language.totalLessons * 5} min',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Progress bar placeholder
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.0, // TODO: Get actual progress
                      backgroundColor: AppTheme.borderColor,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getDifficultyColor(language.difficultyLevel),
                      ),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Arrow Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                LucideIcons.chevronRight,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(int level) {
    switch (level) {
      case 1:
        return AppTheme.successColor;
      case 2:
        return AppTheme.warningColor;
      case 3:
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getDifficultyText(int level) {
    switch (level) {
      case 1:
        return 'BEGINNER';
      case 2:
        return 'INTERMEDIATE';
      case 3:
        return 'ADVANCED';
      default:
        return 'UNKNOWN';
    }
  }

  Widget _buildProfileTab() {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.accentColor.withOpacity(0.05),
              Colors.white,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Modern Profile Header
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  final profile = authProvider.profile;
                  return Container(
                    padding: const EdgeInsets.all(24),
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
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Text(
                              profile?.fullName.substring(0, 1).toUpperCase() ?? 'U',
                              style: GoogleFonts.inter(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          profile?.fullName ?? 'User',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryColor.withOpacity(0.1),
                                AppTheme.secondaryColor.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Level ${profile?.level ?? 1} • ${profile?.totalXp ?? 0} XP',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Profile Options
              Container(
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
                  children: [
                    _buildModernProfileOption(
                      icon: LucideIcons.user,
                      title: 'Edit Profile',
                      subtitle: 'Update your information',
                      color: AppTheme.primaryColor,
                      onTap: () => context.go('/profile'),
                    ),
                    _buildDivider(),
                    _buildModernProfileOption(
                      icon: LucideIcons.settings,
                      title: 'Settings',
                      subtitle: 'App preferences',
                      color: AppTheme.textSecondary,
                      onTap: () => context.go('/settings'),
                    ),
                    _buildDivider(),
                    _buildModernProfileOption(
                      icon: LucideIcons.helpCircle,
                      title: 'Help & Support',
                      subtitle: 'Get help and support',
                      color: AppTheme.infoColor,
                      onTap: () => context.go('/help'),
                    ),
                    _buildDivider(),
                    _buildModernProfileOption(
                      icon: LucideIcons.logOut,
                      title: 'Sign Out',
                      subtitle: 'Sign out of your account',
                      color: AppTheme.errorColor,
                      onTap: () {
                        Provider.of<AuthProvider>(context, listen: false).signOut();
                      },
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildModernQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 28,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: const Icon(
        LucideIcons.chevronRight,
        color: AppTheme.textSecondary,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: AppTheme.borderColor.withOpacity(0.5),
    );
  }
}