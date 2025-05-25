// 障害物をよけるゲーム

import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'dart:ui'; // Color 用

import '../models/game_mode.dart';
import 'player.dart';
import 'obstacle.dart';
import 'package:flame_audio/flame_audio.dart';

class AdventureGame extends FlameGame
    with TapCallbacks, HasCollisionDetection {
  AdventureGame({
    required this.chosenId,
    required this.mode,
    required this.onFinish,
    this.startPaused = false,
  });

  final int chosenId;
  final GameMode mode;
  final VoidCallback onFinish;
  final bool startPaused;

  /// 衝突カウント
  int collisionCount = 0;
  /// 生成済みの障害物カウント（最大10個まで）
  int spawnCount = 0;
  /// 背景コンポーネント
  SpriteComponent? _background;
  late Player _player;

  /// タイマー (秒)
  late double _timeLeft;

  /// カレントの生成間隔
  late double _currentInterval;
  /// ランダム生成用の上下限
  late final double _intervalMin;
  late final double _intervalMax;

  double _spawnTimer = 0;
  final _rng = Random();

  @override
  Color backgroundColor() => const Color(0xFFB3E5FC);

  @override
  Future<void> onLoad() async {
    // ────────── モードごとの設定 ──────────
    if (mode == GameMode.normal) {
      _timeLeft = 20.0;
      _intervalMin = _intervalMax = 1.7; // 固定1.2秒
    } else {
      _timeLeft = 18.0;
      _intervalMin = 1.2;    // 最低1.0秒
      _intervalMax = 1.8;    // 上限はお好みで調整（ここでは1.5秒に設定）
    }
    // 最初の間隔を設定
    _currentInterval = _intervalMax;

    // ────────── 背景 ──────────
    _background = SpriteComponent()
      ..sprite = await Sprite.load('syo.png')
      ..position = Vector2.zero()
      ..size = Vector2(100, 100)  // 後で onGameResize で拡大
      ..anchor = Anchor.topLeft;
    add(_background!);

    // ────────── プレイヤー ──────────
    _player = Player(assetPath: _pathForId(chosenId));
    add(_player);

    // セリフシーン中はストップ
    if (startPaused) {
      pauseEngine();
    }
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    // 背景を画面いっぱいに
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

    // 障害物生成
    _spawnTimer += dt;
    if (_spawnTimer >= _currentInterval && spawnCount < 10) {
      _spawnTimer = 0;
      add(Obstacle());
      spawnCount++;

      // 次の間隔を決定
      if (mode == GameMode.hard) {
        _currentInterval =
            _intervalMin + _rng.nextDouble() * (_intervalMax - _intervalMin);
      } else {
        _currentInterval = _intervalMax; // ノーマルは毎回1.2秒
      }
    }
  }

  @override
  void onTapDown(TapDownEvent _) { 
  FlameAudio.play('Anime_Motion08-2(Mid).mp3');
   _player.jump();
  }

 /// id==2 (シークレット) はモードで purple / green を切替
String _pathForId(int id) {
  if (id == 2) {
    return mode == GameMode.hard ? 'purple.png' : 'green.png';
  }
  switch (id) {
    case 0:  return 'red.png';
    case 1:  return 'blue.png';
    default: return 'red.png';
  }
}

  }
    
