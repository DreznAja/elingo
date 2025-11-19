import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _nameController.text = authProvider.profile?.fullName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
            child: Text(_isEditing ? 'Save' : 'Edit'),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final profile = authProvider.profile;
          
          if (profile == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Profile Picture
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        child: Text(
                          profile.fullName.substring(0, 1).toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 48,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.camera,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(LucideIcons.user),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Email Field (Read-only)
                  TextFormField(
                    initialValue: authProvider.user?.email ?? '',
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(LucideIcons.mail),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: LucideIcons.trophy,
                          title: 'Level',
                          value: '${profile.level}',
                          color: AppTheme.warningColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          icon: LucideIcons.zap,
                          title: 'Total XP',
                          value: '${profile.totalXp}',
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: LucideIcons.flame,
                          title: 'Current Streak',
                          value: '${profile.currentStreak}',
                          color: AppTheme.errorColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          icon: LucideIcons.award,
                          title: 'Best Streak',
                          value: '${profile.longestStreak}',
                          color: AppTheme.successColor,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Account Actions
                  if (!_isEditing) ...[
                    _buildActionTile(
                      icon: LucideIcons.settings,
                      title: 'Settings',
                      onTap: () {
                        // TODO: Navigate to settings
                      },
                    ),
                    _buildActionTile(
                      icon: LucideIcons.helpCircle,
                      title: 'Help & Support',
                      onTap: () {
                        // TODO: Navigate to help
                      },
                    ),
                    _buildActionTile(
                      icon: LucideIcons.shield,
                      title: 'Privacy Policy',
                      onTap: () {
                        // TODO: Show privacy policy
                      },
                    ),
                    _buildActionTile(
                      icon: LucideIcons.logOut,
                      title: 'Sign Out',
                      onTap: () => _showSignOutDialog(),
                      isDestructive: true,
                    ),
                  ],
                  
                  if (authProvider.error != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.errorColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        authProvider.error!,
                        style: GoogleFonts.inter(
                          color: AppTheme.errorColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
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
      trailing: const Icon(
        LucideIcons.chevronRight,
        color: AppTheme.textSecondary,
      ),
      onTap: onTap,
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentProfile = authProvider.profile!;
      
      final updatedProfile = currentProfile.copyWith(
        fullName: _nameController.text.trim(),
        updatedAt: DateTime.now(),
      );
      
      await authProvider.updateProfile(updatedProfile);
      
      if (authProvider.error == null) {
        setState(() {
          _isEditing = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      }
    }
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Sign Out',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
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
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}