import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:go_router/go_router.dart';
import '../flame/adventure_game.dart';
import '../models/result.dart'; // Make sure this path points to where Result is defined
import 'package:provider/provider.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.chosenId});
  final int chosenId; // 0,1,2

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final AdventureGame _game;

  // セリフテーブル（選択 ID → 台詞リスト）
  late final List<String> _dialogue = _lines[widget.chosenId]!;
  int _index = 0; // 現在表示中の行

  @override
  void initState() {
    super.initState();
    _game = AdventureGame(
      chosenId: widget.chosenId,
      onFinish: () {
        Provider.of<Result>(context, listen: false).setCollisions(_game.collisionCount);
        context.go('/quiz');
      },
       startPaused: true,
    );
  }

  void _nextLine() {
    setState(() {
      _index++;
      if (_index >= _dialogue.length) {
        // すべて表示し終えたらゲーム開始
        _index = _dialogue.length; // オーバーフロー防止
        _game.resumeEngine();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _game),
          // セリフオーバーレイ（残っている間だけ表示）
          if (_index < _dialogue.length)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _nextLine,
              child: Container(
                color: Colors.black.withOpacity(0.4),
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _dialogue[_index],
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// キャラごとのセリフ定義
// ─────────────────────────────────────────────
const Map<int, List<String>> _lines = {
  // A (hinoarashi1)
  0: [
    '主「え〜と、地図通りだとジムリーダーはこの先か…（チラッ）」',
    '主「このヒノアラシすごい元気だな…ずっとスキップしながらついてきてるよ」',
    '“ガラガラ”',
    '主（なんだ？！すごい音がしたような…）',
    '主（ッ落石か…避けないと大変なことになる）',
  ],

  // B (hinoarashi2)
  1: [
    '主「え〜と、地図通りだとジムリーダーはこの先か…（チラッ）」',
    '主「このヒノアラシすごい静かだな 炎青いし全然懐いてない気がする」',
    '“ガラガラ”',
    '主（なんだ？！すごい音がしたような…）',
    '主（ッ落石か…避けないと大変なことになる）',
  ],

  // C (tyebu)
  2: [
    '主「え〜と、地図通りだとジムリーダーはこの先か…（チラッ）」',
    '主「このヒノアラシちょっと怖いな…懐いてるけど色が紫なんて村で見たことないよ」',
    '“ガラガラ”',
    '主（なんだ？！すごい音がしたような…）',
    '主（ッ落石か…避けないと大変なことになる）',
  ],
};
