import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/result.dart';
import 'package:go_router/go_router.dart';

class EndingScreen extends StatefulWidget {
  const EndingScreen({super.key});

  @override
  State<EndingScreen> createState() => _EndingScreenState();
}

class _EndingScreenState extends State<EndingScreen> {
  late List<String> _lines;
  int _index = 0;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final r = context.read<Result>();
      final avoided = 10 - r.collisions;
      final qc = r.quizCorrect;
      final chosenID = r.chosenId;

      if (r.collisions == 0 && qc == 5 && chosenID == 2) {
        // 進化
        _lines = [
          '主「？！、なんで急に姿が変わったんだ？とりあえず勝ちは勝ちだ、家に帰れるぞ！」',
          '（姿の変わってしまった相棒と帰路に着いた）',
        ];
      } else if (avoided >= 1 && avoided <= 9 && qc >= 3) {
        // 勝ち
        _lines = [
          '主「よし！何とか倒したぞ…これで村に帰れる！」',
          '（大切な相棒と軽い足取りで帰路に着いた）',
        ];
      } else {
        // 負け
        _lines = [
          '主「くそっ…なんでだよ！これじゃ村に帰れないじゃないかっ…とりあえず村に報告しに行くかないと」',
          '（ボロボロのヒノアラシに冷たい視線を送り帰路に着いた）',
        ];
      }

      // 主人公名を反映
      final name = r.playerName;
      _lines = _lines.map((s) => s.replaceAll('主', name)).toList();

      _initialized = true;
    }
  }

  void _nextLine() {
    setState(() {
      _index++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = context.watch<Result>();

    // セリフが残っている間はオーバーレイ表示
    if (_index < _lines.length) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _nextLine,
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
              child: Text(
                _lines[_index],
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    // セリフが終わったらスコアカード＋リプレイボタン
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('エンドロール')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // スコアカード
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  child: Column(
                    children: [
                      // クイズ正解数
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'クイズ正解数: ',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '${r.quizCorrect} / 5',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(color: Colors.blue),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 当たった障害物数
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '当たった障害物: ',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '${r.collisions} / 10',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // もう一度遊ぶボタン
              ElevatedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.replay),
                label: const Text('もう一度遊ぶ'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 24),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
