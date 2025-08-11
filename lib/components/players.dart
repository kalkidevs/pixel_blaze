import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixelgame/components/collision_block.dart';
import 'package:pixelgame/pixel_adventure.dart';

enum PlayerState { idle, running, jumping }

enum PlayerDirection { right, left, none }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler {
  String character;

  Player({position, required this.character}) : super(position: position);

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpAnimation;
  final double stepTime = 0.05;

  PlayerDirection playerDirection = PlayerDirection.none;
  double moveSpeed = 100;
  double gravity = 500;
  double jumpForce = 200;
  Vector2 velocity = Vector2.zero();
  List<CollisionBlock> collisionBlocks = [];
  bool isFacingRight = true;
  bool onGround = true;

  @override
  FutureOr<void> onLoad() async {
    // debugMode = true;
    _loadAllAnimations();
    size = Vector2.all(32);
    anchor = Anchor.center;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerMovement(dt);
    print("Updating: position.y = ${position.y}, velocity.y = ${velocity.y}, onGround = $onGround");
    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);
    final isJumpKeyPressed = keysPressed.contains(LogicalKeyboardKey.space);

    if (isLeftKeyPressed && isRightKeyPressed) {
      playerDirection = PlayerDirection.none;
    } else if (isLeftKeyPressed) {
      playerDirection = PlayerDirection.left;
    } else if (isRightKeyPressed) {
      playerDirection = PlayerDirection.right;
    } else {
      playerDirection = PlayerDirection.none;
    }

    if (isJumpKeyPressed) jump();
    return super.onKeyEvent(event, keysPressed);
  }

  void _loadAllAnimations() {
    runningAnimation = _spriteAnimation('Run', 12);
    idleAnimation = _spriteAnimation('Idle', 11);
    jumpAnimation = _spriteAnimation('Jump', 1);
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpAnimation,
    };
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }

  // void _updatePlayerMovement(double dt) {
  //   double dirX = 0.0;
  //
  //   switch (playerDirection) {
  //     case PlayerDirection.left:
  //       if (isFacingRight) {
  //         flipHorizontallyAroundCenter();
  //         isFacingRight = false;
  //       }
  //       current = PlayerState.running; // Set to running when moving
  //       dirX -= moveSpeed;
  //       break;
  //     case PlayerDirection.right:
  //       if (!isFacingRight) {
  //         flipHorizontallyAroundCenter();
  //         isFacingRight = true;
  //       }
  //       current = PlayerState.running; // Set to running when moving
  //       dirX += moveSpeed;
  //       break;
  //     case PlayerDirection.none:
  //       if (onGround) current = PlayerState.idle; // Set to idle when not moving
  //       break;
  //   }
  //
  //   // Move horizontally while considering collisions
  //   position.x += dirX * dt;
  //
  //   // Check for horizontal collisions
  //   for (var block in collisionBlocks) {
  //     if (block.toRect().overlaps(toRect())) {
  //       // Collision detected, adjust position
  //       if (playerDirection == PlayerDirection.left) {
  //         position.x = block.position.x +
  //             block.size.x; // Prevent player from passing through left side
  //       } else if (playerDirection == PlayerDirection.right) {
  //         position.x = block.position.x -
  //             size.x; // Prevent player from passing through right side
  //       }
  //     }
  //   }
  //
  //   velocity.x = dirX;
  // }

  void _updatePlayerMovement(double dt) {
    double dirX = 0.0;

    // Horizontal movement
    switch (playerDirection) {
      case PlayerDirection.left:
        if (isFacingRight) {
          flipHorizontallyAroundCenter();
          isFacingRight = false;
        }
        current = PlayerState.running;
        dirX -= moveSpeed;
        break;
      case PlayerDirection.right:
        if (!isFacingRight) {
          flipHorizontallyAroundCenter();
          isFacingRight = true;
        }
        current = PlayerState.running;
        dirX += moveSpeed;
        break;
      case PlayerDirection.none:
        if (onGround) current = PlayerState.idle;
        break;
    }

    // Gravity and vertical velocity
    if (!onGround) {
      velocity.y += gravity * dt;
    } else {
      velocity.y = 0; // Stop falling when on the ground
    }

    // Apply movement
    position.x += dirX * dt;
    position.y += velocity.y * dt;

    // Check collisions
    onGround =
        false; // Reset onGround, will be set true if standing on a platform
    for (var block in collisionBlocks) {
      if (block.toRect().overlaps(toRect())) {
        if (block.isPlatfrom) {
          // Handle collisions with platforms
          final double playerBottom = position.y + size.y / 2;
          final double blockTop = block.position.y;
          final double playerTop = position.y - size.y / 2;
          final double blockBottom = block.position.y + block.size.y;

          if (velocity.y > 0 &&
              playerBottom > blockTop &&
              playerTop < blockTop) {
            // Player is falling onto the platform
            position.y =
                blockTop - size.y / 2; // Align player on top of the platform
            velocity.y = 0;
            onGround = true;
          } else if (velocity.y < 0 &&
              playerTop < blockBottom &&
              playerBottom > blockBottom) {
            // Player hits the platform from below
            position.y =
                blockBottom + size.y / 2; // Prevent player from going through
            velocity.y = 0;
          } else if (playerDirection == PlayerDirection.left &&
              position.x < block.position.x + block.size.x) {
            // Handle horizontal collision when moving left
            position.x = block.position.x + block.size.x;
          } else if (playerDirection == PlayerDirection.right &&
              position.x + size.x > block.position.x) {
            // Handle horizontal collision when moving right
            position.x = block.position.x - size.x;
          }
        }
      }
    }
  }

  void jump() {
    if (onGround) {
      onGround = false; // Prevent multiple jumps
      velocity.y = -jumpForce; // Apply upward force
      current = PlayerState.jumping; // Set animation state to jumping
    }
  }


  void updateDirection(PlayerDirection direction) {
    playerDirection = direction;
  }
}
