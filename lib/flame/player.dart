//ヒノアラシのプレイヤーキャラクターのロジック。ジャンプや当たり判定などのプログラム
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/foundation.dart'; // debugPrint 用
import 'dart:ui';                        // Paint 用

import 'adventure_game.dart';
import 'obstacle.dart'; // 追加: Obstacleクラスをインポート

class Player extends SpriteComponent
    with CollisionCallbacks, HasGameRef<AdventureGame> {
  Player({required this.assetPath});
  final String assetPath;

  // ── 物理定数 ──────────────────────────────────────────
  static const g = 1500.0;      // 重力加速度
  static const jumpV = -720.0; // ジャンプ初速

  double vy = 0;               // 現在の鉛直速度
  late double ground;          // 地面 y 座標
  bool onGround = true;        // 着地判定

  // ── 読み込み ──────────────────────────────────────────
  @override
  Future<void> onLoad() async {
    debugPrint('🛠  Sprite.load -> $assetPath');
    try {
      sprite = await Sprite.load(assetPath);
      debugPrint('✅ Loaded $assetPath');
    } catch (e) {
      debugPrint('❌ Failed to load $assetPath  ($e)');
      paint = Paint()..color = const Color(0xFF2196F3); // 青四角で代用
    }

    size   = Vector2(48*7, 48*7);
    anchor = Anchor.bottomCenter;
  }

  // ── 画面サイズが確定 or 変更されたときに呼ばれる ──
  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);

    // 地面をキャンバス下端ギリギリに再計算
    ground = canvasSize.y -5;

    // 初期配置もここで決めると確実
    position = Vector2(canvasSize.x * 0.10, ground);

    // もしリサイズでプレイヤーがめり込んだら補正
    if (y > ground) y = ground;
  }

  // ── 入力（ジャンプ）────────────────────────────────────
  void jump() {
    if (onGround) {
      vy = jumpV;
      onGround = false;
    }
  }

  // ── 毎フレーム更新 ────────────────────────────────────
  @override
  void update(double dt) {
    super.update(dt);

    vy += g * dt;
    y  += vy * dt;

    // 着地処理
    if (y >= ground) {
      y = ground;
      vy = 0;
      onGround = true;
    }
  }

  // ── 衝突判定 ───────────────────────────────────────────
  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Obstacle) {
        gameRef.incrementCollision();          // ← ここでカウントアップ
      debugPrint('💥 Player hit obstacle');
      gameRef.pauseEngine();
      gameRef.onFinish();
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}
