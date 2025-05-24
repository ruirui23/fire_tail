import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_mode.dart';
import 'package:fire_tail/data/texts.dart' as txt;
import 'package:flame_audio/flame_audio.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GameMode _mode = GameMode.normal;
  bool _hardUnlocked = false;
  bool _infoUnlocked = false;
  bool _hardInfoUnlocked = false;

  @override
  void initState() {
    super.initState();
    _loadFlags();

    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('homeBGM (online-audio-converter.com).mp3', volume: 0.5);
  }

  @override
  void dispose() {
    FlameAudio.bgm.stop();
    super.dispose();
  }
  
  Future<void> _loadFlags() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _hardUnlocked     = p.getBool('hardUnlocked') ?? false;
      _infoUnlocked     = (p.getBool('end_lose') ?? false) &&
                          (p.getBool('end_win') ?? false) &&
                          (p.getBool('end_secret') ?? false);
      _hardInfoUnlocked = (p.getBool('hard_lose') ?? false) &&
                          (p.getBool('hard_win') ?? false) &&
                          (p.getBool('hard_secret') ?? false);
    });
  }

  /* ───────── 共通UI helpers ───────── */
  void _dialog(String title, String body) => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(child: Text(body)),
          actions: [TextButton(onPressed: Navigator.of(context).pop, child: const Text('閉じる'))],
        ),
      );

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _showCharacters() {
    int idx = 0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => StatefulBuilder(
        builder: (c, set) => AlertDialog(
          title: Text(txt.characters[idx].name),
          content: Text(txt.characters[idx].lines.join('\n')),
          actions: [
            TextButton(
              onPressed: idx > 0 ? () => set(() => idx--) : null,
              child: const Text('戻る'),
            ),
            TextButton(
              onPressed: () {
                if (idx < txt.characters.length - 1) {
                  set(() => idx++);
                } else {
                  Navigator.of(c).pop();
                }
              },
              child: Text(idx < txt.characters.length - 1 ? '次へ' : '閉じる'),
            ),
          ],
        ),
      ),
    );
  }

  /* ───────── build ───────── */
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(children: [
          Positioned.fill(
            child: Image.asset('assets/images/home.png', fit: BoxFit.cover),
          ),

          Positioned(
            bottom: 40,
            left: 800,
            right: 0,
            child: Image.asset(
              'assets/images/red.png', // ヒノアラシ画像
              width: 180,
              height: 180,
            ),
          ),

          Positioned(
            bottom: 40,
            left: 450,
            right: 0,
            child: Image.asset(
              'assets/images/blue.png', // ヒノアラシ画像
              width: 180,
              height: 180,
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 450,
            child: Image.asset(
              'assets/images/green.png', // ヒノアラシ画像
              width: 180,
              height: 180,
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 800,
            child: Image.asset(
              'assets/images/purple.png', // ヒノアラシ画像
              width: 180,
              height: 180,
            ),
          ),

          Positioned(
            left: 10,
            bottom: 360,
            child: Image.asset(
              'assets/images/rogo.png',
              width: 330,
              height: 330,
            ),
          ),
          /* 右上ボタン列 */
          Positioned(
            top: 16,
            right: 16,
            child: Column(children: [
              _btn('ゲーム説明', true, () => _dialog('ゲーム説明', txt.gameInfo)),
              const SizedBox(height: 8),
              _btn('ノーマルストーリー', _infoUnlocked,
                  () => _dialog('FireTail ストーリー', txt.normalStory),
                  lock: 'ノーマル３種クリアで解放！'),
              const SizedBox(height: 8),
              _btn('登場人物', _infoUnlocked, _showCharacters,
                  lock: 'ノーマル３種クリアで解放！'),
              const SizedBox(height: 8),
              _btn('ハードストーリー', _hardInfoUnlocked,
                  () => _dialog('ハードストーリー', txt.hardStory),
                  lock: 'ハード３種クリアで解放！'),
              const SizedBox(height: 8),
              _btn('裏設定', _hardInfoUnlocked,
                  () => _dialog('裏設定', txt.hiddenInfo),
                  lock: 'ハード３種クリアで解放！'),
            ]),
          ),
          /* 中央 START & 難易度 */
          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              GestureDetector(
                onTap: () {
                  FlameAudio.play('startbutton.mp3');
                  Future.delayed(const Duration(milliseconds: 100), () {
                   context.go('/choose', extra: _mode);
                });
            },
                child: Image.asset('assets/images/start.png', width: 250),
              ),
              const SizedBox(height: 40),
              Row(mainAxisSize: MainAxisSize.min, children: [
                _modeBtn('ノーマル', GameMode.normal, Colors.deepOrange),
                const SizedBox(height: 20),
                _modeBtn('ハード', GameMode.hard, Colors.redAccent),
                const SizedBox(height: 20),
              ]),
            ]),
          ),
        ]),
      );

  /* ───────── サブwidget ───────── */
  Widget _btn(String lbl, bool en, VoidCallback tap, {String lock = '未解放'}) =>
      ElevatedButton(
        onPressed: en ? tap : () => _snack(lock),
        style: en ? null : ElevatedButton.styleFrom(backgroundColor: Colors.grey),
        child: Text(lbl),
      );

 Widget _modeBtn(String lbl, GameMode gm, Color active) {
  final locked = gm == GameMode.hard && !_hardUnlocked;
  return ElevatedButton(
    onPressed: locked
        ? () => _snack('まずノーマルで勝ち or シークレットを達成してハードを解放！')
        : () => setState(() => _mode = gm),
    style: ElevatedButton.styleFrom(
      // 横幅は内容に応じ可変。最低でも 120px 取るとまず改行しません
      minimumSize: const Size(120, 48),
      backgroundColor: locked
          ? Colors.grey
          : (_mode == gm ? active : Colors.grey[300]),
      foregroundColor:
          locked ? Colors.black45 : (_mode == gm ? Colors.white : Colors.black),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    ),
    child: Text(
      lbl,
      style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
