// lib/flame/player.dart

import 'dart:ui';                        // Paint 用
import 'package:flutter/foundation.dart'; // debugPrint 用
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'adventure_game.dart';
import 'obstacle.dart';

class Player extends SpriteComponent
    with CollisionCallbacks, HasGameRef<AdventureGame> {
  Player({required this.assetPath});
  final String assetPath;

  // ── 物理定数 ──────────────────────────────────────────
  static const g = 2960.0;       // 重力加速度 数字を小さくするとよりゆっくり落ち、大きくすると早く落ちる
  static const jumpV = -1550.0;   // ジャンプ初速　マイナスの絶対値を大きくすると高く飛び、逆に小さくすると低く飛ぶ

  double vy = 0;                 // 現在の鉛直速度
  late double ground;            // 地面 y 座標
  bool onGround = true;          // 着地フラグ

  // ── 読み込み ──────────────────────────────────────────
  @override
  Future<void> onLoad() async {
    debugPrint('🛠 Sprite.load -> $assetPath');
    try {
      sprite = await Sprite.load(assetPath);
      debugPrint('✅ Loaded $assetPath');
    } catch (e) {
      debugPrint('❌ Failed to load $assetPath ($e)');
      paint = Paint()..color = const Color(0xFF2196F3); // 青四角で代用
    }

    size   = Vector2(50*4, 50*4);
    anchor = Anchor.bottomCenter;
    add(RectangleHitbox());
  }

  // ── 画面サイズが確定 or 変更されたとき ────────────────────
  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);

    ground = canvasSize.y - 5;
    position = Vector2(canvasSize.x * 0.10, ground);

    if (y > ground) {
      y = ground;
      vy = 0;
      onGround = true;
    }
  }

  // ── 入力（ジャンプ）─────────────────────────────────────
  void jump() {
    if (onGround) {
      vy = jumpV;
      onGround = false;
    }
  }

  // ── 毎フレーム更新 ──────────────────────────────────────
  @override
  void update(double dt) {
    super.update(dt);

    vy += g * dt;
    y  += vy * dt;

    if (y >= ground) {
      y = ground;
      vy = 0;
      onGround = true;
    }
  }

  // ── 衝突判定 ────────────────────────────────────────────
  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
         // すでに一時停止中なら何もしない（２度目以降はここで弾く）
    if (gameRef.paused) {
      return;
    }
    if (other is Obstacle) {
      // ここで直接 collisionCount フィールドをインクリメント
      gameRef.collisionCount++;
      debugPrint('💥 Player hit obstacle (count=${gameRef.collisionCount})');
 // この障害物は消しておく
      other.removeFromParent();

    
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}
