import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../../features/onboarding/screens/welcome_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/languages/screens/language_selection_screen.dart';
import '../../features/courses/screens/course_detail_screen.dart';
import '../../features/lessons/screens/lesson_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/welcome',
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isAuthenticated = authProvider.isAuthenticated;
      
      // Public routes that don't require authentication
      final publicRoutes = ['/welcome', '/login', '/signup'];
      
      if (!isAuthenticated && !publicRoutes.contains(state.uri.toString())) {
        return '/welcome';
      }
      
      if (isAuthenticated && publicRoutes.contains(state.uri.toString())) {
        return '/home';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/languages',
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: '/course/:courseId',
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          return CourseDetailScreen(courseId: courseId);
        },
      ),
      GoRoute(
        path: '/lesson/:lessonId',
        builder: (context, state) {
          final lessonId = state.pathParameters['lessonId']!;
          return LessonScreen(lessonId: lessonId);
        },
      ),
    ],
  );
}