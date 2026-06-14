import 'dart:async' as async;
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'components/player_component.dart';
import 'components/obstacle_component.dart';
import 'components/background_component.dart';
import 'components/ground_component.dart';
import '../services/speech_service.dart';

enum GameState { menu, playing, letterChallenge, gameOver }

class AlphabetGame extends FlameGame {
  static const menuOverlay = 'menu';
  static const hudOverlay = 'hud';
  static const letterOverlay = 'letter';
  static const gameOverOverlay = 'gameOver';
  static const celebrationOverlay = 'celebration';

  final SpeechService speechService = SpeechService();
  final Random _rng = Random();

  GameState state = GameState.menu;
  int score = 0;
  int lives = 3;
  int level = 1;
  int correctStreak = 0;
  double gameSpeed = 160.0;

  String currentLetter = 'A';
  bool jumpPending = false;
  bool challengeAnswered = false;
  double challengeTimeLeft = 5.0;

  late PlayerComponent player;
  final List<ObstacleComponent> _obstacles = [];

  double _cycleTimer = 0;
  double _cycleInterval = 6.5;
  bool _inChallengeCycle = false;
  bool _celebrationShowing = false;

  double groundY = 0;

  static const List<String> _alphabet =
      ['A','B','C','D','E','F','G','H','I','J','K','L','M',
       'N','O','P','Q','R','S','T','U','V','W','X','Y','Z'];
  int _letterIndex = 0;

  @override
  Color backgroundColor() => const Color(0xFF87CEEB);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await speechService.initialize();
    groundY = size.y * 0.74;

    add(BackgroundComponent());
    add(GroundComponent(groundY: groundY));
    player = PlayerComponent(groundY: groundY, initialX: size.x * 0.13);
    add(player);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (state == GameState.playing) {
      _cycleTimer += dt;
      if (_cycleTimer >= _cycleInterval && !_inChallengeCycle) {
        _beginChallenge();
      }
      _checkObstacleProximity();
      _checkCollisions();
      _cleanObstacles();
    }

    if (state == GameState.letterChallenge) {
      challengeTimeLeft -= dt;
      if (challengeTimeLeft <= 0 && !challengeAnswered) {
        _onWrongAnswer();
      }
    }
  }

  void _beginChallenge() {
    _inChallengeCycle = true;
    currentLetter = _alphabet[_letterIndex % 26];
    _letterIndex++;
    challengeTimeLeft = 5.0;
    challengeAnswered = false;
    jumpPending = false;
    state = GameState.letterChallenge;

    // Spawn obstacle so it arrives ~5 s from now
    final spawnX = size.x + gameSpeed * 5.0 + 80;
    _spawnObstacle(spawnX);

    speechService.speakLetter(currentLetter);
    overlays.add(letterOverlay);
    _startSpeechListening();
  }

  void _startSpeechListening() {
    speechService.startListening(
      onResult: (recognized) {
        if (state == GameState.letterChallenge && !challengeAnswered) {
          if (speechService.isCorrectLetter(recognized, currentLetter)) {
            _onCorrectAnswer();
          } else {
            _onWrongAnswer();
          }
        }
      },
      onTimeout: () {
        if (state == GameState.letterChallenge && !challengeAnswered) {
          _onWrongAnswer();
        }
      },
    );
  }

  void _spawnObstacle(double spawnX) {
    final types = ObstacleType.values;
    final type = types[_rng.nextInt(types.length)];
    final obstacle = ObstacleComponent(
      type: type,
      groundY: groundY,
      speed: gameSpeed,
      spawnX: spawnX,
    );
    _obstacles.add(obstacle);
    add(obstacle);
  }

  void _onCorrectAnswer() {
    challengeAnswered = true;
    jumpPending = true;
    speechService.stopListening();
    overlays.remove(letterOverlay);

    score += 10 + (level * 2);
    correctStreak++;

    if (correctStreak % 5 == 0) {
      level++;
      gameSpeed = (160.0 + level * 15.0).clamp(160.0, 320.0);
      _cycleInterval = (6.5 - level * 0.35).clamp(3.5, 6.5);
      for (final o in _obstacles) {
        o.speed = gameSpeed;
      }
    }

    _showCelebration();
    state = GameState.playing;
  }

  void _onWrongAnswer() {
    if (challengeAnswered) return;
    challengeAnswered = true;
    speechService.stopListening();
    overlays.remove(letterOverlay);

    lives--;
    player.showHurt();
    // Mark all current obstacles as passThrough so they don't deal damage again
    for (final o in _obstacles) {
      o.passThrough = true;
    }
    state = GameState.playing;

    if (lives <= 0) {
      async.Future.delayed(const Duration(milliseconds: 900), _endGame);
    }
  }

  void onTapAnswer(String letter) {
    if (state != GameState.letterChallenge || challengeAnswered) return;
    if (letter == currentLetter) {
      _onCorrectAnswer();
    } else {
      _onWrongAnswer();
    }
  }

  void _checkObstacleProximity() {
    if (!jumpPending) return;
    for (final obstacle in _obstacles) {
      if (obstacle.passThrough) continue;
      final dist = obstacle.position.x - player.position.x;
      if (dist > 0 && dist < size.x * 0.22) {
        jumpPending = false;
        player.jump();
        break;
      }
    }
  }

  void _checkCollisions() {
    final pRect = player.collisionRect;
    for (final obstacle in List.of(_obstacles)) {
      if (obstacle.passThrough) continue;
      if (obstacle.collisionRect.overlaps(pRect)) {
        if (player.isInAir) continue;
        obstacle.passThrough = true;
        lives--;
        player.showHurt();
        if (lives <= 0) {
          async.Future.delayed(const Duration(milliseconds: 700), _endGame);
        }
        break;
      }
    }
  }

  void _cleanObstacles() {
    final done = _obstacles.where((o) => o.position.x < -200).toList();
    for (final o in done) {
      o.removeFromParent();
      _obstacles.remove(o);
    }
    // Reset cycle when all obstacles from this wave are off-screen
    if (_inChallengeCycle && _obstacles.isEmpty) {
      _inChallengeCycle = false;
      _cycleTimer = 0;
    }
  }

  void _showCelebration() {
    if (_celebrationShowing) return;
    _celebrationShowing = true;
    overlays.add(celebrationOverlay);
    async.Future.delayed(const Duration(milliseconds: 1800), () {
      overlays.remove(celebrationOverlay);
      _celebrationShowing = false;
    });
  }

  void _endGame() {
    if (state == GameState.gameOver) return;
    state = GameState.gameOver;
    speechService.stopListening();
    overlays.remove(hudOverlay);
    overlays.remove(letterOverlay);
    overlays.remove(celebrationOverlay);
    overlays.add(gameOverOverlay);
    speechService.speak(
        'Game over! You scored $score points. Amazing alphabet learning!');
  }

  void startGame() {
    state = GameState.playing;
    score = 0;
    lives = 3;
    level = 1;
    correctStreak = 0;
    gameSpeed = 160.0;
    _letterIndex = 0;
    _cycleTimer = 0;
    _cycleInterval = 6.5;
    _inChallengeCycle = false;
    jumpPending = false;
    _celebrationShowing = false;

    for (final o in List.of(_obstacles)) {
      o.removeFromParent();
    }
    _obstacles.clear();

    player.reset();
    overlays.remove(menuOverlay);
    overlays.remove(gameOverOverlay);
    overlays.add(hudOverlay);
    speechService.speak('Ready? Say the letters to make Rufus jump!');
  }

  @override
  void onDispose() {
    speechService.dispose();
    super.onDispose();
  }
}
