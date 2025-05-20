// lib/screens/quiz_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/result.dart';
import '../models/game_mode.dart';

class QuizScreen extends StatefulWidget {
  final GameMode mode;
  const QuizScreen({Key? key, required this.mode}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // 冒頭セリフ
  final List<String> _introLines = [
    '主「やっとたどり着いた…」',
    '主（ここに来るまでにかなり体力を使ってしまった…果たして私に勝てるだろうか）',
    '不安な気持ちを察したのかヒノアラシが「ひのっ」と可愛い声で鳴いてくれた',
    '主「よし、行こう！」',
  ];
  int _introIndex = 0;
  bool _showIntro = true;

  // 問題リスト (モード別に initState でセット)
  late final List<(_Question, List<String>, int)> _qs;
  int _idx = 0, _correct = 0;

  @override
  void initState() {
    super.initState();
    if (widget.mode == GameMode.normal) {
      // ノーマル：３択５問
      _qs = [
        (_Question('ほのおタイプの弱点は？'), ['みず', 'くさ', 'ほのお'], 0),
        (_Question('ヒノアラシの体重はおよそ何kg？'), ['5.3kg', '6.5kg', '7.9kg'], 2),
        (_Question('ヒノアラシの第１進化はどれ？'), ['バクフーン', 'マグカルゴ', 'マグマラシ'], 2),
        (_Question('ヒノアラシの英語名はどれ？'), ['Cyndaquil', 'Quilava', 'Typhlosion'], 0),
        (_Question('ヒノアラシの分類名称「○○ポケモン」の○○は？'), ['ひねずみ', 'ほのお', 'かえん'], 0),
      ];
    } else {
      // ハード：5択５問
      _qs = [
        (_Question('ほのおタイプの弱点は？'), ['こおり', 'エスパー', 'いわ', 'でんき','あく'],2),
        (_Question('ヒノアラシの全国図鑑番号は？'), ['154','155', '156', '157', '158'], 1),
        (_Question('ヒノアラシの第２進化はどれ？'), ['バクフーン', 'マグマラシ','カエンジシ', 'テッポウオ', 'ホルビー'], 0),
        (_Question('マグマラシの英語名はどれ？'), ['Cyndaquil','Typhlosion', 'volcano', 'Magmar', 'Quilava'], 4),
        (_Question('マグマラシの分類名称「○○ポケモン」は？'), ['ひねずみ','まぐまねずみ', 'マグマ', 'かざん', 'かえん'], 3),
      ];
    }
  }

  void _answer(int choice) {
    if (choice == _qs[_idx].$3) {
      _correct++;
    }
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
    final total = _qs.length;
    final current = _idx + 1;
    final question = _qs[_idx];

    return Scaffold(
      appBar: AppBar(title: Text('クイズ $current/$total')),
      body: Stack(
        children: [
          // バトル背景
          Positioned.fill(
            child: Image.asset(
              'assets/images/battle.png',
              fit: BoxFit.cover,
            ),
          ),

          // クイズ本体
          Visibility(
            visible: !_showIntro,
            child: Padding(
              padding: const EdgeInsets.all(60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _QuestionText(text: question.$1.text),
                  const SizedBox(height: 40),
                  // モードに応じた選択肢数 (3 or 4)
                  for (int i = 0; i < question.$2.length; i++) ...[
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
                      onPressed: () => _answer(i),
                      child: Text(question.$2[i]),
                    ),
                    if (i < question.$2.length - 1) const SizedBox(height: 25),
                  ],
                  const SizedBox(height: 20),
                  const Icon(Icons.local_fire_department,
                      color: Colors.orange, size: 48),
                ],
              ),
            ),
          ),

          // 冒頭セリフオーバーレイ
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

// 問題テキスト専用ウィジェット
class _QuestionText extends StatelessWidget {
  final String text;
  const _QuestionText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              shadows: const [
                Shadow(
                  blurRadius: 4,
                  color: Colors.black38,
                  offset: Offset(1, 1),
                ),
              ],
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// 問題文字ラッパー
class _Question {
  final String text;
  const _Question(this.text);
}