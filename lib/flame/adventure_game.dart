//Flameエンジンを使ったゲーム全体の制御プログラム（ゲーム開始・停止・描画・更新）
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flame/events.dart';
import 'player.dart';
import 'obstacle.dart';

class AdventureGame extends FlameGame
    with TapDetector, HasCollisionDetection {
  AdventureGame({required this.chosenId, required this.onFinish});
  final int chosenId;          // 0–2
  final VoidCallback onFinish;

  late Player _player;
  double _t = 10;              // 耐久 10 秒
  double _spawn = 0;
  static const _int = 1.2;     // 障害物間隔

  @override
  Future<void> onLoad() async {
   // camera.viewport = FixedResolutionViewport(Vector2(480, 320));
    _player = Player(assetPath: _pathForId(chosenId));
    add(_player);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _t -= dt;
    if (_t <= 0) { pauseEngine(); onFinish(); }

    _spawn += dt;
    if (_spawn >= _int) {
      _spawn = 0;
      add(Obstacle());
    }
  }

  @override
  void onTapDown(TapDownInfo _) => _player.jump();

 /// assets/ と images/ は 1 回だけ書く！
/// （Flame が自動で assets/ を先頭に付ける）
String _pathForId(int id) => switch (id) {
  0 => 'hinoarashi1.jpg',   // ← 実ファイル名と拡張子を正確に
  1 => 'hinoarashi2.jpg',
  2 => 'tyebu.png',         // ← ディレクトリで確認した名前
  _ => 'tyebuo.png',
};
}
