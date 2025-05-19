// lib/flame/adventure_game.dart

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'dart:ui'; // Color 用

import '../models/game_mode.dart';  // 追加
import 'player.dart';
import 'obstacle.dart';

class AdventureGame extends FlameGame
    with TapCallbacks, HasCollisionDetection {
  AdventureGame({
    required this.chosenId,
    required this.mode,          // 追加
    required this.onFinish,
    this.startPaused = false,
  });

  final int chosenId;
  final GameMode mode;           // 追加
  final VoidCallback onFinish;
  final bool startPaused;

  /// 衝突カウント
  int collisionCount = 0;

  /// 生成済みの障害物カウント（最大10個まで）
  int spawnCount = 0;

  /// 背景コンポーネント（nullable にして初期化前アクセスを防ぐ）
  SpriteComponent? _background;

  late Player _player;
  late double _timeLeft;         // モード別に設定
  double _spawn = 0;
  late double _interval;         // モード別に設定

  @override
  Color backgroundColor() => const Color(0xFFB3E5FC);

  @override
  Future<void> onLoad() async {
    // ▼ モードごとの時間と生成間隔を設定
    if (mode == GameMode.normal) {
      _timeLeft = 20.0;       // ノーマル 20秒
      _interval = 1.2;        // 障害物間隔：1.2秒
    } else {
      _timeLeft = 15.0;       // ハード 15秒
      _interval = 0.8;        // 障害物間隔：0.8秒
    }

    // 1) 背景を最背面に貼る（ダミーサイズで初期化）
    _background = SpriteComponent()
      ..sprite = await Sprite.load('syo.png')
      ..position = Vector2.zero()
      ..size = Vector2(100, 100)  // あとで onGameResize で画面全体に
      ..anchor = Anchor.topLeft;
    add(_background!);

    // 2) プレイヤーを追加
    _player = Player(assetPath: _pathForId(chosenId));
    add(_player);

    // セリフシーン中は止める
    if (startPaused) {
      pauseEngine();
    }
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    // 背景があれば画面サイズいっぱいに伸ばす
    _background?..size = canvasSize;
  }

  @override
  void update(double dt) {
    // セリフシーン中は何もしない
    if (paused) return;
    super.update(dt);

    // タイマー
    _timeLeft -= dt;
    if (_timeLeft <= 0) {
      pauseEngine();
      onFinish();
      return;
    }

    // 障害物生成（最大10個）
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
