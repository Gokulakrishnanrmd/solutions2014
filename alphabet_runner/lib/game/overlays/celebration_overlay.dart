import 'dart:math';
import 'package:flutter/material.dart';
import '../alphabet_game.dart';

class CelebrationOverlay extends StatefulWidget {
  final AlphabetGame game;
  const CelebrationOverlay({super.key, required this.game});

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  final List<_ConfettiPiece> _confetti = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));
    _scale = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 0.3, end: 1.2)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(_controller);
    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_controller);

    final rng = Random();
    for (int i = 0; i < 30; i++) {
      _confetti.add(_ConfettiPiece(rng: rng));
    }
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final letter = widget.game.currentLetter;
    final pts = 10 + (widget.game.level * 2);

    return AnimatedBuilder(
      animation: _controller,
      builder: (ctx, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Stack(
            children: [
              // Confetti
              ..._confetti.map((c) => c.build(_controller.value)),

              // Center panel
              Center(
                child: ScaleTransition(
                  scale: _scale,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(180),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: const Color(0xFFFFD700), width: 3),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0xFFFFD700),
                            blurRadius: 30,
                            spreadRadius: 2),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🌟 CORRECT! 🌟',
                            style: TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2)),
                        const SizedBox(height: 4),
                        Text(
                          letter,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 64,
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(
                                  color: Color(0xFFFFD700),
                                  blurRadius: 20),
                            ],
                          ),
                        ),
                        Text(
                          '+$pts pts',
                          style: const TextStyle(
                              color: Color(0xFF76FF03),
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ConfettiPiece {
  final double x, startY, size, speed;
  final Color color;
  final double angle;

  static const _colors = [
    Colors.red, Colors.orange, Colors.yellow,
    Colors.green, Colors.blue, Colors.purple, Colors.pink,
  ];

  _ConfettiPiece({required Random rng})
      : x = rng.nextDouble(),
        startY = -0.1 + rng.nextDouble() * -0.4,
        size = 6 + rng.nextDouble() * 8,
        speed = 0.2 + rng.nextDouble() * 0.5,
        color = _colors[rng.nextInt(_colors.length)],
        angle = rng.nextDouble() * pi * 2;

  Widget build(double progress) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;
      final curY = (startY + progress * speed * 1.5) * h;

      if (curY > h || progress == 0) return const SizedBox.shrink();

      return Positioned(
        left: x * w,
        top: curY,
        child: Transform.rotate(
          angle: angle + progress * 4,
          child: Container(
            width: size,
            height: size * 0.6,
            color: color.withAlpha(
                (255 * (1 - (progress * 1.2).clamp(0.0, 1.0))).round()),
          ),
        ),
      );
    });
  }
}
