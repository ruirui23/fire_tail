//3択クイズ(転)画面
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/result.dart';
import 'package:go_router/go_router.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _qs = [
    ('ほのおタイプの弱点は？', ['みず', 'くさ', 'ほのお'], 0),
    // TODO: 問題を追加
  ];
  int _idx = 0, _correct = 0;

  void _answer(int choice) {
    if (choice == _qs[_idx].$3) _correct++;
    if (++_idx >= _qs.length) {
      context.read<Result>().setQuizCorrect(_correct);
      context.go('/ending');
    } else setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final q = _qs[_idx];
    return Scaffold(
      appBar: AppBar(title: Text('クイズ  ${_idx + 1}/${_qs.length}')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(q.$1, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            for (int i = 0; i < 3; i++)
              ElevatedButton(
                onPressed: () => _answer(i),
                child: Text(q.$2[i]),
              ),
          ],
        ),
      ),
    );
  }
}