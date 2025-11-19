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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          _buildLanguagesTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondary,
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
            icon: Icon(LucideIcons.user),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                final profile = authProvider.profile;
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Text(
                        profile?.fullName.substring(0, 1).toUpperCase() ?? 'U',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${profile?.fullName ?? 'User'}!',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'Ready to learn today?',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // TODO: Show notifications
                      },
                      icon: const Icon(LucideIcons.bell),
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Daily Goal Card
            const DailyGoalCard(),
            
            const SizedBox(height: 24),
            
            // Stats Row
            Row(
              children: [
                const Expanded(child: StreakCard()),
                const SizedBox(width: 16),
                const Expanded(child: QuickStatsCard()),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Continue Learning
            Text(
              'Continue Learning',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            const ContinueLearningCard(),
            
            const SizedBox(height: 32),
            
            // Quick Actions
            Text(
              'Quick Actions',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    icon: LucideIcons.languages,
                    title: 'Browse Languages',
                    subtitle: 'Explore new languages',
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickActionCard(
                    icon: LucideIcons.trophy,
                    title: 'Achievements',
                    subtitle: 'View your progress',
                    onTap: () {
                      // TODO: Show achievements
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagesTab() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose a Language',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start your language learning journey',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Consumer<LanguageProvider>(
                builder: (context, languageProvider, _) {
                  if (languageProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (languageProvider.languages.isEmpty) {
                    return Center(
                      child: Text(
                        'No languages available',
                        style: GoogleFonts.inter(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    );
                  }
                  
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: languageProvider.languages.length,
                    itemBuilder: (context, index) {
                      final language = languageProvider.languages[index];
                      return _buildLanguageCard(language);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                final profile = authProvider.profile;
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Text(
                        profile?.fullName.substring(0, 1).toUpperCase() ?? 'U',
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
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
                    Text(
                      'Level ${profile?.level ?? 1} • ${profile?.totalXp ?? 0} XP',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  _buildProfileOption(
                    icon: LucideIcons.user,
                    title: 'Edit Profile',
                    onTap: () => context.go('/profile'),
                  ),
                  _buildProfileOption(
                    icon: LucideIcons.settings,
                    title: 'Settings',
                    onTap: () {
                      // TODO: Show settings
                    },
                  ),
                  _buildProfileOption(
                    icon: LucideIcons.helpCircle,
                    title: 'Help & Support',
                    onTap: () {
                      // TODO: Show help
                    },
                  ),
                  _buildProfileOption(
                    icon: LucideIcons.logOut,
                    title: 'Sign Out',
                    onTap: () {
                      Provider.of<AuthProvider>(context, listen: false).signOut();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 32,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard(language) {
    return GestureDetector(
      onTap: () {
        Provider.of<LanguageProvider>(context, listen: false)
            .selectLanguage(language);
        // TODO: Navigate to course selection
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              language.flagEmoji,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 12),
            Text(
              language.name,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${language.totalLessons} lessons',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textSecondary),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          color: AppTheme.textPrimary,
        ),
      ),
      trailing: const Icon(
        LucideIcons.chevronRight,
        color: AppTheme.textSecondary,
      ),
      onTap: onTap,
    );
  }
}