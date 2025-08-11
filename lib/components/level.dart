import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixelgame/components/collision_block.dart';
import 'package:pixelgame/components/players.dart';

class Level extends World with HasGameRef {
  final String levelName;
  final Player player;

  Level({required this.levelName, required this.player});

  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));
    add(level);

    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>('Spawnpoints');
    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        if (spawnPoint.class_ == 'Player') {
          player.position = Vector2(spawnPoint.x, spawnPoint.y);
          // Ensure the player is placed correctly above the ground
          if (player.position.y > game.size.y - player.size.y / 2) {
            player.position.y = game.size.y - player.size.y / 2; // Prevent falling off
          }
          add(player);  // Add player only once after setting position
        }
      }
    }

    final collisionLayer = level.tileMap.getLayer<ObjectGroup>('Collisions');
    if (collisionLayer != null) {
      for (final collision in collisionLayer.objects) {
        final block = CollisionBlock(
          position: Vector2(collision.x, collision.y),
          size: Vector2(collision.width, collision.height),
          isPlatfrom: true,
        );
        collisionBlocks.add(block);
        add(block);
      }
    }

    player.collisionBlocks = collisionBlocks;
    return super.onLoad();
  }
}
