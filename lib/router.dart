//各画面のURLパスの定義や画面遷移の設定のプログラム
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';      
import 'screens/choose_screen.dart';
import 'screens/game_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/ending_screen.dart';

final appRouter = GoRouter(
  routes: [
    // ホーム
    GoRoute(
      path: '/',
      builder: (_, __) => const HomeScreen(),
    ),

    // 起（ヒノアラシ選択）
    GoRoute(
      path: '/choose',
      builder: (_, __) => const ChooseScreen(),
    ),

    // 承（ゲーム） ─ extra に選択 ID を渡す
    GoRoute(
      path: '/game',
      builder: (_, state) {
        final id = state.extra as int? ?? 0;
        return GameScreen(chosenId: id);
      },
    ),

    GoRoute(path: '/quiz',   builder: (_, __) => const QuizScreen()),
    GoRoute(path: '/ending', builder: (_, __) => const EndingScreen()),
  ],
);

