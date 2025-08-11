import 'dart:async';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixelgame/components/level.dart';
import 'package:pixelgame/components/players.dart';

class PixelAdventure extends FlameGame with HasKeyboardHandlerComponents {
  @override
  late final CameraComponent camera;
  late Player player;
  late Level level;

  @override
  Color backgroundColor() => Colors.white;

  PixelAdventure() {
    // Initialize a placeholder for the camera.
    camera = CameraComponent();
    add(camera); // Adding it early to prevent lifecycle issues.
  }

  @override
  Future<void> onLoad() async {
    await images.loadAllImages();

    // Create player and level
    player = Player(character: 'Mask Dude');
    level = Level(player: player, levelName: 'Level-1');

    // Add the level to the game
    add(level);
    // Configure the camera with the actual world and behaviors

    camera.world = level;
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.add(player);
    camera.viewfinder
        .add(FollowBehavior(target: player)); // Camera follows the player
  }
}
