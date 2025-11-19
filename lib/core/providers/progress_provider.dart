import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProgressProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  Map<String, int> _courseProgress = {};
  Set<String> _completedLessons = {};
  Map<String, dynamic>? _dailyGoal;
  bool _isLoading = false;
  String? _error;

  Map<String, int> get courseProgress => _courseProgress;
  Set<String> get completedLessons => _completedLessons;
  Map<String, dynamic>? get dailyGoal => _dailyGoal;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserProgress(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      // Load course progress
      final progressResponse = await _supabase
          .from('user_progress')
          .select('course_id, lessons_completed')
          .eq('user_id', userId);

      _courseProgress = {};
      for (final progress in progressResponse) {
        _courseProgress[progress['course_id']] = progress['lessons_completed'];
      }

      // Load completed lessons
      final completionsResponse = await _supabase
          .from('lesson_completions')
          .select('lesson_id')
          .eq('user_id', userId);

      _completedLessons = completionsResponse
          .map<String>((completion) => completion['lesson_id'] as String)
          .toSet();

      // Load daily goal
      final today = DateTime.now().toIso8601String().split('T')[0];
      final dailyGoalResponse = await _supabase
          .from('daily_goals')
          .select()
          .eq('user_id', userId)
          .eq('date', today)
          .maybeSingle();

      _dailyGoal = dailyGoalResponse;

      notifyListeners();
    } catch (e) {
      _setError('Failed to load progress: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> completeLesson({
    required String userId,
    required String lessonId,
    required String courseId,
    required int score,
    required double accuracy,
    required int timeSpent,
    required int xpReward,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Record lesson completion
      await _supabase.from('lesson_completions').upsert({
        'user_id': userId,
        'lesson_id': lessonId,
        'score': score,
        'accuracy': accuracy,
        'time_spent': timeSpent,
      });

      // Update course progress
      final currentProgress = _courseProgress[courseId] ?? 0;
      final newProgress = currentProgress + 1;
      
      await _supabase.from('user_progress').upsert({
        'user_id': userId,
        'course_id': courseId,
        'lessons_completed': newProgress,
        'total_xp_earned': (_courseProgress[courseId] ?? 0) * 10 + xpReward,
        'last_accessed': DateTime.now().toIso8601String(),
      });

      // Update user profile XP
      await _supabase.rpc('update_user_xp', params: {
        'user_id': userId,
        'xp_to_add': xpReward,
      });

      // Update daily goal
      if (_dailyGoal != null) {
        final currentValue = _dailyGoal!['current_value'] ?? 0;
        final targetValue = _dailyGoal!['target_value'] ?? 5;
        final newValue = currentValue + 1;
        
        await _supabase.from('daily_goals').update({
          'current_value': newValue,
          'completed': newValue >= targetValue,
        }).eq('id', _dailyGoal!['id']);

        _dailyGoal!['current_value'] = newValue;
        _dailyGoal!['completed'] = newValue >= targetValue;
      }

      // Update local state
      _courseProgress[courseId] = newProgress;
      _completedLessons.add(lessonId);

      notifyListeners();
    } catch (e) {
      _setError('Failed to complete lesson: $e');
    } finally {
      _setLoading(false);
    }
  }

  int getCourseProgress(String courseId) {
    return _courseProgress[courseId] ?? 0;
  }

  bool isLessonCompleted(String lessonId) {
    return _completedLessons.contains(lessonId);
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