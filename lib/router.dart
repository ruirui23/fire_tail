// lib/router.dart
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/choose_screen.dart';
import 'screens/game_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/ending_screen.dart';
import 'models/game_mode.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/choose', builder: (_, state) {
      final mode = state.extra as GameMode? ?? GameMode.normal;
      return ChooseScreen(mode: mode);
    }),
    GoRoute(path: '/game', builder: (_, state) {
      final extra = state.extra as Map<String, dynamic>? ?? {};
      return GameScreen(
        chosenId: extra['id'] as int,
        mode: extra['mode'] as GameMode
      );
    }),
    GoRoute(path: '/quiz', builder: (_, state) {
      final mode = state.extra as GameMode? ?? GameMode.normal;
      return QuizScreen(mode: mode);
    }),
    GoRoute(path: '/ending', builder: (_, __) => const EndingScreen()),
  ],
);
