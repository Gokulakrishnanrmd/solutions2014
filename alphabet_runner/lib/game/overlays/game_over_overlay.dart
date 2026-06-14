import 'package:flutter/material.dart';
import '../alphabet_game.dart';

class GameOverOverlay extends StatefulWidget {
  final AlphabetGame game;
  const GameOverOverlay({super.key, required this.game});

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _slideIn;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _slideIn = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _getGrade() {
    final score = widget.game.score;
    if (score >= 200) return 'A+';
    if (score >= 150) return 'A';
    if (score >= 100) return 'B';
    if (score >= 50) return 'C';
    return 'D';
  }

  String _getMessage() {
    final g = _getGrade();
    switch (g) {
      case 'A+':
        return 'You\'re an alphabet superstar! 🌟';
      case 'A':
        return 'Brilliant job! 🎉';
      case 'B':
        return 'Well done! Keep practising! 😊';
      case 'C':
        return 'Good try! You can do it! 💪';
      default:
        return 'Keep learning! You got this! 🦊';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position:
                Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
                    .animate(_slideIn),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 380),
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A237E), Color(0xFF283593)],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFFFD700), width: 2.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 30),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Game Over
                  const Text(
                    'GAME OVER',
                    style: TextStyle(
                      color: Color(0xFFFF1744),
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      shadows: [
                        Shadow(
                            color: Color(0xFFFF1744),
                            blurRadius: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Grade badge
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFD700),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0xFFFFD700), blurRadius: 16),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _getGrade(),
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    _getMessage(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatBox(
                          icon: '⭐',
                          label: 'SCORE',
                          value: '${widget.game.score}'),
                      _StatBox(
                          icon: '🎯',
                          label: 'LEVEL',
                          value: '${widget.game.level}'),
                      _StatBox(
                          icon: '🔥',
                          label: 'STREAK',
                          value: '${widget.game.correctStreak}'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Play again
                  GestureDetector(
                    onTap: widget.game.startGame,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6F00), Color(0xFFFFA000)],
                        ),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0xFFFF6F00),
                              blurRadius: 16,
                              spreadRadius: 1),
                        ],
                      ),
                      child: const Text(
                        '🦊  PLAY AGAIN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String icon, label, value;
  const _StatBox(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 10)),
        ],
      );
}
