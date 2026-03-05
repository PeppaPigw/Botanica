import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/add_plant/add_plant_screen.dart';
import '../../features/calendar/calendar_screen.dart';
import '../../features/daily/daily_screen.dart';
import '../../features/discover/discover_screen.dart';
import '../../features/garden/garden_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/permissions_screen.dart';
import '../../features/plant_detail/plant_detail_screen.dart';
import '../../features/profile/credits_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/species/species_detail_screen.dart';
import '../../features/tasks/tasks_screen.dart';
import '../providers.dart';
import 'app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final hasCompletedOnboarding = ref.watch(
    settingsControllerProvider.select((s) => s.hasCompletedOnboarding),
  );

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: SplashScreen.location,
    redirect: (context, state) {
      final location = state.matchedLocation;

      // Let splash render briefly.
      if (location == SplashScreen.location) return null;

      if (!hasCompletedOnboarding) {
        if (location == OnboardingScreen.location ||
            location == PermissionsScreen.location) {
          return null;
        }
        return OnboardingScreen.location;
      }

      if (hasCompletedOnboarding &&
          (location == OnboardingScreen.location ||
              location == PermissionsScreen.location)) {
        return GardenScreen.location;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: SplashScreen.location,
        pageBuilder: (context, state) => const MaterialPage(
          child: SplashScreen(),
        ),
      ),
      GoRoute(
        path: OnboardingScreen.location,
        pageBuilder: (context, state) => const MaterialPage(
          child: OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: PermissionsScreen.location,
        pageBuilder: (context, state) => const MaterialPage(
          child: PermissionsScreen(),
        ),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(
          location: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(
            path: GardenScreen.location,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: GardenScreen(),
            ),
            routes: [
              GoRoute(
                parentNavigatorKey: _rootNavigatorKey,
                path: AddPlantScreen.subLocation,
                pageBuilder: (context, state) {
                  final speciesId = state.uri.queryParameters['speciesId'];
                  return MaterialPage(
                    fullscreenDialog: true,
                    child: AddPlantScreen(initialSpeciesId: speciesId),
                  );
                },
              ),
              GoRoute(
                parentNavigatorKey: _rootNavigatorKey,
                path: TasksScreen.subLocation,
                pageBuilder: (context, state) => const MaterialPage(
                  child: TasksScreen(),
                ),
              ),
              GoRoute(
                parentNavigatorKey: _rootNavigatorKey,
                path: CalendarScreen.subLocation,
                pageBuilder: (context, state) => const MaterialPage(
                  child: CalendarScreen(),
                ),
              ),
              GoRoute(
                parentNavigatorKey: _rootNavigatorKey,
                path: PlantDetailScreen.subLocation,
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id']!;
                  final tab = state.uri.queryParameters['tab'] ?? '';
                  final action = state.uri.queryParameters['action'] ?? '';

                  final initialTabIndex = switch (tab.trim().toLowerCase()) {
                    'care' || '1' => 1,
                    'journal' || '2' => 2,
                    'logs' || '3' => 3,
                    _ => 0,
                  };

                  final normalizedAction = action.trim().toLowerCase();
                  final autoAddPhoto = normalizedAction == 'add_photo';
                  final autoAddNote = normalizedAction == 'add_note';

                  return MaterialPage(
                    child: PlantDetailScreen(
                      plantId: id,
                      initialTabIndex: initialTabIndex,
                      autoAddPhoto: autoAddPhoto,
                      autoAddNote: autoAddNote,
                    ),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: CalendarScreen.location,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CalendarScreen(inShell: true),
            ),
          ),
          GoRoute(
            path: DiscoverScreen.location,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DiscoverScreen(),
            ),
            routes: [
              GoRoute(
                parentNavigatorKey: _rootNavigatorKey,
                path: SpeciesDetailScreen.subLocation,
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return MaterialPage(
                    child: SpeciesDetailScreen(speciesId: id),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: DailyScreen.location,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DailyScreen(),
            ),
          ),
          GoRoute(
            path: ProfileScreen.location,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
            routes: [
              GoRoute(
                parentNavigatorKey: _rootNavigatorKey,
                path: CreditsScreen.subLocation,
                pageBuilder: (context, state) => const MaterialPage(
                  child: CreditsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
