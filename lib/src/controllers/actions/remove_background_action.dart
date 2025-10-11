import 'package:flutter/foundation.dart';

import '../drawables/drawable.dart';
import '../drawables/image_drawable.dart';
import '../painter_controller.dart';
import 'action.dart';
import 'add_drawables_action.dart';
import 'insert_drawables_action.dart';

/// An action of removing the background from an [ImageDrawable] in the [PainterController].
///
/// This action replaces an [ImageDrawable] with a new one that has a transparent background.
class RemoveBackgroundAction extends ControllerAction<bool, bool> {
  /// The original drawable before background removal.
  final ImageDrawable originalDrawable;

  /// The new drawable with background removed.
  final ImageDrawable processedDrawable;

  /// Creates a [RemoveBackgroundAction] with [originalDrawable] and [processedDrawable].
  RemoveBackgroundAction(this.originalDrawable, this.processedDrawable);

  /// Performs the action.
  ///
  /// Replaces [originalDrawable] with [processedDrawable] (background removed version).
  ///
  /// Returns `true` if [originalDrawable] is found and replaced, and `false` otherwise.
  @protected
  @override
  bool perform$(PainterController controller) {
    final value = controller.value;
    final oldDrawableIndex = value.drawables.indexOf(originalDrawable);
    if (oldDrawableIndex < 0) {
      return false;
    }

    final currentDrawables = List<Drawable>.from(value.drawables);
    final selectedObject = controller.selectedObjectDrawable;
    final isSelectedObject = originalDrawable == selectedObject;

    currentDrawables[oldDrawableIndex] = processedDrawable;

    controller.value = value.copyWith(
      drawables: currentDrawables,
      selectedObjectDrawable:
          isSelectedObject ? processedDrawable : selectedObject,
    );

    return true;
  }

  /// Un-performs the action.
  ///
  /// Replaces [processedDrawable] back with [originalDrawable] (restores original).
  ///
  /// Returns `true` if [processedDrawable] is found and replaced, and `false` otherwise.
  @protected
  @override
  bool unperform$(PainterController controller) {
    final value = controller.value;
    final newDrawableIndex = value.drawables.indexOf(processedDrawable);
    if (newDrawableIndex < 0) {
      return false;
    }

    final currentDrawables = List<Drawable>.from(value.drawables);
    final selectedObject = controller.selectedObjectDrawable;
    final isSelectedObject = processedDrawable == selectedObject;

    currentDrawables[newDrawableIndex] = originalDrawable;

    controller.value = value.copyWith(
      drawables: currentDrawables,
      selectedObjectDrawable:
          isSelectedObject ? originalDrawable : selectedObject,
    );

    return true;
  }

  /// Merges [this] action and the [previousAction] into one action.
  ///
  /// If the previous action was also a background removal on the same drawable,
  /// we merge them by keeping the original from the first action.
  @protected
  @override
  ControllerAction? merge$(ControllerAction previousAction) {
    if (previousAction is RemoveBackgroundAction &&
        previousAction.processedDrawable == originalDrawable) {
      // Chain multiple background removals: keep the very first original
      return RemoveBackgroundAction(
          previousAction.originalDrawable, processedDrawable);
    }
    return super.merge$(previousAction);
  }
}
