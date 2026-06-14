import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'game/alphabet_game.dart';
import 'game/overlays/menu_overlay.dart';
import 'game/overlays/hud_overlay.dart';
import 'game/overlays/letter_overlay.dart';
import 'game/overlays/game_over_overlay.dart';
import 'game/overlays/celebration_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const AlphabetRunnerApp());
}

class AlphabetRunnerApp extends StatelessWidget {
  const AlphabetRunnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final game = AlphabetGame();
    return MaterialApp(
      title: 'Alphabet Runner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'monospace',
        useMaterial3: true,
      ),
      home: Scaffold(
        body: GameWidget(
          game: game,
          overlayBuilderMap: {
            AlphabetGame.menuOverlay: (ctx, g) =>
                MenuOverlay(game: g as AlphabetGame),
            AlphabetGame.hudOverlay: (ctx, g) =>
                HudOverlay(game: g as AlphabetGame),
            AlphabetGame.letterOverlay: (ctx, g) =>
                LetterOverlay(game: g as AlphabetGame),
            AlphabetGame.gameOverOverlay: (ctx, g) =>
                GameOverOverlay(game: g as AlphabetGame),
            AlphabetGame.celebrationOverlay: (ctx, g) =>
                CelebrationOverlay(game: g as AlphabetGame),
          },
          initialActiveOverlays: const [AlphabetGame.menuOverlay],
        ),
      ),
    );
  }
}
