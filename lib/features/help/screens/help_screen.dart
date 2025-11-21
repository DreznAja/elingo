import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // FAQ Section
          Text(
            'Frequently Asked Questions',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFAQItem(
            question: 'How do I change my daily goal?',
            answer: 'Go to Settings > Learning > Daily Goal to adjust how many lessons you want to complete each day.',
          ),
          
          _buildFAQItem(
            question: 'How is my level calculated?',
            answer: 'Your level is based on the total XP you\'ve earned. Every 100 XP increases your level by 1.',
          ),
          
          _buildFAQItem(
            question: 'What happens if I miss a day?',
            answer: 'Your streak will reset to 0, but don\'t worry! You can start building a new streak the next day.',
          ),
          
          _buildFAQItem(
            question: 'How do I unlock new languages?',
            answer: 'All available languages are unlocked from the start. You can switch between them anytime from the Languages tab.',
          ),
          
          _buildFAQItem(
            question: 'Can I practice offline?',
            answer: 'Currently, Elingo requires an internet connection to sync your progress and access lessons.',
          ),
          
          const SizedBox(height: 32),
          
          // Contact Section
          Text(
            'Need More Help?',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildContactOption(
            icon: LucideIcons.mail,
            title: 'Email Support',
            subtitle: 'Get help via email',
            onTap: () => _openEmailSupport(context),
          ),
          
          _buildContactOption(
            icon: LucideIcons.messageCircle,
            title: 'Community Forum',
            subtitle: 'Ask questions and get answers',
            onTap: () => _openCommunityForum(context),
          ),
          
          _buildContactOption(
            icon: LucideIcons.bug,
            title: 'Report a Bug',
            subtitle: 'Help us improve the app',
            onTap: () => _showBugReportDialog(context),
          ),
          
          const SizedBox(height: 32),
          
          // Tips Section
          Text(
            'Learning Tips',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildTipCard(
            icon: LucideIcons.clock,
            title: 'Practice Daily',
            description: 'Even 5-10 minutes a day can make a big difference in your language learning journey.',
          ),
          
          _buildTipCard(
            icon: LucideIcons.repeat,
            title: 'Review Regularly',
            description: 'Go back to previous lessons to reinforce what you\'ve learned.',
          ),
          
          _buildTipCard(
            icon: LucideIcons.target,
            title: 'Set Realistic Goals',
            description: 'Start with a manageable daily goal and increase it as you build the habit.',
          ),
          
          _buildTipCard(
            icon: LucideIcons.users,
            title: 'Practice with Others',
            description: 'Try to use what you\'ve learned in real conversations when possible.',
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      title: Text(
        question,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
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
      trailing: const Icon(
        LucideIcons.chevronRight,
        color: AppTheme.textSecondary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildTipCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 20,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
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
    );
  }

  void _openEmailSupport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening email client...'),
        backgroundColor: AppTheme.primaryColor,
        action: SnackBarAction(
          label: 'Copy Email',
          textColor: Colors.white,
          onPressed: () {
            // In a real app, copy email to clipboard
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Email copied: support@elingo.app'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          },
        ),
      ),
    );
  }

  void _openCommunityForum(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Community Forum',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.users,
              color: AppTheme.primaryColor,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Join our community forum to:\n\n'
              '• Ask questions and get help\n'
              '• Share tips and learning strategies\n'
              '• Connect with other learners\n'
              '• Get updates about new features',
              style: GoogleFonts.inter(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening community forum...'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
            child: const Text('Open Forum'),
          ),
        ],
      ),
    );
  }

  void _showBugReportDialog(BuildContext context) {
    final TextEditingController bugDescriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Report a Bug',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Help us improve Elingo by reporting any bugs or issues you encounter.',
              style: GoogleFonts.inter(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bugDescriptionController,
              decoration: InputDecoration(
                labelText: 'Describe the issue',
                hintText: 'What went wrong?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(LucideIcons.alertCircle),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              bugDescriptionController.dispose();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (bugDescriptionController.text.trim().isNotEmpty) {
                bugDescriptionController.dispose();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bug report submitted. Thank you!'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please describe the issue'),
                    backgroundColor: AppTheme.warningColor,
                  ),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}