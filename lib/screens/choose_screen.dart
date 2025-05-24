import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/hinoarashi.dart';
import '../models/game_mode.dart';
import '../models/result.dart';
import '../utils/hino_asset.dart';
class ChooseScreen extends StatefulWidget {
  final GameMode mode;
  const ChooseScreen({super.key, required this.mode});

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
  int _revealIdx = 0;

  final List<Map<String, dynamic>> _questions = [
    {
      'text': '第1問！目の前で子供が泣いておる。次のうち君のとる行動はなんじゃ？',
      'options': ['A.心配になり話しかける', 'B.無視する', 'C.つられて泣いてしまう'],
    },
    {
      'text': '第2問！家に泥棒が入ってきてしまった。次のうち君のとる行動はなんじゃ？',
      'options': ['A.警察を呼ぶ', 'B.こっそり窓から逃げる', 'C.泥棒に立ち向かう'],
    },
    {
      'text': '第3問！信頼していた者に裏切られた。君はどうする？',
      'options': ['A.事情を受け入れる', 'B.縁を切る', 'C.復讐を誓う'],
    },
  ];

  final Map<GameMode, List<String>> _openingLines = {
    GameMode.normal: [
      'コンコン（ドアを叩く音）',
      '主「博士〜ヒノアラシを貰いに来たんだけどいる？」',
      'ドタドタ（階段をおりる音）',
      '博士 「おぉ、よく来たのぉ、よく来たのぉ。今日で20歳か、あんなに小さかったのに、時間の流れは早いものじゃな」',
      '主「もぉ！いつの話してるの博士」',
      '主「そういう博士は全然変わってないね」',
      '私の住む『ヒノアラシ村』は成人すると自分に合うヒノアラシを連れてジムリーダーを倒す旅に出ないといけないらしい',
      '今年から始まったことらしくこの試練を乗り越えると成人として正式に認められる',
      '博士 「優しいのぉ、これでも今年で95歳なんじゃよ」',
      '博士 「よしそろそろヒノアラシをあげようかのお」',
    ],
    GameMode.hard: [
      'コンコン（ドアを叩く音）',
      '主「こんにちは〜ヒノアラシを選びに来たんですけど博士はいますか？」',
      '助手「こんにちは、お名前をお伺いしても宜しいですか？」',
      '主「主です」',
      '助手「主さんですね」',
      '助手「博士は2階にいらっしゃいます。あちらの階段から上がってください」',
      '私の住む村は『ヒノアラシ村』と言って成人すると自分に合うヒノアラシを連れて旅に出るという少し変わった村だ',
      '（ジムリーダーを倒さないと村に帰れないなんて…最悪だ正直全然乗り気じゃない早く終わらせよう）',
      '2階に到着',
    ],
  };

  final Map<GameMode, List<String>> _finalLines = {
    GameMode.normal: [
      '博士「この子が君の相棒じゃ！」',
      '主「ありがとう、すごく可愛い！」',
      '博士「うむ！この子と一緒に頑張るんじゃぞ、私が死ぬまでには帰ってきておくれ」',
      '主「もう、縁起でもないこと言わないでよ…じゃ行ってきます！」',
    ],
    GameMode.hard: [
      '博士「この子が君の相棒じゃ！」',
      '主（あ…自分で選べるとかじゃないんだ。使えるヒノアラシだといいけど…）',
      '主「ありがとうございます！じゃ早速行ってきます！」',
      '博士「うむ！気をつけるんじゃぞ。帰ったらアニスがおるからその子に話しかけておくれ」',
      '主（アニス？あーあの助手の人、そういえばそんな名前だったっけ）',
    ],
  };

  void _next() => setState(() => _step++);

  void _answer(int choice) {
    final idx = (_step - 2) ~/ 2;
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
                const Text('主人公の名前を入力してください', style: TextStyle(fontSize: 20)),
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

    Widget content = const SizedBox.shrink();

    if (_step == 0) {
      int openingLineIndex = 0;
      final lines = _openingLines[widget.mode]!;
      content = StatefulBuilder(
        builder: (context, setState) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (openingLineIndex < lines.length - 1) {
                setState(() {
                  openingLineIndex++;
                });
              } else {
                _next();
              }
            },
            child:
                _oneLineScene(_rp(lines[openingLineIndex]), noScaffold: true),
          );
        },
      );
    } else if (_step == 1) {
      content = _oneLineScene(
        'では、君と相性の良い子を見つけるために3つ質問をするからよく考えて答えておくれ',
        onTap: _next,
        noScaffold: true,
      );
    } else {
      final revealStart = _questions.length * 2 + 3;
      if (_step >= 2 && _step <= _questions.length * 2 + 1) {
        final qIdx = (_step - 2) ~/ 2;
        if (_step.isEven) {
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
          final choice = _answers[qIdx];
          final label = ['A', 'B', 'C'][choice];
          content = _dialogueBox(_rp('主「$label！」'), onTap: _next);
        }
      } else if (_step == _questions.length * 2 + 2) {
        content =
            _dialogueBox('博士「うむ！では君の旅の相棒を連れてくるから少し待っていておくれ」', onTap: _next);
      } else if (_step == _questions.length * 2 + 3) {
        content = _dialogueBox('…ドン！！', onTap: _next);
      } else if (_step >= revealStart) {
        final chosenId = _answers.last;
        if (_revealIdx == 0) {
          context.read<Result>().setChosen(chosenId);
        }
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatefulBuilder(
              builder: (context, setState) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      _revealIdx++;
                      if (_revealIdx >= _finalLines[widget.mode]!.length) {
                        context.go('/game',
                            extra: {'mode': widget.mode, 'id': chosenId});
                        return;
                      }
                    });
                  },
                  child: _oneLineScene(
                      _rp(_finalLines[widget.mode]![_revealIdx]),
                      noScaffold: true),
                );
              },
            ),
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
 chosenId == 2                     // 2＝シークレットを選んだ時だけ
    ? secretHinorashiAsset(widget.mode)
    : Hinorashi.options[chosenId].assetPath,
  width: 200,
  height: 200,
            ),
          ],
        ],
      );

    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Lab.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: content,
            ),
          ),
        ],
      ),
    );
  }

  Widget _oneLineScene(String text,
      {VoidCallback? onTap, bool noScaffold = false}) {
    final child = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(child: _dialogueBox(text)),
    );
    return noScaffold ? child : Scaffold(body: child);
  }

  Widget _dialogueBox(String text, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
