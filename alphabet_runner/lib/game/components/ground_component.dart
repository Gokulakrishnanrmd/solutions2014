import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GroundComponent extends PositionComponent with HasGameRef<FlameGame> {
  final double groundY;
  final List<_Blade> _blades = [];
  late List<_Pebble> _pebbles;
  double _scrollX = 0;

  GroundComponent({required this.groundY});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final w = gameRef.size.x;
    final h = gameRef.size.y - groundY;
    size = Vector2(w, h);
    position = Vector2(0, groundY);

    final rng = Random(99);
    for (int i = 0; i < 45; i++) {
      _blades.add(_Blade(
        x: rng.nextDouble() * w,
        h: 8 + rng.nextDouble() * 10,
        lean: (rng.nextDouble() - 0.5) * 0.6,
      ));
    }
    final pr = Random(42);
    _pebbles = List.generate(14, (_) => _Pebble(
      x: pr.nextDouble() * w,
      y: 20 + pr.nextDouble() * 18,
      w: 6 + pr.nextDouble() * 9,
      h: 4 + pr.nextDouble() * 4,
    ));
  }

  @override
  void update(double dt) {
    final w = gameRef.size.x;
    _scrollX = (_scrollX + 160 * dt) % w;
    for (final b in _blades) {
      b.x = (b.x - 160 * dt + w) % w;
    }
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    final dirtRect = Rect.fromLTWH(0, 14, w, h - 14);

    canvas.drawRect(
      dirtRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xFF8D6E63), Color(0xFF4E342E)],
        ).createShader(dirtRect),
    );

    canvas.drawRect(Rect.fromLTWH(0, 0, w, 18), Paint()..color = const Color(0xFF66BB6A));
    canvas.drawRect(Rect.fromLTWH(0, 14, w, 5), Paint()..color = const Color(0xFF43A047));

    for (final b in _blades) {
      canvas.drawLine(
        Offset(b.x, 8),
        Offset(b.x + b.lean * b.h, 8 - b.h),
        Paint()
          ..color = const Color(0xFF81C784)
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
    }

    final pebble = Paint()..color = Colors.grey.shade400.withAlpha(160);
    for (final p in _pebbles) {
      final px = (p.x - _scrollX + w) % (w + 20) - 10;
      canvas.drawOval(Rect.fromLTWH(px, p.y, p.w, p.h), pebble);
    }
  }
}

class _Blade {
  double x;
  final double h, lean;
  _Blade({required this.x, required this.h, required this.lean});
}

class _Pebble {
  final double x, y, w, h;
  _Pebble({required this.x, required this.y, required this.w, required this.h});
}
