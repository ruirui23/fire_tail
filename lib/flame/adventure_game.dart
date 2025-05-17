import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'player.dart';
import 'obstacle.dart';
import 'dart:ui'; // Color 用

class AdventureGame extends FlameGame
    with TapCallbacks, HasCollisionDetection {
  AdventureGame({
    required this.chosenId,
    required this.onFinish,
    this.startPaused = false,
  });

  final int chosenId;
  final VoidCallback onFinish;
  final bool startPaused;

int collisionCount = 0;
int spawnCount = 0;
  // 衝突数を取得
  void incrementCollision() {
    collisionCount++;
  }
  late Player _player;
  double _timeLeft = 15; // ゲーム時間
  double _spawn     = 0;
  static const _interval = 1.2;

  @override
  Color backgroundColor() => const Color(0xFFB3E5FC);

  @override
  Future<void> onLoad() async {
    // プレイヤーだけ先に追加し…
    _player = Player(assetPath: _pathForId(chosenId));
    add(_player);
    // セリフ中はゲームを止める
    if (startPaused) {
      pauseEngine();
    }
  }

  @override
  void update(double dt) {
    // セリフ表示中は何もしない
    if (paused) {
      return;
    }
    super.update(dt);
    // タイマー処理
    _timeLeft -= dt;
    if (_timeLeft <= 0) {
      pauseEngine();
      onFinish();
      return;
    }

    // 障害物生成
    _spawn += dt;
      if (_spawn >= _interval && spawnCount < 10) {
      _spawn = 0;
      add(Obstacle());
      spawnCount++;
    }
  }

  @override
  void onTapDown(TapDownEvent _) => _player.jump();

  String _pathForId(int id) => switch (id) {
        0 => 'red.png',
        1 => 'blue.png',
        2 => 'purple.png',
        _ => 'rock.png',
      };
}
