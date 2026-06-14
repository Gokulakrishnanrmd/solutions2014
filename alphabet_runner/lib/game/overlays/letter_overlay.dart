import 'dart:async';
import 'package:flutter/material.dart';
import '../alphabet_game.dart';
import '../../services/speech_service.dart';

class LetterOverlay extends StatefulWidget {
  final AlphabetGame game;
  const LetterOverlay({super.key, required this.game});

  @override
  State<LetterOverlay> createState() => _LetterOverlayState();
}

class _LetterOverlayState extends State<LetterOverlay>
    with TickerProviderStateMixin {
  late AnimationController _bounceCtrl;
  late AnimationController _micCtrl;
  late Animation<double> _bounce;
  late Animation<double> _micPulse;
  late Timer _refreshTimer;

  static const List<Color> _palette = [
    Color(0xFFFF1744), Color(0xFFFF6D00), Color(0xFFFFD600),
    Color(0xFF00E676), Color(0xFF00B0FF), Color(0xFFD500F9),
    Color(0xFFFF4081), Color(0xFF1DE9B6),
  ];

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650))
      ..forward();
    _bounce = CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut);

    _micCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);
    _micPulse = Tween(begin: 0.8, end: 1.2)
        .animate(CurvedAnimation(parent: _micCtrl, curve: Curves.easeInOut));

    // Refresh every 100ms so the countdown bar stays accurate
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _micCtrl.dispose();
    _refreshTimer.cancel();
    super.dispose();
  }

  Color _letterColor(String letter) {
    final idx = letter.codeUnitAt(0) - 'A'.codeUnitAt(0);
    return _palette[idx % _palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final letter = game.currentLetter;
    final word = SpeechService.letterWords[letter] ?? '';
    final color = _letterColor(letter);
    final progress = (game.challengeTimeLeft / 5.0).clamp(0.0, 1.0);
    final alphabet = List.generate(26, (i) => String.fromCharCode(65 + i));

    return Column(
      children: [
        // ── Top banner ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withAlpha(190), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Big bouncing letter
              ScaleTransition(
                scale: _bounce,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withAlpha(25),
                    border: Border.all(color: color, width: 3),
                    boxShadow: [
                      BoxShadow(color: color.withAlpha(130), blurRadius: 22, spreadRadius: 4),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: 70,
                        fontWeight: FontWeight.w900,
                        color: color,
                        height: 1.0,
                        shadows: [
                          Shadow(color: color.withAlpha(180), blurRadius: 14),
                          const Shadow(color: Colors.black87, blurRadius: 3, offset: Offset(2, 2)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$letter  is for',
                      style: const TextStyle(color: Colors.white70, fontSize: 13, fontStyle: FontStyle.italic)),
                  Text(
                    word,
                    style: TextStyle(
                      color: color,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: color.withAlpha(90), blurRadius: 10)],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Countdown bar
                  SizedBox(
                    width: 150,
                    height: 9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress > 0.4 ? color : Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ScaleTransition(
                        scale: _micPulse,
                        child: const Text('🎙️', style: TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 6),
                      const Text('Shout the letter!',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        const Spacer(),

        // ── Tap-to-answer keyboard (fallback for no mic) ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(170),
            border: const Border(top: BorderSide(color: Colors.white24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No mic? Tap the letter:',
                  style: TextStyle(color: Colors.white54, fontSize: 11)),
              const SizedBox(height: 5),
              Wrap(
                spacing: 5,
                runSpacing: 5,
                alignment: WrapAlignment.center,
                children: alphabet.map((l) {
                  final isTarget = l == letter;
                  return GestureDetector(
                    onTap: () => game.onTapAnswer(l),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isTarget ? color.withAlpha(55) : Colors.white.withAlpha(15),
                        border: Border.all(
                            color: isTarget ? color : Colors.white30,
                            width: isTarget ? 2 : 1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          l,
                          style: TextStyle(
                            color: isTarget ? color : Colors.white70,
                            fontWeight: isTarget ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
