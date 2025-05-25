import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/result.dart';
import '../models/game_mode.dart';

class EndingScreen extends StatefulWidget {
  const EndingScreen({super.key});
  @override
  State<EndingScreen> createState() => _EndingScreenState();
}

class _EndingScreenState extends State<EndingScreen> {
  late List<String> _lines;
  int  _idx    = 0;
  bool _inited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;

    final r    = context.read<Result>();
    final mode = GoRouterState.of(context).extra as GameMode? ?? GameMode.normal;

    /* ───── エンディング種別判定 ───── */
    String key;
    if (r.collisions == 0 && r.quizCorrect == 5 && r.chosenId == 2) {
      key = 'evolution';                           // シークレット
    } else if (r.collisions <= 8 && r.quizCorrect >= 2) {
      key = 'win';                                 // 勝ち
    } else {
      key = 'lose';                                // 負け
    }

    _saveFlags(mode, key);

    _lines = _endPreset[mode]![key]!
        .map((s) => s.replaceAll('主', r.playerName))
        .toList();

    _inited = true;
  }

  /* ───────── フラグ保存 ───────── */
  Future<void> _saveFlags(GameMode mode, String key) async {
    final p = await SharedPreferences.getInstance();
    if (mode == GameMode.normal) {
      if (key == 'lose')       p.setBool('end_lose',   true);
      if (key == 'win')        p.setBool('end_win',    true);
      if (key == 'evolution')  p.setBool('end_secret', true);
      if (key == 'win' || key == 'evolution') {
        p.setBool('hardUnlocked', true);             // ハード解放
      }
    } else {
      if (key == 'lose')       p.setBool('hard_lose',   true);
      if (key == 'win')        p.setBool('hard_win',    true);
      if (key == 'evolution')  p.setBool('hard_secret', true);
    }
  }

  /* ───────── 背景ウィジェット ─────────
     1) hinoarashimura.png
     2) hinoarashi.png
     3) グレー
  */



int _bgType = 0;
void _next() {
  setState(() {
    _idx++;


    // 背景変更条件
    if (_idx < _lines.length) {
      final line = _lines[_idx];

      if (line.contains('ただいま')) {
        _bgType = 1; // 村背景
      }
       if (line.contains('村の宴')) {
        _bgType = 2; 
      }
       if (line.contains('庭先')) {
        _bgType = 3; 
      }
      if (line.contains('研究所全体')) {
        _bgType = 4; // 研究所背景炎上
      }
      if (line.contains('お久しぶり')) {
        _bgType = 5; // 研究所背景
      }
      if (line.contains('うっ……')|| line.contains('ふぅ〜')|| line.contains('〜バッドエンド（研究所の闇）〜')) {
        _bgType = 6; // 暗転
      }
      if (line.contains('目が覚めたかい？')) {
        _bgType = 7; 
      }

    }

  });
}
Widget _background() {
  String imagePath;

  switch (_bgType) {
    case 1:
      imagePath = 'assets/images/hionoarashimura.png'; 
      break;
    case 2:
      imagePath = 'assets/images/utage.png'; 
      break;
    case 3:
      imagePath = 'assets/images/anisu.png'; 
      break;
    case 4:
      imagePath = 'assets/images/hakase.png'; 
      break;
    case 5:
      imagePath = 'assets/images/hakase2.png'; 
      break;
    case 6:
      imagePath = 'assets/images/kuro.png'; 
      break;
    case 7:
      imagePath = 'assets/images/chika.png'; 
      break;
    default:
      imagePath = 'assets/images/battle.png'; 
  }

  return Positioned.fill(
    child: Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
    ),
  );
}


/* ───────── UI ───────── */

@override
Widget build(BuildContext context) {
  final r = context.watch<Result>();

  /* ── セリフパート ── */
  if (_idx < _lines.length) {
    return Scaffold(
        body: Stack(children: [
          _background(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _next,
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _lines[_idx],
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ]),
      );
    }

    /* ── スコアカード ── */
    return Scaffold(
      appBar: AppBar(title: const Text('エンドロール')),
      body: Stack(children: [
        _background(),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Card(
                color: Colors.white.withOpacity(0.9),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: 24),
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text('クイズ正解数: '),
                      Text('${r.quizCorrect}/5',
                          style: const TextStyle(
                              fontSize: 24, color: Colors.blue)),
                    ]),
                    const SizedBox(height: 16),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text('当たった障害物: '),
                      Text('${r.collisions}/10',
                          style: const TextStyle(
                              fontSize: 24, color: Colors.red)),
                    ]),
                  ]),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.replay),
                label: const Text('もう一度遊ぶ'),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

