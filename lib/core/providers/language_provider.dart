import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/language.dart';
import '../models/course.dart';
import '../models/lesson.dart';

class LanguageProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  List<Language> _languages = [];
  List<Course> _courses = [];
  List<Lesson> _lessons = [];
  Language? _selectedLanguage;
  Course? _selectedCourse;
  bool _isLoading = false;
  String? _error;

  List<Language> get languages => _languages;
  List<Course> get courses => _courses;
  List<Lesson> get lessons => _lessons;
  Language? get selectedLanguage => _selectedLanguage;
  Course? get selectedCourse => _selectedCourse;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadLanguages() async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _supabase
          .from('languages')
          .select()
          .order('name');

      _languages = (response as List)
          .map((json) => Language.fromJson(json))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('Failed to load languages: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCourses(String languageId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _supabase
          .from('courses')
          .select()
          .eq('language_id', languageId)
          .order('order_index');

      _courses = (response as List)
          .map((json) => Course.fromJson(json))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('Failed to load courses: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadLessons(String courseId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _supabase
          .from('lessons')
          .select()
          .eq('course_id', courseId)
          .order('order_index');

      _lessons = (response as List)
          .map((json) => Lesson.fromJson(json))
          .toList();

      notifyListeners();
    } catch (e) {
      _setError('Failed to load lessons: $e');
    } finally {
      _setLoading(false);
    }
  }

  void selectLanguage(Language language) {
    _selectedLanguage = language;
    _courses = [];
    _lessons = [];
    loadCourses(language.id);
    notifyListeners();
  }

  void selectCourse(Course course) {
    _selectedCourse = course;
    _lessons = [];
    loadLessons(course.id);
    notifyListeners();
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