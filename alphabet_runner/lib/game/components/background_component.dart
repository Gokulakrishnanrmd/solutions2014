import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BackgroundComponent extends PositionComponent with HasGameRef<FlameGame> {
  final List<_Cloud> _clouds = [];
  final List<_Tree> _farTrees = [];
  final List<_Tree> _nearTrees = [];
  final List<_Mountain> _mountains = [];
  final Random _rng = Random(1234);
  late double _groundY;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = gameRef.size;
    final w = size.x;
    _groundY = size.y * 0.74;

    for (int i = 0; i < 7; i++) {
      _mountains.add(_Mountain(
        x: w * i / 6,
        w: 130 + _rng.nextDouble() * 90,
        h: 75 + _rng.nextDouble() * 65,
        ground: _groundY,
      ));
    }
    for (int i = 0; i < 9; i++) {
      _farTrees.add(_Tree(
        x: i * (w / 8) - 20,
        y: _groundY * 0.82,
        w: 55 + _rng.nextDouble() * 40,
        h: 70 + _rng.nextDouble() * 50,
        color: const Color(0xFF388E3C),
        speed: 50,
      ));
    }
    for (int i = 0; i < 6; i++) {
      _nearTrees.add(_Tree(
        x: i * (w / 5) - 30,
        y: _groundY * 0.88,
        w: 65 + _rng.nextDouble() * 50,
        h: 90 + _rng.nextDouble() * 55,
        color: const Color(0xFF2E7D32),
        speed: 90,
      ));
    }
    for (int i = 0; i < 6; i++) {
      _clouds.add(_Cloud(
        x: _rng.nextDouble() * w,
        y: 15 + _rng.nextDouble() * _groundY * 0.28,
        w: 80 + _rng.nextDouble() * 70,
        speed: 14 + _rng.nextDouble() * 18,
      ));
    }
  }

  @override
  void update(double dt) {
    final w = gameRef.size.x;
    for (final m in _mountains) {
      m.x -= 18 * dt;
      if (m.x < -m.w) m.x = w + _rng.nextDouble() * 60;
    }
    for (final t in [..._farTrees, ..._nearTrees]) {
      t.x -= t.speed * dt;
      if (t.x < -t.w - 10) {
        t.x = w + _rng.nextDouble() * 40;
        t.w = 55 + _rng.nextDouble() * 50;
        t.h = 70 + _rng.nextDouble() * 60;
      }
    }
    for (final c in _clouds) {
      c.x -= c.speed * dt;
      if (c.x < -c.w) {
        c.x = w + 20;
        c.y = 15 + _rng.nextDouble() * _groundY * 0.28;
        c.speed = 14 + _rng.nextDouble() * 18;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5), Color(0xFFB3E5FC)],
          stops: [0, 0.4, 1],
        ).createShader(rect),
    );
    for (final m in _mountains) m.render(canvas);
    for (final t in _farTrees) t.render(canvas);
    for (final t in _nearTrees) t.render(canvas);
    for (final c in _clouds) c.render(canvas);
  }
}

class _Cloud {
  double x, y, w, speed;
  _Cloud({required this.x, required this.y, required this.w, required this.speed});

  void render(Canvas canvas) {
    final h = w * 0.36;
    final p = Paint()..color = Colors.white.withAlpha(215);
    canvas.drawOval(Rect.fromLTWH(x, y, w, h), p);
    canvas.drawOval(Rect.fromLTWH(x + w * 0.15, y - h * 0.55, w * 0.48, h * 0.75), p);
    canvas.drawOval(Rect.fromLTWH(x + w * 0.45, y - h * 0.4, w * 0.36, h * 0.65), p);
  }
}

class _Mountain {
  double x;
  final double w, h, ground;
  _Mountain({required this.x, required this.w, required this.h, required this.ground});

  void render(Canvas canvas) {
    canvas.drawPath(
      Path()
        ..moveTo(x, ground)
        ..lineTo(x + w / 2, ground - h)
        ..lineTo(x + w, ground)
        ..close(),
      Paint()..color = const Color(0xFF7B1FA2).withAlpha(150),
    );
    canvas.drawPath(
      Path()
        ..moveTo(x + w * 0.35, ground - h * 0.63)
        ..lineTo(x + w / 2, ground - h)
        ..lineTo(x + w * 0.65, ground - h * 0.63)
        ..close(),
      Paint()..color = Colors.white.withAlpha(200),
    );
  }
}

class _Tree {
  double x, y;
  double w, h;
  final Color color;
  final double speed;
  _Tree({required this.x, required this.y, required this.w, required this.h,
      required this.color, required this.speed});

  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(x + w / 2 - 5, y + h * 0.45, 10, h * 0.55),
      Paint()..color = const Color(0xFF5D4037),
    );
    final leaf = Paint()..color = color;
    for (int i = 0; i < 3; i++) {
      final tierH = h * (0.48 - i * 0.04);
      final tierW = w * (1.0 - i * 0.26);
      final tierY = y + i * h * 0.16;
      canvas.drawPath(
        Path()
          ..moveTo(x + w / 2 - tierW / 2, tierY + tierH)
          ..lineTo(x + w / 2, tierY)
          ..lineTo(x + w / 2 + tierW / 2, tierY + tierH)
          ..close(),
        leaf,
      );
    }
  }
}
