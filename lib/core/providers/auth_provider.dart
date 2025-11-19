import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  User? _user;
  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initialize();
  }

  void _initialize() {
    _user = _supabase.auth.currentUser;
    if (_user != null) {
      _loadProfile();
    }
    
    _supabase.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      if (_user != null) {
        _loadProfile();
      } else {
        _profile = null;
      }
      notifyListeners();
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user != null) {
        _user = response.user;
        await _loadProfile();
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _user = response.user;
        await _loadProfile();
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      _user = null;
      _profile = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> _loadProfile() async {
    if (_user == null) return;

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', _user!.id)
          .single();

      _profile = UserProfile.fromJson(response);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load profile: $e');
    }
  }

  Future<void> updateProfile(UserProfile updatedProfile) async {
    try {
      _setLoading(true);
      _clearError();

      await _supabase
          .from('profiles')
          .update(updatedProfile.toJson())
          .eq('id', updatedProfile.id);

      _profile = updatedProfile;
      notifyListeners();
    } catch (e) {
      _setError('Failed to update profile: $e');
    } finally {
      _setLoading(false);
    }
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