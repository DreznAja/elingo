import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/providers/settings_provider.dart';
import '../../../core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Notifications Section
              _buildSectionHeader('Notifications'),
              const SizedBox(height: 16),
              _buildSwitchTile(
                icon: LucideIcons.bell,
                title: 'Daily Reminders',
                subtitle: 'Get reminded to practice daily',
                value: settingsProvider.dailyReminders,
                onChanged: settingsProvider.setDailyReminders,
              ),
              _buildSwitchTile(
                icon: LucideIcons.trophy,
                title: 'Achievement Notifications',
                subtitle: 'Get notified when you unlock achievements',
                value: settingsProvider.achievementNotifications,
                onChanged: settingsProvider.setAchievementNotifications,
              ),
              
              const SizedBox(height: 32),
              
              // Learning Section
              _buildSectionHeader('Learning'),
              const SizedBox(height: 16),
              _buildTile(
                icon: LucideIcons.target,
                title: 'Daily Goal',
                subtitle: '${settingsProvider.dailyGoal} lessons per day',
                onTap: () => _showDailyGoalDialog(context, settingsProvider),
              ),
              _buildSwitchTile(
                icon: LucideIcons.volume2,
                title: 'Sound Effects',
                subtitle: 'Play sounds for correct/incorrect answers',
                value: settingsProvider.soundEffects,
                onChanged: settingsProvider.setSoundEffects,
              ),
              
              const SizedBox(height: 32),
              
              // Privacy Section
              _buildSectionHeader('Privacy & Data'),
              const SizedBox(height: 16),
              _buildTile(
                icon: LucideIcons.shield,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                onTap: () {
                  // TODO: Show privacy policy
                },
              ),
              _buildTile(
                icon: LucideIcons.download,
                title: 'Download My Data',
                subtitle: 'Export your learning data',
                onTap: () {
                  // TODO: Export data
                },
              ),
              _buildTile(
                icon: LucideIcons.trash2,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account',
                onTap: () => _showDeleteAccountDialog(context),
                isDestructive: true,
              ),
              
              const SizedBox(height: 32),
              
              // About Section
              _buildSectionHeader('About'),
              const SizedBox(height: 16),
              _buildTile(
                icon: LucideIcons.info,
                title: 'App Version',
                subtitle: '1.0.0',
                onTap: null,
              ),
              _buildTile(
                icon: LucideIcons.helpCircle,
                title: 'Help & Support',
                subtitle: 'Get help with the app',
                onTap: () {
                  // TODO: Show help
                },
              ),
              _buildTile(
                icon: LucideIcons.star,
                title: 'Rate the App',
                subtitle: 'Leave a review on the app store',
                onTap: () {
                  // TODO: Open app store
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppTheme.errorColor : AppTheme.textSecondary,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          color: isDestructive ? AppTheme.errorColor : AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: onTap != null
          ? const Icon(
              LucideIcons.chevronRight,
              color: AppTheme.textSecondary,
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
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
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  void _showDailyGoalDialog(BuildContext context, SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Daily Goal',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How many lessons do you want to complete each day?',
              style: GoogleFonts.inter(),
            ),
            const SizedBox(height: 16),
            ...List.generate(10, (index) {
              final goal = index + 1;
              return RadioListTile<int>(
                title: Text('$goal lesson${goal > 1 ? 's' : ''}'),
                value: goal,
                groupValue: settingsProvider.dailyGoal,
                onChanged: (value) {
                  if (value != null) {
                    settingsProvider.setDailyGoal(value);
                    Navigator.of(context).pop();
                  }
                },
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Account',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: AppTheme.errorColor,
          ),
        ),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your progress will be lost.',
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
              // TODO: Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion is not implemented yet'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}