//障害物をよけるアクションゲーム(承)画面
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:go_router/go_router.dart'; // Added import for go_router
import '../flame/adventure_game.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key, required this.chosenId});
  final int chosenId;                    // 0=hinoarashi1, 1=hinoarashi2, 2=tyebu

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: AdventureGame(
          chosenId: chosenId,
         onFinish: () => context.go('/quiz'),  
        ),
      ),
    );
  }
}