/* ───────── エンディング文テーブル ───────── */
const _endPreset = <GameMode, Map<String, List<String>>>{
  GameMode.normal: {
    'win': [
     '主「よし！何とか倒したぞ…」',
     'これで村に帰れる！」',
      '（大切な相棒と軽い足取りで帰路に着いた）',
      '主「ただいま〜！」',
      'アニス「１ヶ月ぶりね、ジムリーダーは倒せたの？」',
      '主「うん！なんとか勝つことができたよ！」',
      'アニス「良かったじゃない！これであなたあなたも成人ね、今日は飲むわよ〜！」',
      '村の宴は一晩中続き久々に村の仲間と語り合った',
      '主「いや〜それでね、急に岩が落ちてきたんだよ！」',
      '村人A「それは大変だったな、まぁ飲んで飲んで今夜はパーッとやろう！ワハハハハッ」',
      'ヒノアラシは体力回復のために博士の研究所にいる',
      '主（明日にでも様子を見に行ってみよう）',
      '～ハッピーエンド～',

    ],
    'lose': [
      '主「うう…負けちゃった、これじゃ村に帰れないよ」',
      '主「「とりあえず報告だけしに行こう」',
      'ボロボロのヒノアラシを抱え私たちは帰路に着いた',
      '主「ただいま…」',
      'アニス「１ヶ月ぶりね、ジムリーダーは倒せたの？」',
      '主「ううん負けちゃった……」',
      'アニス「そう…それは残念ね」',
      '主「でも、本当にあと少しだったの！また挑戦してくるよ」',
      'アニス「いや…その必要は多分ないわ」',
      '主「え？でもジムリーダーを倒さないと成人って認められないんでしょ？」',
      'アニス「あなたは知らなかったのだろうけどチャンスは１回しかないのよ」',
      '主「そんな…じゃあ私はどうなるの？」',
      'アニス「……村の住人では居られなくでしょうね」',
      '主「追放ってこと…？そんなの酷すぎるよ！」',
      'アニス「ごめんね私にはどうすることも…」',
      '博士「そうかそうか失敗したのか、仕方ないのう君は私の実験体になってもらおうかのう」',
      '主「うっ……」',
      '博士の言葉を聞いたあと私は深い眠りについた',
      'そのあとのことは覚えていない',

      '〜バッドエンド（村からの追放？）〜'

    ],
    'evolution': [
      '主「？！なんで急に姿が変わったんだろう？でも勝てたから良いよね」',
      '私は姿の変わってしまった相棒と帰路に着いた',
      '主「？！急に姿が変わった…勝ちは勝ちだ、帰ろう！」',
      '（姿の変わった相棒と帰路に着いた）',
      '主「ただいま〜！」',
      'アニス「１ヶ月ぶりね、ジムリーダーは倒せっ…!?」',
      '主「あぁこの子？バトル中に急に姿が変わっちゃったんだよね」',
      'アニス「びっくりした〜そういう事ね、それは進化って言ってヒノアラシがマグマラシに進化したのよ」',
      '主「マグマラシって言うんだ！可愛い〜」',
      'アニス「ここで話すのもなんだしうちの家で色々話聞かせてよ」',
      '主「うん行く行く〜」',
      '庭先にはポピーが咲いており手入れが行き届いた綺麗な家だ',
      '主「おじゃましま〜す」',
      '主（ラベンダーの良い香りがする）',
      'アニス「そうそうあなたが旅に行ってる間に隣の家で子供が生まれたのよ」',
      '主「へ〜明日にでも会いに行ってみようかな」',
      '~~~~~~~~~~~~~~',
      'アニスと話をしているとすっかり夜になってしまった',
      '主「もう遅いしそろそろ帰ろるよ」',
      'アニス「そうね、あとそのマグマラシを博士のところに預けてから帰ってね、疲れてるみたいだから」',
      '主「ほんとだ、疲れて寝ちゃったのかな？」',
      '主「じゃ、また明日〜！」',
      '"バタン"',
      'アニス「……」',
      'アニス「ふぅ〜危なかったわ」',
      'アニス「進化して記憶が戻ってたらどうしようかと思ったけどすぐ眠ってくれて助かったわ…」',
      'アニス「あのマグマラシは処分ね」',
      'アニス「補充は……あの子にするとして、博士に伝えておきましょうか」',
      '〜シークレットエンド〜',

    ],
  },
  GameMode.hard: {
    'win': [
       '主「よし！何とか倒したぞ…これで村に帰れる！」',
      '（大切な相棒と軽い足取りで帰路に着いた）',
      '主「ただいま〜！」',
      'アニス「１ヶ月ぶりね、ジムリーダーは倒せたの？」',
      '主「うん！なんとか勝つことができたよ！」'
      '主「ただいま戻りました！」',
      '助手（アニス）「１ヶ月ぶりですね、ジムリーダーは倒せましたか？」',
      '主「はい！なんとか勝つことが出来ました！」',
      '助手（アニス）「おめでとうございます！これで立派な大人ですね」',
      '主（そういえば私以外にこの試練を乗り越えた人はいるのかな？ちょうど10年前に始まった風習らしいけど）',
      'そんなことを思っていると涙を流した母が後ろに立っていた',
      '母「ッ……良かったわ…グスッ……本当にッ……」',
      '主「も〜大袈裟だよ」',
      '無事に帰った私はその日、村人たちに祝われながら楽しい時を過ごした',
      '一緒に帰ったはずのヒノアラシはいつの間にか博士が研究所に連れていったらしい。',
      'これからも一緒に過ごしたかったのに少し残念だな…',
      'そういえばヒノアラシ村なのになんで研究所以外にヒノアラシが居ないんだろう……',
      'まあ、そんなこと気にしなくてもいいか',
      '〜ハッピーエンド（？）〜',

    ],
    'lose': [
      '主「くそっ…なんでだよ！帰れないじゃないか…」',
      '（ボロボロのヒノアラシに冷たい視線を送り帰路に着いた）'
      '主「ただいま戻りました……」',
      '助手（アニス）「１ヶ月ぶりですね、ジムリーダーは倒せましたか？」',
      '主「いえ、敗れてしまいました…」',
      '助手（アニス）「そうですか…それは残念でしたね」',
      '主「でも、本当にあと少しだったんです！また挑戦してきます！」',
      '助手（アニス）「いえ…その必要はありません」',
      '主「え？でも試練を乗り越えないと帰れないんじゃ」',
      '助手（アニス）「この村の試練は1回しかチャンスがないんです」',
      '主「そんな…」',
      '博士「おや、帰ったのかい？」',
      '主「博士…うっ……」',
      '急に口を布で覆われ視界がぼやけ始めた',
      '気がつくと真っ白な部屋の中にいた',
      '実験台に固定され体の自由がきかない',
      '博士「目が覚めたかい？」',
      '博士は手に緑色の液体が入った注射器を持ちながら近づいてくる',
      '博士「君が外に出れるのは次の子が旅に出る時かな」',
      '主（どういうことだ…博士が何を言っているのか理解できない）',
     '博士の焦点のあっていない目を見つめながら私は意識を手放した',
      '〜バッドエンド（研究所の闇）〜',


    ],
    'evolution': [
     '主「？！急に姿が変わった…勝ちは勝ちだ、帰ろう！」',
     '（姿の変わった相棒と帰路に着いた）',
     '主「お久しぶりです！今戻りました！」',
     '助手（アニス）「１ヶ月ぶりですね、ジムリーダーは倒せまし……っ？！」',
     '主「あぁこの子ですか、急に姿が変わってしまって」',
     '助手（アニス）「それは進化って言ってヒノアラシがマグマラシに進化したのでしょう」',
     '主「そうなんですね！可愛い〜」',
     '助手（アニス）「と、とりあえずその子を研究所の2階に上げましょう！」',
     '助手（アニス）「つ、疲れてるみたいですし…治療しますので！」'
     '主（ん？何をそんなに焦っているんだ？）',
     '助手（アニス）「さあ、早く…っ」',
     'アニスがマグマラシに触れた瞬間マグマラシが体から紫色の炎を放った',
     'アニスが炎に包まれ、研究所全体も飲み込んでいく',
     '何とか研究所から出た私は目を疑った',
     '主「なんで…まだ生きているんだ？」',
     'アニスは皮膚がただれ眼球が浮き上がり始めてもなお、マグマラシを振り払おうとしている',
     '博士も慌てて降りてきて、マグマラシを捕まえようとしている',
     '私はこの異様な光景をただ眺めることしか出来なかった',
     '〜シークレットエンド（復讐）〜',




    ],
  },
};
