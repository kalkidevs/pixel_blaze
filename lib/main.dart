import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:pixelgame/components/players.dart';
import 'package:pixelgame/pixel_adventure.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  PixelAdventure game = PixelAdventure();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            GameWidget(game: game),
            Positioned(
              bottom: 20,
              left: 300,
              child: Row(
                children: [
                  GestureDetector(
                    onTapDown: (_) =>
                        game.player.updateDirection(PlayerDirection.left),
                    onTapUp: (_) =>
                        game.player.updateDirection(PlayerDirection.none),
                    child: Container(
                      height: 50,
                      width: 100,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.grey.withOpacity(.5)),
                      child: const Icon(
                        Icons.arrow_left,

                      ),
                    ),
                  ),
                  GestureDetector(
                    onTapDown: (_) => game.player.jump(),
                    // Use onTapDown for jump
                    child: Container(
                      height: 50,
                      width: 100,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.grey.withOpacity(.5)),
                      child: const Icon(Icons.arrow_upward),
                    ),
                  ),
                  GestureDetector(
                    onTapDown: (_) =>
                        game.player.updateDirection(PlayerDirection.right),
                    onTapUp: (_) =>
                        game.player.updateDirection(PlayerDirection.none),
                    child: Container(
                      height: 50,
                      width: 100,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.grey.withOpacity(.5)),
                      child: const Icon(Icons.arrow_right),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
