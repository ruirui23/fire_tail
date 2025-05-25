import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flame_audio/flame_audio.dart';

import '../models/game_mode.dart';
import '../data/texts.dart' as txt;

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
    FlameAudio.bgm.play('homeBGM (online-audio-converter.com).mp3',
        volume: 0.5);
  }

  @override
  void dispose() {
    FlameAudio.bgm.stop();
    super.dispose();
  }

  Future<void> _loadFlags() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _hardUnlocked = p.getBool('hardUnlocked') ?? false;
      _infoUnlocked = (p.getBool('end_lose') ?? false) &&
          (p.getBool('end_win') ?? false) &&
          (p.getBool('end_secret') ?? false);
      _hardInfoUnlocked = (p.getBool('hard_lose') ?? false) &&
          (p.getBool('hard_win') ?? false) &&
          (p.getBool('hard_secret') ?? false);
    });
  }

  void _dialog(String title, String body) => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(child: Text(body)),
          actions: [
            TextButton(
                onPressed: Navigator.of(context).pop, child: const Text('閉じる'))
          ],
        ),
      );

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _showCharacters() {
    int idx = 0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => StatefulBuilder(builder: (c, set) {
        final chr = txt.characters[idx];
        return AlertDialog(
          title: Text(chr.name),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(chr.lines.join('\n'))),
              const SizedBox(width: 16),
              Image.asset(chr.assetPath, width: 80, height: 80),
            ],
          ),
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
        );
      }),
    );
  }

  Widget _btn(String lbl, bool enabled, VoidCallback onTap,
          {String lock = '未解放'}) =>
      ElevatedButton(
        onPressed: enabled ? onTap : () => _snack(lock),
        style: enabled
            ? null
            : ElevatedButton.styleFrom(backgroundColor: Colors.grey),
        child: Text(lbl),
      );

  Widget _modeBtn(String lbl, GameMode gm, Color activeColor) {
    final locked = gm == GameMode.hard && !_hardUnlocked;
    return ElevatedButton(
      onPressed: locked
          ? () => _snack(
              'まずノーマルで勝ち or シークレットを達成してハードを解放！')
          : () => setState(() => _mode = gm),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(120, 48),
        backgroundColor: locked
            ? Colors.grey
            : (_mode == gm ? activeColor : Colors.grey[300]),
        foregroundColor:
            locked ? Colors.black45 : (_mode == gm ? Colors.white : Colors.black),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      child: Text(lbl, style: const TextStyle(fontSize: 18)),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(children: [
          Positioned.fill(
            child: Image.asset('assets/images/home.png', fit: BoxFit.cover),
          ),
          // ヒノアラシ群
          // *purpleのみシークレット、green以外３体を配置する例
          Positioned(
            bottom: 40,
            left: 800,
            right: 0,
            child: Image.asset(
              'assets/images/red.png', // ヒノアラシ画像
              width: 200,
              height: 200,
            ),
          ),

          Positioned(
            bottom: 40,
            left: 420,
            right: 0,
            child: Image.asset(
              'assets/images/blue.png', // ヒノアラシ画像
              width: 200,
              height: 200,
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 420,
            child: Image.asset(
              'assets/images/green.png', // ヒノアラシ画像
              width: 200,
              height: 200,
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 800,
            child: Image.asset(
              'assets/images/purple.png', // ヒノアラシ画像
              width: 200,
              height: 200,
            ),
          ),

          Positioned(
  bottom: 500,
  left: 0,
  right: 0,
  child: Center(
    child: Image.asset(
      'assets/images/rogo.png',
      width: 400,
      height: 400,
    ),
  ),
),
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

          // 中央 START & 難易度選択
          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              GestureDetector(
                onTap: () {
                  FlameAudio.play('assets/startbutton.mp3');
                  Future.delayed(const Duration(milliseconds: 100), () {
                    context.go('/choose', extra: _mode);
                  });
                },
                child: Image.asset('assets/images/start.png', width: 250),
              ),
              const SizedBox(height: 40),
              Row(mainAxisSize: MainAxisSize.min, children: [
                _modeBtn('ノーマル', GameMode.normal, Colors.deepOrange),
                const SizedBox(width: 20),
                _modeBtn('ハード', GameMode.hard, Colors.redAccent),
              ]),
            ]),
          ),
        ]),
      );
}