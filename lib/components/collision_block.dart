import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent {
  bool isPlatfrom;

  CollisionBlock({position, size, this.isPlatfrom = false})
      : super(
          position: position,
          size: size,
        ) {
    // debugMode = true;
  }
}
