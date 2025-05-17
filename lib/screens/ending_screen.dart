//最後のセリフ表示の結の画面

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/result.dart';
import 'package:go_router/go_router.dart';

class EndingScreen extends StatelessWidget {
  const EndingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = context.watch<Result>();

    String ending;
    if (r.quizCorrect >= 4 && r.collisions == 0) {
      ending = 'GOOD END\nヒノアラシは大冒険を成し遂げた！';
    } else if (r.quizCorrect >= 2) {
      ending = 'NORMAL END\nヒノアラシは冒険を続ける！';
    } else {
      ending = 'BAD END\n弱いヒノアラシなんていらない…';
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('エンドロール')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // エンディングタイトル
              Text(
                ending,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.deepOrange),
              ),
              const SizedBox(height: 32),

              // スコアカード
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: 24),
                  child: Column(
                    children: [
                      // クイズ正解数
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'クイズ正解数',
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
                        ],
                      ),
                      const SizedBox(height: 24),

                      // よけた障害物数
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shield, size: 32, color: Colors.red),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '当たった障害物',
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
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
