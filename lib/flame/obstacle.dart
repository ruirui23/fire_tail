import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/foundation.dart'; // debugPrint 用

class Obstacle extends SpriteComponent
    with CollisionCallbacks, HasGameRef {
  static const double speed = 800.0;

  @override
  Future<void> onLoad() async {
    // ── スプライト読み込み ──────────────────────────────
    try {
      sprite = await Sprite.load('rock.png');
      debugPrint('✅ Obstacle sprite loaded');
    } catch (e) {
      debugPrint('❌ Failed to load rock.png: $e');

    }

    size = Vector2(50*5, 50*5); // スプライトのサイズを指定
    anchor = Anchor.bottomLeft;
    add(RectangleHitbox());
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    // 画面右端の外側、地面 y=canvasSizeに初期配置
    position = Vector2(canvasSize.x + size.x, canvasSize.y  );
  }

  @override
  void update(double dt) {
    super.update(dt);
    // 左へ流れる
    x -= speed * dt;
    // 画面外に出たら削除
    if (x < -width) {
      removeFromParent();
      // （必要なら回避カウントなどの通知をここで）
    }
  }
}
