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
    // ホーム
    GoRoute(
      path: '/',
      builder: (_, __) => const HomeScreen(),
    ),

    // 起（ヒノアラシ選択） ─ extra に GameMode を渡す
    GoRoute(
      path: '/choose',
      builder: (_, state) {
        final mode = state.extra as GameMode? ?? GameMode.normal;
        return ChooseScreen(mode: mode);
      },
    ),

    // 承（ゲーム） ─ extra に {'mode': GameMode, 'id': int} を渡す
    GoRoute(
      path: '/game',
      builder: (_, state) {
        final args = state.extra as Map<String, dynamic>? ?? {};
        final mode = args['mode'] as GameMode? ?? GameMode.normal;
        final id = args['id'] as int? ?? 0;
        return GameScreen(chosenId: id, mode: mode);
      },
    ),

    // 転（クイズ）
    GoRoute(
      path: '/quiz',
      builder: (_, __) => const QuizScreen(),
    ),

    // 結（エンディング）
    GoRoute(
      path: '/ending',
      builder: (_, __) => const EndingScreen(),
    ),
  ],
);
