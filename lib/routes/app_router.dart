import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/screens/onboarding_screen.dart';
import '../presentation/screens/dashboard_screen.dart';
import '../presentation/screens/auth_screen.dart';
import '../presentation/screens/goal_setup_screen.dart';
import '../presentation/screens/mood_check_screen.dart';
import '../presentation/screens/premium_screen.dart';
import '../presentation/screens/achievements_screen.dart';
import '../presentation/screens/profile_screen.dart';
import '../presentation/screens/settings_screen.dart';
import '../presentation/screens/block_overlay_screen.dart';
import '../presentation/screens/quiz_screen.dart';
import '../presentation/screens/change_limit_screen.dart';
import '../presentation/screens/focus_mode_screen.dart';
import '../presentation/widgets/main_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/goal-setup',
      builder: (context, state) => const GoalSetupScreen(),
    ),
    GoRoute(
      path: '/mood-check',
      builder: (context, state) => const MoodCheckScreen(),
    ),
    
    // Bottom Navigation Screens
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/achievements',
              builder: (context, state) => const AchievementsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),

    // Other screens (premium, quiz, block-overlay)
    GoRoute(
      path: '/premium',
      builder: (context, state) => const PremiumScreen(),
    ),
    GoRoute(
      path: '/quiz',
      builder: (context, state) => const QuizScreen(),
    ),
    GoRoute(
      path: '/block-overlay',
      builder: (context, state) => const BlockOverlayScreen(),
    ),
    GoRoute(
      path: '/change-limit',
      builder: (context, state) => const ChangeLimitScreen(),
    ),
    GoRoute(
      path: '/focus-mode',
      builder: (context, state) => const FocusModeScreen(),
    ),
  ],
);
