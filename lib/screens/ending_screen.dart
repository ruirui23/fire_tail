import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/result.dart';
import '../models/game_mode.dart';

class EndingScreen extends StatefulWidget {
  const EndingScreen({super.key});
  @override
  State<EndingScreen> createState() => _EndingScreenState();
}

class _EndingScreenState extends State<EndingScreen> {
  late List<String> _lines;
  int _idx = 0, _initialized = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized == 1) return;

    final r = context.read<Result>();
    final mode =
        GoRouterState.of(context).extra as GameMode? ?? GameMode.normal;
    final avoided = 10 - r.collisions;
    final qc = r.quizCorrect;
    final chosen = r.chosenId;

    String key;
    if (r.collisions == 0 && qc == 5 && chosen == 2) {
      key = 'evolution';
    } else if (avoided >= 1 && avoided <= 9 && qc >= 3) {
      key = 'win';
    } else {
      key = 'lose';
    }
    _lines = _endPreset[mode]![key]!
        .map((l) => l.replaceAll('主', r.playerName))
        .toList();
    _initialized = 1;
  }

  void _next() => setState(() => _idx++);

  @override
  Widget build(BuildContext context) {
    final r = context.watch<Result>();

    if (_idx < _lines.length) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _next,
          child: Container(
            color: Colors.black.withOpacity(0.6),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_lines[_idx],
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center),
            ),
          ),
        ),
      );
    }

    // スコア画面
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('エンドロール')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('クイズ正解数: ',
                        style: Theme.of(context).textTheme.bodyMedium),
                    Text('${r.quizCorrect} / 5',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(color: Colors.blue)),
                  ]),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('当たった障害物: ',
                        style: Theme.of(context).textTheme.bodyMedium),
                    Text('${r.collisions} / 10',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(color: Colors.red)),
                  ]),
                ]),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.replay),
              label: const Text('もう一度遊ぶ'),
              style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  textStyle: const TextStyle(fontSize: 18)),
            ),
          ]),
        ),
      ),
    );
  }
}

/* ───────── モード別エンディング ───────── */
const _endPreset = <GameMode, Map<String, List<String>>>{
  GameMode.normal: {
    'win': [
      '主「よし！何とか倒したぞ…これで村に帰れる！」',
      '（大切な相棒と軽い足取りで帰路に着いた）',
    ],
    'lose': [
      '主「くそっ…なんでだよ！帰れないじゃないか…」',
      '（ボロボロのヒノアラシに冷たい視線を送り帰路に着いた）',
    ],
    'evolution': [
      '主「？！急に姿が変わった…勝ちは勝ちだ、帰ろう！」',
      '（姿の変わった相棒と帰路に着いた）',
    ],
  },
  GameMode.hard: {
    'win': [
      '主「あ',
      '主「が',
    ],
    'lose': [
      '主「く」',
    ],
    'evolution': [
      '主「いえい！」',
      
    ],
  },
};
