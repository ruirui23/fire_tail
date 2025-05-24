import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/result.dart';
import '../models/game_mode.dart';

class EndingScreen extends StatefulWidget {
  const EndingScreen({super.key});
  @override
  State<EndingScreen> createState() => _EndingScreenState();
}

class _EndingScreenState extends State<EndingScreen> {
  late List<String> _lines;
  int  _idx    = 0;
  bool _inited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;

    final r    = context.read<Result>();
    final mode = GoRouterState.of(context).extra as GameMode? ?? GameMode.normal;

    /* ───── エンディング種別判定 ───── */
    String key;
    if (r.collisions == 0 && r.quizCorrect == 5 && r.chosenId == 2) {
      key = 'evolution';                           // シークレット
    } else if (r.collisions <= 8 && r.quizCorrect >= 2) {
      key = 'win';                                 // 勝ち
    } else {
      key = 'lose';                                // 負け
    }

    _saveFlags(mode, key);

    _lines = _endPreset[mode]![key]!
        .map((s) => s.replaceAll('主', r.playerName))
        .toList();

    _inited = true;
  }

  /* ───────── フラグ保存 ───────── */
  Future<void> _saveFlags(GameMode mode, String key) async {
    final p = await SharedPreferences.getInstance();
    if (mode == GameMode.normal) {
      if (key == 'lose')       p.setBool('end_lose',   true);
      if (key == 'win')        p.setBool('end_win',    true);
      if (key == 'evolution')  p.setBool('end_secret', true);
      if (key == 'win' || key == 'evolution') {
        p.setBool('hardUnlocked', true);             // ハード解放
      }
    } else {
      if (key == 'lose')       p.setBool('hard_lose',   true);
      if (key == 'win')        p.setBool('hard_win',    true);
      if (key == 'evolution')  p.setBool('hard_secret', true);
    }
  }

  /* ───────── 背景ウィジェット ─────────
     1) hinoarashimura.png
     2) hinoarashi.png
     3) グレー
  */
  Widget _background() => Positioned.fill(
        child: Image.asset(
          'assets/images/hionoarashimura.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/images/hinoarashi.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: Colors.grey[200]),
          ),
        ),
      );

  /* ───────── UI ───────── */
  void _next() => setState(() => _idx++);

  @override
  Widget build(BuildContext context) {
    final r = context.watch<Result>();

    /* ── セリフパート ── */
    if (_idx < _lines.length) {
      return Scaffold(
        body: Stack(children: [
          _background(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _next,
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _lines[_idx],
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ]),
      );
    }

    /* ── スコアカード ── */
    return Scaffold(
      appBar: AppBar(title: const Text('エンドロール')),
      body: Stack(children: [
        _background(),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Card(
                color: Colors.white.withOpacity(0.9),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: 24),
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text('クイズ正解数: '),
                      Text('${r.quizCorrect}/5',
                          style: const TextStyle(
                              fontSize: 24, color: Colors.blue)),
                    ]),
                    const SizedBox(height: 16),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text('当たった障害物: '),
                      Text('${r.collisions}/10',
                          style: const TextStyle(
                              fontSize: 24, color: Colors.red)),
                    ]),
                  ]),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.replay),
                label: const Text('もう一度遊ぶ'),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

/* ───────── エンディング文テーブル ───────── */
const _endPreset = <GameMode, Map<String, List<String>>>{
  GameMode.normal: {
    'win': [
      '主「よし！何とか倒せた！」',
      '（大切な相棒と帰路に着いた）',
    ],
    'lose': [
      '主「くそっ…負けた…」',
      '（ヒノアラシを抱え帰路に着いた）',
    ],
    'evolution': [
      '主「？！突然進化した…」',
      '（姿の変わった相棒と帰路に着いた）',
    ],
  },
  GameMode.hard: {
    'win': [
      '主「ハードでも勝った！」',
      '主「ヒノアラシ、ありがとう！」',
    ],
    'lose': [
      '主「……ハードは手強いな」',
      '主「でも次は負けない！」',
    ],
    'evolution': [
      '主「ハードで進化…伝説になる！」',
    ],
  },
};
