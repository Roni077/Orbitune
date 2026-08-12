import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'scaffold_with_nav.dart';
import '../../features/home/views/home_screen.dart';
import '../../features/search/views/search_screen.dart';
import '../../features/library/views/library_screen.dart';
import '../../features/downloads/views/downloads_screen.dart';
import '../../features/settings/views/settings_screen.dart';
import '../../features/onboarding/views/onboarding_screen.dart';
import '../../../core/helpers/settings_provider.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'homeShell');
final shellNavigatorSearchKey = GlobalKey<NavigatorState>(debugLabel: 'searchShell');
final shellNavigatorLibraryKey = GlobalKey<NavigatorState>(debugLabel: 'libraryShell');
final shellNavigatorDownloadsKey = GlobalKey<NavigatorState>(debugLabel: 'downloadsShell');
final shellNavigatorSettingsKey = GlobalKey<NavigatorState>(debugLabel: 'settingsShell');

final goRouterProvider = Provider<GoRouter>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final hasCompletedOnboarding = prefs.getBool('onboarding_completed') ?? false;

  return GoRouter(
    initialLocation: hasCompletedOnboarding ? '/home' : '/onboarding',
    navigatorKey: rootNavigatorKey,
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNav(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorSearchKey,
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorLibraryKey,
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorDownloadsKey,
            routes: [
              GoRoute(
                path: '/downloads',
                builder: (context, state) => const DownloadsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorSettingsKey,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
