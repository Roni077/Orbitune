import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_screen.dart';
import '../features/library/library_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/search/search_screen.dart';
import '../features/player/player_screen.dart';
import '../features/equalizer/equalizer_screen.dart';
import '../features/settings/screens/appearance_screen.dart';
import '../features/settings/screens/playback_screen.dart';
import '../features/settings/screens/data_screen.dart';
import '../features/settings/screens/about_screen.dart';
import '../shared/scaffold_with_nav_bar.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorSettingsKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/library',
              builder: (context, state) => const LibraryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorSettingsKey,
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'appearance',
                  builder: (context, state) => const AppearanceSettingsScreen(),
                ),
                GoRoute(
                  path: 'playback',
                  builder: (context, state) => const PlaybackSettingsScreen(),
                ),
                GoRoute(
                  path: 'data',
                  builder: (context, state) => const DataSettingsScreen(),
                ),
                GoRoute(
                  path: 'about',
                  builder: (context, state) => const AboutSettingsScreen(),
                ),
              ]
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/search',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/player',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PlayerScreen(),
    ),
    GoRoute(
      path: '/equalizer',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const EqualizerScreen(),
    ),
  ],
);
