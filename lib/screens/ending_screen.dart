//プレイ結果をもとにエンディングを表示する(結)画面
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
    if (r.quizCorrect >= 4 && r.dodged >= 15) {
      ending = 'GOOD END – ヒノアラシは大冒険を成し遂げた！';
    } else if (r.quizCorrect >= 2) {
      ending = 'NORMAL END – ヒノアラシは冒険を続ける！';
    } else {
      ending = 'BAD END – 弱いヒノアラシなんていならない…';
    }
    return Scaffold(
      appBar: AppBar(title: const Text('エンドロール')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(ending, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 32),
            Text('クイズ正解数: ${r.quizCorrect}/5'),
            Text('よけた障害物: ${r.dodged}'),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () => context.go('/'), child: const Text('もう一度')),
          ],
        ),
      ),
    );
  }
}