// lib/screens/game_screen.dart

import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../flame/adventure_game.dart';
import '../models/result.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.chosenId});
  final int chosenId; // 0,1,2

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final AdventureGame _game;

  // セリフ（冒頭）
  late final List<String> _dialogue = _lines[widget.chosenId]!;
  int _index = 0;

  // ────────── 結果オーバーレイ用 ──────────
  bool _showResult = false;
  late List<String> _resultDialogue;
  int _resIndex = 0;

  @override
  void initState() {
    super.initState();

    _game = AdventureGame(
      chosenId: widget.chosenId,
      startPaused: true,
      onFinish: () {
          final hits   = _game.collisionCount;
    final total  = _game.spawnCount;

    // Result に保存
    context.read<Result>().setCollisions(hits);

    // 全滅（hit==spawnCount） → ノーミス（hit==0） → それ以外はノーマル
    if (hits == total && total > 0) {
      _resultDialogue = _endingsAllHit;
    } else if (hits == 0) {
      _resultDialogue = _endingsNoMiss;
    } else {
      _resultDialogue = _endingsNormal;
    }

        setState(() {
          _showResult = true; // 結果オーバーレイを表示
        });
      },
    );
  }

  void _nextLine() {
    setState(() {
      _index++;
      if (_index >= _dialogue.length) {
        _index = _dialogue.length;
        _game.resumeEngine(); // 冒頭セリフが終わったらゲーム開始
      }
    });
  }

  void _nextResultLine() {
    setState(() {
      _resIndex++;
      if (_resIndex >= _resultDialogue.length) {
        // 結果セリフを送り切ったらクイズ画面へ
        context.go('/quiz');
      }
    });
  }

  // lib/screens/game_screen.dart

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        GameWidget(game: _game),

        // ── 冒頭セリフオーバーレイ ───────────────────────────
        if (!_showResult && _index < _dialogue.length)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _nextLine,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 32),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _dialogue[_index],
                  style: const TextStyle(fontSize: 18, height: 1.4),
                ),
              ),
            ),
          ),

        // ── 結果セリフオーバーレイ ───────────────────────────
        if (_showResult)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _nextResultLine,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 32),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _resultDialogue[_resIndex],
                  style: const TextStyle(fontSize: 18, height: 1.4),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
}
// ─── 冒頭セリフ ───────────────────────────
const Map<int, List<String>> _lines = {
  //red
0: [
    '主「え〜と、地図通りだとジムリーダーはこの先か…（チラッ）」',
    '主「このヒノアラシすごい元気だな…ずっとスキップしながらついてきてるよ」',
    '“ガラガラ”',
    '主（なんだ？！すごい音がしたような…）',
    '主（ッ落石か…避けないと大変なことになる）',
  ],

  // B (blue)
  1: [
    '主「え〜と、地図通りだとジムリーダーはこの先か…（チラッ）」',
    '主「このヒノアラシすごい静かだな 炎青いし全然懐いてない気がする」',
    '“ガラガラ”',
    '主（なんだ？！すごい音がしたような…）',
    '主（ッ落石か…避けないと大変なことになる）',
  ],

  // C (purple)
  2: [
    '主「え〜と、地図通りだとジムリーダーはこの先か…（チラッ）」',
    '主「このヒノアラシちょっと怖いな…懐いてるけど色が紫なんて村で見たことないよ」',
    '“ガラガラ”',
    '主（なんだ？！すごい音がしたような…）',
    '主（ッ落石か…避けないと大変なことになる）',
  ],
}; 
// ─── 結果セリフパターン ────────────────────
const List<String> _endingsNoMiss = [
  '主「ふぅ、間一髪だったな…何とか怪我せずに済んだだ」',
  '主「よし先へ進むか」',
];

const List<String> _endingsAllHit = [
  '主「うっ…痛い、全身が痛いこんなことならもっと鍛えとけばよかった…ヒノアラシが庇ってくれなかったら死んでたかも」',
  '(ボロボロになったヒノアラシを見る)',
  '主「助けてくれてありがとう。手当してから先へ進もうか」',
];

const List<String> _endingsNormal = [
  '主「くっ…少しかすったな、危ないところだった」',
  '主「あと少しだ、先へ進もう」',
];
