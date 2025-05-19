// lib/screens/quiz_screen.dart

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
  // ─── 冒頭セリフ ─────────────────────────────
  final List<String> _introLines = [
    '主「やっとたどり着いた…」',
    '主（ここに来るまでにかなり体力を使ってしまった果てして私に勝てるだろうか）',
    '不安な気持ちを察したのかヒノアラシが「ひのっ」と可愛い声で鳴いてくれた',
    '主「よし、行こう！」',
  ];
  int _introIndex = 0;
  bool _showIntro = true;

  // ─── クイズデータ ─────────────────────────────
  final _qs = [
    ('ほのおタイプの弱点は？', ['みず', 'くさ', 'ほのお'], 0),
    ('ヒノアラシの体重はおよそ何kg？', ['5.3kg', '6.5kg', '7.9kg'], 2),
    ('ヒノアラシの進化後の姿（第２進化）はどれ？', ['バクフーン', 'マグカルゴ', 'マグマラシ'], 2),
    ('ヒノアラシの英語名は次のうちどれ？', ['Cyndaquil', 'Quilava', 'Typhlosion'], 0),
    ('ヒノアラシの分類名称「○○ポケモン」の○○に入る言葉は？', ['ひねずみ', 'ほのお', 'かえん'], 0),
  ];
  int _idx = 0, _correct = 0;

  void _answer(int choice) {
    if (choice == _qs[_idx].$3) _correct++;
    if (++_idx >= _qs.length) {
      context.read<Result>().setQuizCorrect(_correct);
      context.go('/ending');
    } else {
      setState(() {});
    }
  }

  void _nextIntro() {
    setState(() {
      _introIndex++;
      if (_introIndex >= _introLines.length) {
        _showIntro = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = _qs[_idx];

    return Scaffold(
      appBar: AppBar(title: Text('クイズ  ${_idx + 1}/${_qs.length}')),
      body: Stack(
        children: [
          // ─── クイズ本体 ─────────────────────────
          Padding(
            padding: const EdgeInsets.all(60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  q.$1,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                const Divider(thickness: 3),
                const SizedBox(height: 30),
                Column(
                  children: [
                    for (int i = 0; i < 3; i++) ...[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, 55),
                          backgroundColor: Colors.blue[300],
                          foregroundColor: Colors.white,
                          elevation: 7,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          shadowColor: Colors.blue[200],
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed:
                            _showIntro ? null : () => _answer(i), // セリフ中は無効化
                        child: Text(q.$2[i]),
                      ),
                      if (i < 2) const SizedBox(height: 25),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                const Icon(Icons.local_fire_department,
                    color: Colors.orange, size: 48),
              ],
            ),
          ),

          // ─── セリフオーバーレイ ─────────────────────
          if (_showIntro)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _nextIntro,
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
                    _introLines[_introIndex],
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
