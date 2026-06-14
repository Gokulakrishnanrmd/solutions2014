import 'dart:async';
import 'package:flutter/material.dart';
import '../alphabet_game.dart';

class HudOverlay extends StatefulWidget {
  final AlphabetGame game;
  const HudOverlay({super.key, required this.game});

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay> {
  late Timer _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Rebuild 8× per second to reflect score / lives changes
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 125), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Lives (hearts)
            Row(
              children: List.generate(3, (i) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  i < game.lives ? '❤️' : '🖤',
                  style: const TextStyle(fontSize: 22),
                ),
              )),
            ),
            // Score + Level chips
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                _Chip(label: '⭐ ${game.score}', color: const Color(0xFFFFD700)),
                const SizedBox(height: 4),
                _Chip(label: 'Level ${game.level}', color: const Color(0xFF76FF03), small: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final bool small;
  const _Chip({required this.label, required this.color, this.small = false});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(
            horizontal: small ? 8 : 12, vertical: small ? 3 : 5),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(180), width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: small ? 12 : 18,
            shadows: [Shadow(color: color.withAlpha(100), blurRadius: 8)],
          ),
        ),
      );
}
