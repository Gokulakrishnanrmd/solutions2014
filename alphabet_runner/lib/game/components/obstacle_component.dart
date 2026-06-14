import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum ObstacleType { stump, rock, pit, spikeBush }

class ObstacleComponent extends PositionComponent {
  final ObstacleType type;
  final double groundY;
  double speed;
  bool passThrough = false;

  ObstacleComponent({
    required this.type,
    required this.groundY,
    required this.speed,
    required double spawnX,
  }) : super(size: _sizeFor(type)) {
    position = Vector2(
      spawnX,
      type == ObstacleType.pit ? groundY : groundY - _sizeFor(type).y,
    );
  }

  static Vector2 _sizeFor(ObstacleType t) {
    switch (t) {
      case ObstacleType.stump:
        return Vector2(42, 58);
      case ObstacleType.rock:
        return Vector2(64, 44);
      case ObstacleType.pit:
        return Vector2(90, 28);
      case ObstacleType.spikeBush:
        return Vector2(56, 52);
    }
  }

  Rect get collisionRect {
    const pad = 6.0;
    return Rect.fromLTWH(
      position.x + pad,
      position.y + pad,
      size.x - pad * 2,
      size.y - pad * 2,
    );
  }

  @override
  void update(double dt) {
    position.x -= speed * dt;
  }

  @override
  void render(Canvas canvas) {
    switch (type) {
      case ObstacleType.stump:
        _drawStump(canvas);
      case ObstacleType.rock:
        _drawRock(canvas);
      case ObstacleType.pit:
        _drawPit(canvas);
      case ObstacleType.spikeBush:
        _drawSpikeBush(canvas);
    }
  }

  void _drawStump(Canvas canvas) {
    // Trunk
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(5, 14, 32, 44), const Radius.circular(4)),
      Paint()..color = const Color(0xFF8B4513),
    );
    // Top
    canvas.drawOval(
        const Rect.fromLTWH(2, 8, 38, 16),
        Paint()..color = const Color(0xFFA0522D));
    // Rings
    final ring = Paint()
      ..color = const Color(0xFF8B4513)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawOval(const Rect.fromLTWH(8, 10, 26, 12), ring);
    canvas.drawOval(const Rect.fromLTWH(14, 12, 14, 8), ring);
    // Grass
    final gp = Paint()
      ..color = const Color(0xFF4CAF50)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 6; i++) {
      canvas.drawLine(Offset(2.0 + i * 7.0, 56), Offset(4.0 + i * 7.0, 44), gp);
    }
  }

  void _drawRock(Canvas canvas) {
    canvas.drawOval(
      const Rect.fromLTWH(4, 36, 56, 10),
      Paint()..color = Colors.black.withAlpha(35),
    );
    final rock = Path()
      ..moveTo(10, 44)
      ..lineTo(4, 30)
      ..lineTo(14, 10)
      ..lineTo(30, 4)
      ..lineTo(50, 12)
      ..lineTo(60, 28)
      ..lineTo(58, 44)
      ..close();
    canvas.drawPath(rock, Paint()..color = const Color(0xFF8D8D8D));
    final highlight = Path()
      ..moveTo(14, 16)
      ..lineTo(10, 24)
      ..lineTo(20, 12)
      ..close();
    canvas.drawPath(highlight, Paint()..color = const Color(0xFFBDBDBD));
    final dark = Path()
      ..moveTo(46, 28)
      ..lineTo(56, 30)
      ..lineTo(58, 44)
      ..lineTo(46, 44)
      ..close();
    canvas.drawPath(dark, Paint()..color = const Color(0xFF616161));
  }

  void _drawPit(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4E342E), Colors.black],
        ).createShader(rect),
    );
    // Zigzag top edge
    final edge = Path()..moveTo(0, 0);
    for (int i = 0; i <= 10; i++) {
      edge.lineTo(i * 9.0, i.isEven ? 8 : 0);
    }
    edge
      ..lineTo(size.x, 10)
      ..lineTo(0, 10)
      ..close();
    canvas.drawPath(edge, Paint()..color = const Color(0xFF5D4037));
    // Warning arrows
    final arrow = Paint()
      ..color = Colors.yellow.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final cx in [size.x / 3, size.x * 2 / 3]) {
      final p = Path()
        ..moveTo(cx - 5, 3)
        ..lineTo(cx, 11)
        ..lineTo(cx + 5, 3);
      canvas.drawPath(p, arrow);
    }
  }

  void _drawSpikeBush(Canvas canvas) {
    final cx = size.x / 2;
    final cy = size.y * 0.55;
    canvas.drawCircle(Offset(cx, cy), 22, Paint()..color = const Color(0xFF2E7D32));

    final spikePaint = Paint()
      ..color = const Color(0xFF1B5E20)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 14; i++) {
      final angle = (i / 14) * pi * 2;
      canvas.drawLine(
        Offset(cx + cos(angle) * 18, cy + sin(angle) * 18),
        Offset(cx + cos(angle) * 28, cy + sin(angle) * 28),
        spikePaint,
      );
    }
    // Berries
    final berryPaint = Paint()..color = const Color(0xFFD32F2F);
    for (int i = 0; i < 5; i++) {
      final angle = (i / 5) * pi * 2;
      canvas.drawCircle(
          Offset(cx + cos(angle) * 12, cy + sin(angle) * 12), 3, berryPaint);
    }
    // Grass base
    final gp = Paint()
      ..color = const Color(0xFF388E3C)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 5; i++) {
      canvas.drawLine(
          Offset(5.0 + i * 11.0, size.y),
          Offset(8.0 + i * 11.0, size.y - 12),
          gp);
    }
  }
}
