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

  // 冒頭セリフ
  late final List<String> _dialogue = _lines[widget.chosenId]!;
  int _index = 0;

  // 結果セリフ用
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
        // 衝突数を保存
        context.read<Result>().setCollisions(_game.collisionCount);

        // 結果セリフパターンを決定
        final c = _game.collisionCount;
        if (c == 0) {
          _resultDialogue = _endingsNoMiss;
        } else if (c >= 10) {
          _resultDialogue = _endingsAllHit;
        } else {
          _resultDialogue = _endingsNormal;
        }

        setState(() {
          _showResult = true;
          _resIndex = 0;
        });
      },
    );
  }

  void _nextLine() {
    setState(() {
      _index++;
      if (_index >= _dialogue.length) {
        _index = _dialogue.length;
        _game.resumeEngine();
      }
    });
  }

  void _nextResultLine() {
    setState(() {
      _resIndex++;
      if (_resIndex >= _resultDialogue.length) {
        context.go('/quiz');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
            SizedBox.expand(
          // ── GameWidget の backgroundBuilder で最背面に背景を貼る ──
           child:GameWidget(
            game: _game,
            backgroundBuilder: (_) {
              return SizedBox.expand(
                  child: Image.asset(
                'assets/images/syo.png',
                fit: BoxFit.cover,
                  ),
              );
            },
          ),
            ),

          // ───────── 冒頭セリフオーバーレイ ─────────
          if (!_showResult && _index < _dialogue.length)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _nextLine,
              child: Container(
                color: Colors.black.withOpacity(0.4),
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.all(24),
                child: _buildTextBox(_dialogue[_index]),
              ),
            ),

          // ───────── 結果セリフオーバーレイ ─────────
          if (_showResult)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _nextResultLine,
              child: Container(
                color: Colors.black.withOpacity(0.6),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(24),
                child: _buildTextBox(_resultDialogue[_resIndex]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextBox(String text) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text, style: const TextStyle(fontSize: 18)),
      );
}
// ──────────────── 冒頭セリフ ────────────────
const Map<int, List<String>> _lines = {
  0: [
    '主「え〜と、地図通りだとジムリーダーはこの先か…（チラッ）」',
    '主「このヒノアラシすごい元気だな…ずっとスキップしながらついてきてるよ」',
    '“ガラガラ”',
    '主（なんだ？！すごい音がしたような…）',
    '主（ッ落石か…避けないと大変なことになる）',
  ],
  1: [
    '主「え〜と、地図通りだとジムリーダーはこの先か…（チラッ）」',
    '主「このヒノアラシすごい静かだな 炎青いし全然懐いてない気がする」',
    '“ガラガラ”',
    '主（なんだ？！すごい音がしたような…）',
    '主（ッ落石か…避けないと大変なことになる）',
  ],
  2: [
    '主「え〜と、地図通りだとジムリーダーはこの先か…（チラッ）」',
    '主「このヒノアラシちょっと怖いな…懐いてるけど色が紫なんて村で見たことないよ」',
    '“ガラガラ”',
    '主（なんだ？！すごい音がしたような…）',
    '主（ッ落石か…避けないと大変なことになる）',
  ],
};

// ──────────────── 結果セリフパターン ────────────────
const List<String> _endingsNoMiss = [
  'ノーミス',
  '主「ふぅ、間一髪だったな…何とか怪我せずに済んだ」',
  '主「よし先へ進むか」',
];

const List<String> _endingsAllHit = [
  '全滅',
  '主「うっ…痛い、全身が痛いこんなことならもっと鍛えとけばよかった…ヒノアラシが庇ってくれなかったら死んでたかも」',
  '(ボロボロになったヒノアラシを見る)',
  '主「助けてくれてありがとう。手当してから先へ進もうか」',
];

const List<String> _endingsNormal = [
  'ノーマル（ちょいミス）',
  '主「くっ…少しかすったな、危ないところだった」',
  '主「あと少しだ、先へ進もう」',
];
