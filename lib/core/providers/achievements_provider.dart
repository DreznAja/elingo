import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/achievement.dart';

class AchievementsProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  List<Achievement> _achievements = [];
  Set<String> _earnedAchievements = {};
  bool _isLoading = false;
  String? _error;

  List<Achievement> get achievements => _achievements;
  Set<String> get earnedAchievements => _earnedAchievements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAchievements() async {
    try {
      _setLoading(true);
      _clearError();

      // Load all achievements
      final achievementsResponse = await _supabase
          .from('achievements')
          .select()
          .order('created_at');

      _achievements = (achievementsResponse as List)
          .map((json) => Achievement.fromJson(json))
          .toList();

      // Load user's earned achievements
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final earnedResponse = await _supabase
            .from('user_achievements')
            .select('achievement_id')
            .eq('user_id', user.id);

        _earnedAchievements = earnedResponse
            .map<String>((item) => item['achievement_id'] as String)
            .toSet();
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to load achievements: $e');
    } finally {
      _setLoading(false);
    }
  }

  bool isAchievementEarned(String achievementId) {
    return _earnedAchievements.contains(achievementId);
  }

  Future<void> checkAndUnlockAchievements(String userId) async {
    try {
      // This would typically be called after completing a lesson
      // to check if any new achievements should be unlocked
      
      for (final achievement in _achievements) {
        if (_earnedAchievements.contains(achievement.id)) continue;
        
        bool shouldUnlock = false;
        
        switch (achievement.requirementType) {
          case 'lessons_completed':
            final completedCount = await _getCompletedLessonsCount(userId);
            shouldUnlock = completedCount >= achievement.requirementValue;
            break;
          case 'streak_days':
            final currentStreak = await _getCurrentStreak(userId);
            shouldUnlock = currentStreak >= achievement.requirementValue;
            break;
          case 'total_xp':
            final totalXp = await _getTotalXp(userId);
            shouldUnlock = totalXp >= achievement.requirementValue;
            break;
        }
        
        if (shouldUnlock) {
          await _unlockAchievement(userId, achievement.id);
          _earnedAchievements.add(achievement.id);
        }
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to check achievements: $e');
    }
  }

  Future<int> _getCompletedLessonsCount(String userId) async {
    final response = await _supabase
        .from('lesson_completions')
        .select('id')
        .eq('user_id', userId);
    return response.length;
  }

  Future<int> _getCurrentStreak(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select('current_streak')
        .eq('id', userId)
        .single();
    return response['current_streak'] ?? 0;
  }

  Future<int> _getTotalXp(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select('total_xp')
        .eq('id', userId)
        .single();
    return response['total_xp'] ?? 0;
  }

  Future<void> _unlockAchievement(String userId, String achievementId) async {
    await _supabase.from('user_achievements').insert({
      'user_id': userId,
      'achievement_id': achievementId,
    });
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}