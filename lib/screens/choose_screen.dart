import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/hinoarashi.dart';
import '../models/game_mode.dart';
import '../models/result.dart';

class ChooseScreen extends StatefulWidget {
  final GameMode mode;
  const ChooseScreen({Key? key, required this.mode}) : super(key: key);

  @override
  State<ChooseScreen> createState() => _ChooseScreenState();
}

class _ChooseScreenState extends State<ChooseScreen> {
  /* ───────── ステップ管理 ─────────
     -1 : 主人公名入力
      0 : モード別オープニング
      1 : 「では質問を…」
      2〜 : 質問フェーズ … */
  int _step = -1;

  // ------------- 主人公名 -------------
  final TextEditingController _nameCtrl = TextEditingController();
  String _playerName = '主';

  // ------------- 質問／回答 -------------
  final List<int> _answers = [-1, -1, -1];
  final List<Map<String, dynamic>> _questions = [
    {
      'text':
          '第1問！目の前で子供が泣いておる。次のうち君のとる行動はなんじゃ？',
      'options': ['A.心配になり話しかける', 'B.無視する', 'C.つられて泣いてしまう'],
    },
    {
      'text':
          '第2問！家に泥棒が入ってきてしまった。次のうち君のとる行動はなんじゃ？',
      'options': ['A.警察を呼ぶ', 'B.こっそり窓から逃げる', 'C.泥棒に立ち向かう'],
    },
    {
      'text': '第3問！信頼していた者に裏切られた。君はどうする？',
      'options': ['A.事情を受け入れる', 'B.縁を切る', 'C.復讐を誓う'],
    },
  ];

  // 質問後のセリフ
  final List<String> _finalLines = [
    'この子が君の相棒じゃ！',
    '（あ…自分で選べるとかじゃないんだ。使えるヒノアラシだといいけど…）',
    '主「ありがとうございます！じゃ早速行ってきます！」',
    'は「うむ！気をつけるんじゃぞ」',
  ];
  int _revealIdx = 0;

  /* ───────── ヘルパー ───────── */
  void _next() => setState(() => _step++);
  void _answer(int choice) {
    final idx = (_step - 2) ~/ 2; // 質問は step 2 から
    _answers[idx] = choice;
    setState(() => _step++);
  }
  String _rp(String s) => s.replaceAll('主', _playerName);

  /* ───────── ビルド ───────── */
  @override
  Widget build(BuildContext context) {
    // (1) 名前入力
    if (_step == -1) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('主人公の名前を入力してください',
                    style: TextStyle(fontSize: 20)),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '名前を入力',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _playerName =
                        _nameCtrl.text.trim().isEmpty ? '主' : _nameCtrl.text;
                    context.read<Result>().setPlayerName(_playerName);
                    _next();
                  },
                  child: const Text('決定'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // (2) モード別のオープニングセリフ
    if (_step == 0) {
      final line = _rp(_openingLines[widget.mode]!);
      return _oneLineScene(line, onTap: _next);
    }

    // (3) 質問開始前の定型セリフ
    if (_step == 1) {
      return _oneLineScene(
        'では、君と相性の良い子を見つけるために3つ質問をするからよく考えて答えておくれ',
        onTap: _next,
      );
    }

    // (4) 質問フェーズ
    final revealStart = _questions.length * 2 + 3; // 質問 3*2 + 3 で 9
    late Widget content;

    if (_step >= 2 && _step <= _questions.length * 2 + 1) {
      final qIdx = (_step - 2) ~/ 2;
      if (_step.isEven) {
        // 質問文
        final q = _questions[qIdx];
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogueBox(_rp(q['text'] as String)),
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
        // 答えを叫ぶ
        final choice = _answers[qIdx];
        final label = ['A', 'B', 'C'][choice];
        content = _dialogueBox(_rp('主「$label！」'), onTap: _next);
      }
    } else if (_step == _questions.length * 2 + 2) {
      content = _dialogueBox(
        'は「うむ！では君の旅の相棒を連れてくるから少し待っていておくれ」',
        onTap: _next,
      );
    } else if (_step == _questions.length * 2 + 3) {
      content = _dialogueBox('…ドン！！', onTap: _next);
    } else if (_step >= revealStart) {
      final chosenId = _answers.last;
      if (_revealIdx == 0) {
        context.read<Result>().setChosen(chosenId);
      }
      final line = _rp(_finalLines[_revealIdx]);
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dialogueBox(line, onTap: () {
            setState(() {
              _revealIdx++;
              if (_revealIdx >= _finalLines.length) {
                context.go(
                  '/game',
                  extra: {'mode': widget.mode, 'id': chosenId},
                );
              }
            });
          }),
          if (_revealIdx == 0) ...[
            const SizedBox(height: 16),
            Image.asset(
              Hinorashi.options[chosenId].assetPath,
              width: 200,
              height: 200,
            ),
          ],
        ],
      );
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

  /* ───────── 汎用UI ───────── */
  Widget _oneLineScene(String text, {VoidCallback? onTap}) =>
      Scaffold(body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(child: _dialogueBox(text)),
      ));

  Widget _dialogueBox(String text, {VoidCallback? onTap}) {
    final box = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Text(text,
          style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
    );
    return onTap != null ? GestureDetector(onTap: onTap, child: box) : box;
  }
}

/* ───────── モード別オープニングセリフ ───────── */
const _openingLines = <GameMode, String>{
  GameMode.normal: 'は「はかせ」',
  GameMode.hard: 'は「ははかかせせ」',
};
