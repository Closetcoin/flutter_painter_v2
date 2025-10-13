part of 'flutter_painter.dart';

/// Flutter widget to detect user input and request drawing [FreeStyleDrawable]s.
class _FreeStyleWidget extends StatefulWidget {
  /// Child widget.
  final Widget child;

  /// Creates a [_FreeStyleWidget] with the given [controller], [child] widget.
  const _FreeStyleWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _FreeStyleWidgetState createState() => _FreeStyleWidgetState();
}

/// State class
class _FreeStyleWidgetState extends State<_FreeStyleWidget> {
  /// The current drawable being drawn.
  PathDrawable? drawable;

  /// The current erase path being drawn on an object (for eraseObject mode).
  List<Offset>? objectErasePath;

  /// The original drawable before starting the current erase gesture.
  ObjectDrawable? originalDrawable;

  @override
  Widget build(BuildContext context) {
    if (settings.mode == FreeStyleMode.none || shapeSettings.factory != null) {
      return widget.child;
    }

    return RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      gestures: {
        _DragGestureDetector:
            GestureRecognizerFactoryWithHandlers<_DragGestureDetector>(
          () => _DragGestureDetector(
            onHorizontalDragDown: _handleHorizontalDragDown,
            onHorizontalDragUpdate: _handleHorizontalDragUpdate,
            onHorizontalDragUp: _handleHorizontalDragUp,
          ),
          (_) {},
        ),
      },
      child: widget.child,
    );
  }

  /// Getter for [FreeStyleSettings] from `widget.controller.value` to make code more readable.
  FreeStyleSettings get settings =>
      PainterController.of(context).value.settings.freeStyle;

  /// Getter for [ShapeSettings] from `widget.controller.value` to make code more readable.
  ShapeSettings get shapeSettings =>
      PainterController.of(context).value.settings.shape;

  /// Callback when the user holds their pointer(s) down onto the widget.
  void _handleHorizontalDragDown(Offset globalPosition) {
    // If the user is already drawing, don't create a new drawing
    if (this.drawable != null || this.objectErasePath != null) return;

    // Create a new free-style drawable representing the current drawing
    final PathDrawable drawable;
    if (settings.mode == FreeStyleMode.draw) {
      drawable = FreeStyleDrawable(
        path: [_globalToLocal(globalPosition)],
        color: settings.color,
        strokeWidth: settings.strokeWidth,
      );

      // Add the drawable to the controller's drawables
      PainterController.of(context).addDrawables([drawable]);
      // Set the drawable as the current drawable
      this.drawable = drawable;
    } else if (settings.mode == FreeStyleMode.erase) {
      drawable = EraseDrawable(
        path: [_globalToLocal(globalPosition)],
        strokeWidth: settings.strokeWidth,
      );
      PainterController.of(context).groupDrawables();

      // Add the drawable to the controller's drawables
      PainterController.of(context).addDrawables([drawable], newAction: false);
      // Set the drawable as the current drawable
      this.drawable = drawable;
    } else if (settings.mode == FreeStyleMode.eraseObject) {
      // Check if there's a selected object
      final controller = PainterController.of(context);
      if (controller.selectedObjectDrawable == null) return;

      // Save the original drawable for undo support
      originalDrawable = controller.selectedObjectDrawable;

      // Start tracking the erase path for the selected object
      objectErasePath = [_globalToLocal(globalPosition)];
    } else {
      return;
    }
  }

  /// Callback when the user moves, rotates or scales the pointer(s).
  void _handleHorizontalDragUpdate(Offset globalPosition) {
    final drawable = this.drawable;
    final objectErasePath = this.objectErasePath;

    // Handle regular free-style drawing or erasing
    if (drawable != null) {
      // Add the new point to a copy of the current drawable
      final newDrawable = drawable.copyWith(
        path: List<Offset>.from(drawable.path)
          ..add(_globalToLocal(globalPosition)),
      );
      // Replace the current drawable with the copy with the added point
      PainterController.of(context)
          .replaceDrawable(drawable, newDrawable, newAction: false);
      // Update the current drawable to be the new copy
      this.drawable = newDrawable;
    }
    // Handle object erase mode
    else if (objectErasePath != null) {
      // Add the new point to the erase path
      final updatedPath = List<Offset>.from(objectErasePath)
        ..add(_globalToLocal(globalPosition));
      this.objectErasePath = updatedPath;

      // Update the selected object in real-time to show the erase preview
      final controller = PainterController.of(context);
      final selected = controller.selectedObjectDrawable;
      if (selected != null && originalDrawable != null) {
        // Convert path to object-local coordinates
        final localPath =
            _convertToObjectLocalCoordinates(updatedPath, selected);

        // Update the drawable with the original mask plus the current erase path
        final newEraseMask =
            List<List<Offset>>.from(originalDrawable!.eraseMask)
              ..add(localPath);
        final newDrawable = originalDrawable!.copyWith(eraseMask: newEraseMask);
        controller.replaceDrawable(selected, newDrawable, newAction: false);
      }
    }
  }

  /// Callback when the user removes all pointers from the widget.
  void _handleHorizontalDragUp() {
    // Handle regular drawable completion
    if (drawable != null) {
      DrawableCreatedNotification(drawable).dispatch(context);
      drawable = null;
    }
    // Handle object erase path completion
    else if (objectErasePath != null && originalDrawable != null) {
      // Create a proper undoable action by replacing the original with the final version
      final controller = PainterController.of(context);
      final selected = controller.selectedObjectDrawable;

      if (selected != null) {
        // The selected drawable already has the erase applied from the preview
        // Now we need to create an undoable action
        // Replace the temporary preview with the final version (with newAction: true)

        // First, revert to the original drawable
        controller.replaceDrawable(selected, originalDrawable!,
            newAction: false);

        // Then apply the final version with newAction: true to create an undo point
        final localPath = _convertToObjectLocalCoordinates(
            objectErasePath!, originalDrawable!);
        final newEraseMask =
            List<List<Offset>>.from(originalDrawable!.eraseMask)
              ..add(localPath);
        final finalDrawable =
            originalDrawable!.copyWith(eraseMask: newEraseMask);
        controller.replaceDrawable(originalDrawable!, finalDrawable,
            newAction: true);
      }

      // Reset the state
      objectErasePath = null;
      originalDrawable = null;
    }
  }

  Offset _globalToLocal(Offset globalPosition) {
    final getBox = context.findRenderObject() as RenderBox;

    return getBox.globalToLocal(globalPosition);
  }

  /// Converts a path from global canvas coordinates to object-local coordinates.
  /// This ensures the erase path moves with the object when it's transformed.
  ///
  /// Note: The local coordinates are stored in "unflipped" space, meaning they
  /// represent positions relative to the original unflipped object. For flipped
  /// objects, we need to negate the X coordinate because the screen position maps
  /// to the opposite side of the unflipped image.
  List<Offset> _convertToObjectLocalCoordinates(
      List<Offset> canvasPath, ObjectDrawable object) {
    // Convert each point to be relative to the object's position, rotation, and scale
    return canvasPath.map((point) {
      // Translate to object's position
      final translatedPoint = point - object.position;

      // Rotate by the negative of the object's rotation to get local coordinates
      final cos = math.cos(-object.rotationAngle);
      final sin = math.sin(-object.rotationAngle);

      final rotatedX = translatedPoint.dx * cos - translatedPoint.dy * sin;
      final rotatedY = translatedPoint.dx * sin + translatedPoint.dy * cos;

      // Scale by the inverse of the object's scale to get true local coordinates
      var localX = rotatedX / object.scale;
      final localY = rotatedY / object.scale;

      // If the object is horizontally flipped, negate the X coordinate
      // because the screen shows a flipped version - what appears on the right
      // is actually the left side of the unflipped image
      if (object.isFlippedHorizontally) {
        localX = -localX;
      }

      return Offset(localX, localY);
    }).toList();
  }
}

/// A custom recognizer that recognize at most only one gesture sequence.
class _DragGestureDetector extends OneSequenceGestureRecognizer {
  _DragGestureDetector({
    required this.onHorizontalDragDown,
    required this.onHorizontalDragUpdate,
    required this.onHorizontalDragUp,
  });

  final ValueSetter<Offset> onHorizontalDragDown;
  final ValueSetter<Offset> onHorizontalDragUpdate;
  final VoidCallback onHorizontalDragUp;

  bool _isTrackingGesture = false;

  @override
  void addPointer(PointerEvent event) {
    if (!_isTrackingGesture) {
      resolve(GestureDisposition.accepted);
      startTrackingPointer(event.pointer);
      _isTrackingGesture = true;
    } else {
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerDownEvent) {
      onHorizontalDragDown(event.position);
    } else if (event is PointerMoveEvent) {
      onHorizontalDragUpdate(event.position);
    } else if (event is PointerUpEvent) {
      onHorizontalDragUp();
      stopTrackingPointer(event.pointer);
      _isTrackingGesture = false;
    }
  }

  @override
  String get debugDescription => '_DragGestureDetector';

  @override
  void didStopTrackingLastPointer(int pointer) {}
}
