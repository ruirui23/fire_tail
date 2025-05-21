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
  late final List<String> _introLines;
  int _introIdx = 0;
  bool _showIntro = true;

  late final List<(_Question, List<String>, int)> _qs;
  int _idx = 0, _correct = 0;

  @override
  void initState() {
    super.initState();
    _introLines = _introPreset[widget.mode]!
        .map((l) => l.replaceAll('主', context.read<Result>().playerName))
        .toList();

    if (widget.mode == GameMode.normal) {
      _qs = [
        (_Question('ほのおタイプの弱点は？'), ['みず', 'くさ', 'ほのお'], 0),
        (_Question('ヒノアラシの体重はおよそ何kg？'), ['5.3kg', '6.5kg', '7.9kg'], 2),
        (_Question('ヒノアラシの第１進化はどれ？'), ['バクフーン', 'マグカルゴ', 'マグマラシ'], 2),
        (_Question('ヒノアラシの英語名はどれ？'), ['Cyndaquil', 'Quilava', 'Typhlosion'], 0),
        (_Question('ヒノアラシの分類名称「○○ポケモン」の○○は？'), ['ひねずみ', 'ほのお', 'かえん'], 0),
      ];
    } else {
      _qs = [
        (_Question('ほのおタイプの弱点は？'), ['こおり', 'エスパー', 'いわ', 'でんき', 'あく'], 2),
        (_Question('ヒノアラシの全国図鑑番号は？'), ['154', '155', '156', '157', '158'], 1),
        (_Question('ヒノアラシの第２進化はどれ？'), ['バクフーン', 'マグマラシ', 'カエンジシ', 'テッポウオ', 'ホルビー'], 0),
        (_Question('マグマラシの英語名はどれ？'), ['Cyndaquil', 'Typhlosion', 'volcano', 'Magmar', 'Quilava'], 4),
        (_Question('マグマラシの分類名称「○○ポケモン」は？'), ['ひねずみ', 'まぐまねずみ', 'マグマ', 'かざん', 'かえん'], 3),
      ];
    }
  }

  void _answer(int choice) {
    if (choice == _qs[_idx].$3) _correct++;
    if (++_idx >= _qs.length) {
      context.read<Result>().setQuizCorrect(_correct);
      context.go('/ending', extra: widget.mode);
    } else {
      setState(() {});
    }
  }

  void _nextIntro() {
    setState(() {
      _introIdx++;
      if (_introIdx >= _introLines.length) _showIntro = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _qs.length, current = _idx + 1;
    final q = _qs[_idx];

    return Scaffold(
      appBar: AppBar(title: Text('クイズ $current/$total')),
      body: Stack(children: [
        Positioned.fill(
          child: Image.asset('assets/images/battle.png', fit: BoxFit.cover),
        ),
        if (!_showIntro)
          Padding(
            padding: const EdgeInsets.all(60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _QuestionText(text: q.$1.text),
                const SizedBox(height: 40),
                for (int i = 0; i < q.$2.length; i++) ...[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 55),
                      backgroundColor: Colors.blue[300],
                      foregroundColor: Colors.white,
                      elevation: 7,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () => _answer(i),
                    child: Text(q.$2[i]),
                  ),
                  if (i < q.$2.length - 1) const SizedBox(height: 25),
                ],
                const SizedBox(height: 20),
                const Icon(Icons.local_fire_department,
                    color: Colors.orange, size: 48),
              ],
            ),
          ),
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
                child: Text(_introLines[_introIdx],
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center),
              ),
            ),
          ),
      ]),
    );
  }
}

/* ───────── モード別イントロ ───────── */
const _introPreset = <GameMode, List<String>>{
  GameMode.normal: [
    '主「やっとたどり着いた…」',
    '主（ここまでの道のり、長かったけど自信はある！）',
    'ヒノアラシが「ひのっ」と可愛く鳴いた',
    '主「よし、行こう！」',
  ],
  GameMode.hard: [
    '主「…れ',
    '主（が',
    'ヒノアラシの',
    'た',
  ],
};

class _QuestionText extends StatelessWidget {
  final String text;
  const _QuestionText({required this.text});
  @override
  Widget build(BuildContext ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text,
            textAlign: TextAlign.center,
            style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                )),
      );
}

class _Question {
  final String text;
  const _Question(this.text);
}
