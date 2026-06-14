import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PlayerComponent extends PositionComponent {
  final double groundY;
  final double initialX;

  double _velocityY = 0;
  double _runTime = 0;
  bool _isJumping = false;
  bool _isHurt = false;
  double _hurtTimer = 0;

  static const double _gravity = 1100.0;
  static const double _jumpForce = -530.0;
  static const double _pw = 72.0;
  static const double _ph = 80.0;

  bool get isInAir => _isJumping;

  PlayerComponent({required this.groundY, required this.initialX})
      : super(size: Vector2(_pw, _ph));

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    position = Vector2(initialX, groundY - _ph);
  }

  Rect get collisionRect => Rect.fromLTWH(
        position.x + 12,
        position.y + 10,
        _pw - 24,
        _ph - 10,
      );

  void jump() {
    if (!_isJumping) {
      _velocityY = _jumpForce;
      _isJumping = true;
    }
  }

  void showHurt() {
    _isHurt = true;
    _hurtTimer = 0.7;
  }

  void reset() {
    position = Vector2(initialX, groundY - _ph);
    _velocityY = 0;
    _isJumping = false;
    _isHurt = false;
    _hurtTimer = 0;
    _runTime = 0;
  }

  @override
  void update(double dt) {
    _runTime += dt;

    if (_isJumping) {
      _velocityY += _gravity * dt;
      position.y += _velocityY * dt;
      if (position.y >= groundY - _ph) {
        position.y = groundY - _ph;
        _velocityY = 0;
        _isJumping = false;
      }
    }

    if (_isHurt) {
      _hurtTimer -= dt;
      if (_hurtTimer <= 0) _isHurt = false;
    }
  }

  @override
  void render(Canvas canvas) {
    if (_isHurt && ((_hurtTimer * 8).floor() % 2 == 0)) return;

    final groundOffset = (groundY - _ph) - position.y;
    final shadowAlpha = (55 - groundOffset * 0.3).clamp(0.0, 55.0).toInt();
    canvas.drawOval(
      Rect.fromLTWH(10, _ph + groundOffset - 4, _pw - 20, 8),
      Paint()
        ..color = Colors.black.withAlpha(shadowAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    _drawTail(canvas);
    _drawBody(canvas);
    _drawHead(canvas);
    _drawLegs(canvas, _runTime, _isJumping);

    if (_isHurt) {
      canvas.drawOval(
        Rect.fromLTWH(8, 12, _pw - 16, _ph - 16),
        Paint()..color = Colors.red.withAlpha(100),
      );
    }
  }

  void _drawTail(Canvas canvas) {
    final orange = Paint()..color = const Color(0xFFFF8C00);
    final tail = Path()
      ..moveTo(14, 48)
      ..quadraticBezierTo(-20, 28, -8, 8)
      ..quadraticBezierTo(-3, 26, 10, 40)
      ..close();
    canvas.drawPath(tail, orange);

    final tip = Path()
      ..moveTo(-8, 8)
      ..quadraticBezierTo(-18, -2, -9, -5)
      ..quadraticBezierTo(-2, 10, -5, 18)
      ..close();
    canvas.drawPath(tip, Paint()..color = Colors.white);
  }

  void _drawBody(Canvas canvas) {
    canvas.drawOval(
      const Rect.fromLTWH(8, 28, 54, 40),
      Paint()..color = const Color(0xFFFF8C00),
    );
  }

  void _drawHead(Canvas canvas) {
    final orange = Paint()..color = const Color(0xFFFF8C00);
    final pink = Paint()..color = const Color(0xFFFFB3BA);

    canvas.drawCircle(const Offset(54, 22), 20, orange);

    // Left ear
    final leftEar = Path()
      ..moveTo(40, 8)
      ..lineTo(45, -10)
      ..lineTo(52, 8)
      ..close();
    canvas.drawPath(leftEar, orange);
    final leftInner = Path()
      ..moveTo(42, 6)
      ..lineTo(45, -4)
      ..lineTo(51, 6)
      ..close();
    canvas.drawPath(leftInner, pink);

    // Right ear
    final rightEar = Path()
      ..moveTo(56, 7)
      ..lineTo(63, -10)
      ..lineTo(68, 7)
      ..close();
    canvas.drawPath(rightEar, orange);
    final rightInner = Path()
      ..moveTo(58, 5)
      ..lineTo(63, -4)
      ..lineTo(67, 5)
      ..close();
    canvas.drawPath(rightInner, pink);

    // Eye
    canvas.drawOval(
        const Rect.fromLTWH(56, 14, 14, 12), Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(64, 20), 5, Paint()..color = Colors.black);
    canvas.drawCircle(const Offset(66, 18), 2, Paint()..color = Colors.white);

    // Nose
    final nose = Path()
      ..moveTo(70, 26)
      ..lineTo(72, 23)
      ..lineTo(74, 26)
      ..close();
    canvas.drawPath(nose, Paint()..color = Colors.black87);

    // Mouth
    canvas.drawPath(
      Path()
        ..moveTo(69, 28)
        ..quadraticBezierTo(72, 32, 75, 28),
      Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawLegs(Canvas canvas, double t, bool inAir) {
    final paint = Paint()
      ..color = const Color(0xFFE07000)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (inAir) {
      canvas.drawLine(const Offset(22, 62), const Offset(16, 50), paint);
      canvas.drawLine(const Offset(32, 64), const Offset(28, 52), paint);
      canvas.drawLine(const Offset(44, 64), const Offset(44, 52), paint);
      canvas.drawLine(const Offset(54, 62), const Offset(58, 50), paint);
    } else {
      final a = sin(t * 9) * 9;
      canvas.drawLine(Offset(22, 62), Offset(18 + a, 77), paint);
      canvas.drawLine(Offset(32, 64), Offset(30 - a, 78), paint);
      canvas.drawLine(Offset(44, 64), Offset(42 - a, 78), paint);
      canvas.drawLine(Offset(54, 62), Offset(52 + a, 77), paint);
    }
  }
}
