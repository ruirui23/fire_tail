import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_mode.dart';
import 'package:fire_tail/data/texts.dart' as txt;

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
                onTap: () => context.go('/choose', extra: _mode),
                child: Image.asset('assets/images/start.png', width: 300),
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
