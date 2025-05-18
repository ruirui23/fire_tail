// lib/screens/choose_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/hinoarashi.dart';
import '../models/result.dart';

class ChooseScreen extends StatefulWidget {
  const ChooseScreen({Key? key}) : super(key: key);

  @override
  State<ChooseScreen> createState() => _ChooseScreenState();
}

class _ChooseScreenState extends State<ChooseScreen> {
  int _step = 0;
  final List<int> _answers = [-1, -1, -1];

 

  // 質問データ
  final List<Map<String, dynamic>> _questions = [
    {
      'text': '第1問！目の前で子供が泣いておる。次のうち君のとる行動はなんじゃ？',
      'options': ['心配になり話しかける', '無視する', 'つられて泣いてしまう'],
    },
    {
      'text': '第2問！家に泥棒が入ってきてしまった。次のうち君のとる行動はなんじゃ？',
      'options': ['警察を呼ぶ', 'こっそり窓から逃げる', '泥棒に立ち向かう'],
    },
    {
      'text': '第3問！信頼していた者に裏切られた。君はどうする？',
      'options': ['事情を受け入れる', '縁を切る', '復讐を誓う'],
    },
  ];

  void _next() => setState(() => _step++);
  void _answer(int choice) {
    final idx = (_step - 1) ~/ 2;
    _answers[idx] = choice;
    setState(() => _step++);
  }

  @override
  Widget build(BuildContext context) {
    // ■ ステップ0：オープニング（画面全体タップで進む）
    if (_step == 0) {
      return Scaffold(
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _next,
          child: Center(
            child: _dialogueBox(
              'では、君と相性の良い子を見つけるために3つ質問をするからよく考えて答えておくれ',
            ),
          ),
        ),
      );
    }

    // 以降は通常のレイアウト
    final revealStart = _questions.length * 2 + 3;
    Widget content;

    if (_step <= _questions.length * 2) {
      // ■ 質問フェーズ
      final qIdx = (_step - 1) ~/ 2;
      if (_step.isOdd) {
        // 質問文＋選択肢ボタン
        final q = _questions[qIdx];
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogueBox(q['text'] as String),
            const SizedBox(height: 16),
            for (int i = 0; i < (q['options'] as List<String>).length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ElevatedButton(
                  onPressed: () => _answer(i),
                  child: Text((q['options'] as List<String>)[i]),
                ),
              ),
          ],
        );
      } else {
        // 回答フィードバック
        final choice = _answers[qIdx];
        final label = ['A', 'B', 'C'][choice];
        content = _dialogueBox('主「$label！」', onTap: _next);
      }
    }
    else if (_step == _questions.length * 2 + 1) {
      // ■ 待機メッセージ
      content = _dialogueBox(
        'うむ！では君の旅の相棒を連れてくるから少し待っていておくれ',
        onTap: _next,
      );
    }
    else if (_step == _questions.length * 2 + 2) {
      // ■ ドン演出
      content = _dialogueBox('…ドン！！', onTap: _next);
    }
    else if (_step >= revealStart) {
      // ■ 相棒発表フェーズ
      final chosenId = _answers.last;
      if (_revealIdx == 0) {
        // 最初に相棒を保存
        Provider.of<Result>(context, listen: false).setChosen(chosenId);
      }
      final line = _finalLines[_revealIdx];
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dialogueBox(line, onTap: () {
            setState(() {
              _revealIdx++;
              if (_revealIdx >= _finalLines.length) {
                // 全セリフ終わり → ゲーム画面へ
                context.go('/game', extra: chosenId);
              }
            });
          }),
          if (_revealIdx == 0) ...[
            const SizedBox(height: 16),
            Image.asset(
              Hinorashi.options[chosenId].assetPath,
              width: 400,
              height: 400,
            ),
          ],
        ],
      );
    }
    else {
      content = const SizedBox.shrink();
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: content,
        ),
      ),
    );
  }

  Widget _dialogueBox(String text, {VoidCallback? onTap}) {
    final box = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Text(text, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
    );
    return onTap != null
        ? GestureDetector(onTap: onTap, child: box)
        : box;
  }
}
 // 最終セリフ
  final List<String> _finalLines = [
    'この子が君の相棒じゃ！',
    '（あ…自分で選べるとかじゃないんだ。使えるヒノアラシだといいけど…）',
    '主「ありがとうございます！じゃ早速行ってきます！」',
    'は「うむ！気をつけるんじゃぞ」',
  ];
  int _revealIdx = 0;