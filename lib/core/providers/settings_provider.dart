import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _dailyReminders = true;
  bool _achievementNotifications = true;
  bool _soundEffects = true;
  int _dailyGoal = 5;

  bool get dailyReminders => _dailyReminders;
  bool get achievementNotifications => _achievementNotifications;
  bool get soundEffects => _soundEffects;
  int get dailyGoal => _dailyGoal;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _dailyReminders = prefs.getBool('daily_reminders') ?? true;
    _achievementNotifications = prefs.getBool('achievement_notifications') ?? true;
    _soundEffects = prefs.getBool('sound_effects') ?? true;
    _dailyGoal = prefs.getInt('daily_goal') ?? 5;
    notifyListeners();
  }

  Future<void> setDailyReminders(bool value) async {
    _dailyReminders = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_reminders', value);
    notifyListeners();
  }

  Future<void> setAchievementNotifications(bool value) async {
    _achievementNotifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('achievement_notifications', value);
    notifyListeners();
  }

  Future<void> setSoundEffects(bool value) async {
    _soundEffects = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_effects', value);
    notifyListeners();
  }

  Future<void> setDailyGoal(int value) async {
    _dailyGoal = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_goal', value);
    notifyListeners();
  }
}