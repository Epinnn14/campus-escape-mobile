import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/room_meta.dart';
import '../../presentation/screens/collection/collection_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/insight/insight_card_screen.dart';
import '../../presentation/screens/landing/landing_screen.dart';
import '../../presentation/screens/leaderboard/leaderboard_screen.dart';
import '../../presentation/screens/map/campus_map_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/rooms/ai_lab_room_screen.dart';
import '../../presentation/screens/rooms/algorithm_room_screen.dart';
import '../../presentation/screens/rooms/cyber_security_room_screen.dart';
import '../../presentation/screens/rooms/data_science_room_screen.dart';
import '../../presentation/screens/rooms/database_room_screen.dart';
import '../../presentation/screens/rooms/game_dev_room_screen.dart';
import '../../presentation/screens/rooms/mobile_dev_room_screen.dart';
import '../../presentation/screens/rooms/networking_room_screen.dart';
import '../../presentation/screens/rooms/software_engineering_room_screen.dart';
import '../../presentation/screens/rooms/uiux_room_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/summary/summary_screen.dart';
import '../../presentation/screens/admin/admin_login_screen.dart';
import '../../presentation/screens/admin/admin_screen.dart';
import '../../presentation/shell/main_shell.dart';

/// Satu tempat mapping RoomId → widget ruangan. Route-nya `/room/<RoomId.name>`
/// (lihat RoomMeta.route), jadi peta/home tinggal `context.push(meta.route)`.
Widget roomScreenFor(RoomId id) => switch (id) {
      RoomId.algorithm => const AlgorithmRoomScreen(),
      RoomId.uiUx => const UiuxRoomScreen(),
      RoomId.dataScience => const DataScienceRoomScreen(),
      RoomId.gameDev => const GameDevRoomScreen(),
      RoomId.mobileDev => const MobileDevRoomScreen(),
      RoomId.networking => const NetworkingRoomScreen(),
      RoomId.softwareEngineering => const SoftwareEngineeringRoomScreen(),
      RoomId.database => const DatabaseRoomScreen(),
      RoomId.bonusAi => const AiLabRoomScreen(),
      RoomId.bonusCyber => const CyberSecurityRoomScreen(),
    };

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/landing', builder: (_, __) => const LandingScreen()),

    // 5 hub screen — berbagi bottom nav.
    ShellRoute(
      builder: (context, state, child) =>
          MainShell(location: state.uri.path, child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/map', builder: (_, __) => const CampusMapScreen()),
        GoRoute(path: '/collection', builder: (_, __) => const CollectionScreen()),
        GoRoute(path: '/leaderboard', builder: (_, __) => const LeaderboardScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      ],
    ),

    // Full-screen (di-push di atas tab, tanpa bottom nav).
    GoRoute(
      path: '/room/:id',
      builder: (context, state) {
        final id = RoomId.values.byName(state.pathParameters['id']!);
        return KeyedSubtree(key: ValueKey(id), child: roomScreenFor(id));
      },
    ),
    GoRoute(
      path: '/insight/:id',
      builder: (context, state) => InsightCardScreen(
        roomId: RoomId.values.byName(state.pathParameters['id']!),
        fromGallery: state.uri.queryParameters['from'] == 'gallery',
      ),
    ),
    GoRoute(path: '/summary', builder: (_, __) => const SummaryScreen()),
    GoRoute(path: '/admin', builder: (_, __) => const AdminPanelRoute()),
    GoRoute(path: '/admin/login', builder: (_, __) => const AdminLoginScreen()),
  ],
);
