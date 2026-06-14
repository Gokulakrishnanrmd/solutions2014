import 'package:flutter/material.dart';
import '../alphabet_game.dart';

class MenuOverlay extends StatelessWidget {
  final AlphabetGame game;
  const MenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A237E), Color(0xFF283593)],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            const Text(
              '🦊 ALPHABET',
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFFD700),
                shadows: [
                  Shadow(color: Colors.orange, blurRadius: 20, offset: Offset(0, 3)),
                  Shadow(color: Colors.black54, blurRadius: 6, offset: Offset(3, 3)),
                ],
                letterSpacing: 4,
              ),
            ),
            const Text(
              'RUNNER',
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w900,
                color: Color(0xFF76FF03),
                shadows: [
                  Shadow(color: Colors.green, blurRadius: 20, offset: Offset(0, 3)),
                  Shadow(color: Colors.black54, blurRadius: 6, offset: Offset(3, 3)),
                ],
                letterSpacing: 6,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white38),
              ),
              child: const Text(
                '🎙️ Shout the letter — make Rufus jump!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Animated tap to start
            _PulsingButton(
              onTap: game.startGame,
              label: '▶  TAP TO PLAY',
            ),

            const SizedBox(height: 20),

            // How to play
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('HOW TO PLAY',
                      style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 2)),
                  SizedBox(height: 8),
                  _HowToRow(icon: '📝', text: 'A big letter appears on screen'),
                  _HowToRow(icon: '🗣️', text: 'Shout the letter out loud!'),
                  _HowToRow(icon: '🦊', text: 'Rufus jumps over the obstacle'),
                  _HowToRow(icon: '⭐', text: 'Score points for every correct letter'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HowToRow extends StatelessWidget {
  final String icon, text;
  const _HowToRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ]),
      );
}

class _PulsingButton extends StatefulWidget {
  final VoidCallback onTap;
  final String label;
  const _PulsingButton({required this.onTap, required this.label});

  @override
  State<_PulsingButton> createState() => _PulsingButtonState();
}

class _PulsingButtonState extends State<_PulsingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _scale = Tween(begin: 0.97, end: 1.03).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6F00), Color(0xFFFFA000)],
              ),
              borderRadius: BorderRadius.circular(50),
              boxShadow: const [
                BoxShadow(
                    color: Color(0xFFFF6F00),
                    blurRadius: 20,
                    spreadRadius: 2),
              ],
            ),
            child: Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      );
}
