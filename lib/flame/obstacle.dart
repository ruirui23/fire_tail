//障害物の位置や衝突判定、動きの処理プログラム
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

class Obstacle extends SpriteComponent
    with CollisionCallbacks, HasGameRef {
  static const v = 240.0;

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('/tyebuo.png');
    size   = Vector2(40, 40);
    anchor = Anchor.bottomLeft;
    y      = gameRef.size.y - 10;
    x      = gameRef.size.x + width;
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    x -= v * dt;
    if (x < -width) removeFromParent();
  }
}
