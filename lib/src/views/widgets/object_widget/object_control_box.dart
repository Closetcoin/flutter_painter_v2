import 'package:flutter/material.dart';

/// The control box container (only the UI, no logic).
/// This is used for scale, rotation, resize, and stretch controls.
class ObjectControlBox extends StatelessWidget {
  /// Shape of the control box.
  final BoxShape shape;

  /// Whether the box is being used or not.
  final bool active;

  /// Color of control when it is not active.
  /// Defaults to [Colors.white].
  final Color inactiveColor;

  /// Color of control when it is active.
  /// If null is provided, the theme's accent color is used. If there is no theme, [Colors.blue] is used.
  final Color? activeColor;

  /// Color of the shadow surrounding the control.
  /// Defaults to [Colors.black].
  final Color shadowColor;

  /// The blur radius of the shadow.
  /// Defaults to `2.0`.
  final double shadowBlurRadius;

  /// The color of the control box border.
  /// Defaults to `Colors.grey`.
  final Color borderColor;

  /// The thickness of the control box border.
  /// Defaults to `1.0`.
  final double borderWidth;

  /// Duration for the transition animation
  static const Duration transitionDuration = Duration(milliseconds: 100);

  /// Creates an [ObjectControlBox] with the given [shape] and [active].
  ///
  /// By default, it will be a [BoxShape.rectangle] shape and not active.
  const ObjectControlBox({
    Key? key,
    this.shape = BoxShape.rectangle,
    this.active = false,
    this.inactiveColor = Colors.white,
    this.activeColor,
    this.shadowColor = Colors.black,
    this.shadowBlurRadius = 2.0,
    this.borderColor = Colors.grey,
    this.borderWidth = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData? theme = Theme.of(context);
    if (theme == ThemeData.fallback()) theme = null;
    final activeColor =
        this.activeColor ?? theme?.colorScheme.secondary ?? Colors.blue;
    return AnimatedContainer(
      duration: transitionDuration,
      decoration: BoxDecoration(
        color: active ? activeColor : inactiveColor,
        shape: shape,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: shadowBlurRadius > 0
            ? [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: shadowBlurRadius,
                )
              ]
            : null,
      ),
    );
  }
}
