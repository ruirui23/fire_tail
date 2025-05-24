import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flame_audio/flame_audio.dart';

import '../flame/adventure_game.dart';
import '../models/result.dart';
import '../models/game_mode.dart';
class GameScreen extends StatefulWidget {
  final int chosenId; // 0,1,2
  final GameMode mode;
  const GameScreen(
      {Key? key, required this.chosenId, required this.mode})
      : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final AdventureGame _game;
  late List<String> _dialogue; // モード別
  int _idx = 0;

  bool _showResult = false;
  late List<String> _resultDialogue;
  int _resIdx = 0;

  @override
  void initState() {
    super.initState();
    final name = context.read<Result>().playerName;
    _dialogue = _opening[widget.mode]![widget.chosenId]!
        .map((l) => l.replaceAll('主', name))
        .toList();

    _game = AdventureGame(
      chosenId: widget.chosenId,
      mode: widget.mode,
      startPaused: true,
      onFinish: () {
        context.read<Result>().setCollisions(_game.collisionCount);
        final c = _game.collisionCount;
        String key;
        if (c == 0) {
          key = 'noMiss';
        } else if (c >= 10) {
          key = 'allHit';
        } else {
          key = 'normal';
        }
        _resultDialogue = _result[widget.mode]![key]!
            .map((l) => l.replaceAll('主', name))
            .toList();
        setState(() {
          _showResult = true;
          _resIdx = 0;
        });
      },
    );
  }

  
 String _assetForId(int id) {
    if (id == 2) {
      return widget.mode == GameMode.hard      // ← ハード？
          ? 'assets/images/purple.png'         
          : 'assets/images/green.png';        
    }
    // 通常 3 色は今まで通り
    switch (id) {
      case 0:
        return 'assets/images/red.png';
      case 1:
        return 'assets/images/blue.png';
      default:
        return 'assets/images/putple.png';
    }
  }

  void _next() {
    setState(() {
     // 「ガラガラ」セリフなら落石音だけ鳴らし、通常はセリフ切り替え音
    if (_idx + 1 < _dialogue.length && _dialogue[_idx + 1].contains("ガラガラ")) {
      // 次のセリフが「ガラガラ」なら落石音のみ
      _idx++;
      FlameAudio.play('kan_ge_gakefuti01.mp3');
    } else {
      // 通常はセリフ切り替え音
      FlameAudio.play('messagechange.mp3', volume: 0.2);
      _idx++;
    }
    if (_idx >= _dialogue.length) {
      _game.resumeEngine();
    }
  });
}

  void _nextRes() {
    setState(() {
      FlameAudio.play('messaagechange.mp3', volume: 0.2);
      _resIdx++;
      if (_resIdx >= _resultDialogue.length) {
        context.go('/quiz', extra: widget.mode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        // 背景＋ゲーム
        SizedBox.expand(
          child: GameWidget(
            game: _game,
            backgroundBuilder: (_) => SizedBox.expand(
              child: Image.asset('assets/images/syo.png', fit: BoxFit.cover),
            ),
          ),
        ),
        // 冒頭セリフ
        if (!_showResult && _idx < _dialogue.length)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _next,
            child: Container(
              color: Colors.black.withOpacity(0.4),
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.all(24),
              child: _box(_dialogue[_idx]),
            ),
          ),
        // ヒノアラシ立ち絵
        if (!_showResult && _idx < _dialogue.length)
          Positioned(
            bottom: 40,
            left: 300,
            child: Image.asset(_assetForId(widget.chosenId),
                width: 200, height: 200),
          ),
        // 結果セリフ
        if (_showResult)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _nextRes,
            child: Container(
              color: Colors.black.withOpacity(0.6),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(24),
              child: _box(_resultDialogue[_resIdx]),
            ),
          ),
      ]),
    );
  }

  Widget _box(String t) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(t, style: const TextStyle(fontSize: 18)),
      );
}

/* ───────── モード別セリフ ───────── */
const _opening = <GameMode, Map<int, List<String>>>{
  GameMode.normal: {
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
      '主「このヒノアラシの炎、緑色で可愛いなすごくなついてくれている気がする」',
      '“ガラガラ”',
      '主（なんだ？！すごい音がしたような…）',
      '主（ッ落石か…避けないと大変なことになる）',
    ],
  },
  GameMode.hard: {
    0: [
      '主「え〜と、地図通りだとジムリーダーはこの先か…（チラッ）」',
      '主「このヒノアラシすごい元気だな…ずっとスキップしながらついてきてるよ」',
      '"ガラガラ"',
      '主（なんだ？！すごい音がしたような…）',
      '主（ッ落石か…避けないと大変なことになる）',
    ],
    1: [
      '主「え〜と、地図通りだとジムリーダーはこの先か…（チラッ）」',
      '主「このヒノアラシすごい静かだな炎青いし全然懐いてない気がする」',
      '"ガラガラ"', 
      '主（なんだ？！すごい音がしたような…）',
      '主（ッ落石か…避けないと大変なことになる）',
    ],
    2: [
      '主「え〜と、地図通りだとジムリーダーはこの先か…（チラッ）」',
      '主「このヒノアラシちょっと怖いな…懐いてるけど色が紫なんて…この炎の色って普通なのか？」（Cの場合）',
      '"ガラガラ"', 
      '主（なんだ？！すごい音がしたような…）',
      '主（ッ落石か…避けないと大変なことになる）',

    ],
  },
};

const _result = <GameMode, Map<String, List<String>>>{
  GameMode.normal: {
    'noMiss': [
      '主「ふぅ、怪我なしで切り抜けた！」',
      '主「この調子で先へ進もう」',
    ],
    'allHit': [
      '主「うっ…ボロボロだ…」',
      '主「ヒノアラシが庇ってくれた。ありがとう…」',
    ],
    'normal': [
      '主「なんとか凌いだが油断できない！」',
      '主「次はもっと素早く動こう」',
    ],
  },
  GameMode.hard: {
    'noMiss': [
      '主「ふぅ、怪我なしで切り抜けた！」',
      '主「この調子で先へ進もう」',
    ],
    'allHit': [
      '主「うっ…ボロボロだ…」',
      '主「ヒノアラシが庇ってくれた。ありがとう…」',
    ],
    'normal': [
      '主「くっ…少しかすったな、危ないところだった」',
      '主「あと少しだ、先へ進もう」',
    ],
  },
};
