import 'package:flutter/foundation.dart';

import '../drawables/drawable.dart';

import '../painter_controller.dart';
import 'action.dart';

/// An action of moving a drawable to a different index in the [PainterController].
class MoveDrawableAction extends ControllerAction<bool, bool> {
  /// The drawable to be moved.
  final Drawable drawable;

  /// The index to move the drawable to.
  final int toIndex;

  /// The original index of the drawable before moving.
  ///
  /// This value is initially `null`, and is updated once the action is performed.
  /// It is used by [unperform$] to move the [drawable] back to its original index.
  int? _fromIndex;

  /// Creates a [MoveDrawableAction] with the [drawable] to be moved and the [toIndex] to move it to.
  MoveDrawableAction(this.drawable, this.toIndex);

  /// Performs the action.
  ///
  /// Moves [drawable] to [toIndex] in the drawables in [controller.value].
  ///
  /// Returns `true` if [drawable] was found and moved, and `false` otherwise.
  @protected
  @override
  bool perform$(PainterController controller) {
    final value = controller.value;
    final currentDrawables = List<Drawable>.from(value.drawables);
    final fromIndex = currentDrawables.indexOf(drawable);

    if (fromIndex < 0 || fromIndex == toIndex) return false;

    _fromIndex = fromIndex;

    // Remove from old position and insert at new position
    currentDrawables.removeAt(fromIndex);

    // Insert at the target index (no adjustment needed as insert uses the new indices)
    currentDrawables.insert(toIndex, drawable);

    controller.value = value.copyWith(
      drawables: currentDrawables,
    );

    return true;
  }

  /// Un-performs the action.
  ///
  /// Moves [drawable] back to its original index ([_fromIndex]) in the drawables in [controller.value].
  ///
  /// Returns `true` if [drawable] was found and moved back, and `false` otherwise.
  @protected
  @override
  bool unperform$(PainterController controller) {
    final fromIndex = _fromIndex;
    if (fromIndex == null) return false;

    final value = controller.value;
    final currentDrawables = List<Drawable>.from(value.drawables);
    final currentIndex = currentDrawables.indexOf(drawable);

    if (currentIndex < 0) return false;

    // Remove from current position and insert back at original position
    currentDrawables.removeAt(currentIndex);
    currentDrawables.insert(fromIndex, drawable);

    controller.value = value.copyWith(
      drawables: currentDrawables,
    );

    return true;
  }
}
