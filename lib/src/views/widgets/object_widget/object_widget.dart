part of '../flutter_painter.dart';

/// Flutter widget to move, scale and rotate [ObjectDrawable]s.
///
/// V2: Refactored version using extracted components for better maintainability.
class _ObjectWidget extends StatefulWidget {
  /// Child widget.
  final Widget child;

  /// Whether scaling is enabled or not.
  ///
  /// If `false`, objects won't be movable, scalable or rotatable.
  final bool interactionEnabled;

  /// Creates a [_ObjectWidget] with the given [controller], [child] widget.
  const _ObjectWidget({
    Key? key,
    required this.child,
    this.interactionEnabled = true,
  }) : super(key: key);

  @override
  _ObjectWidgetState createState() => _ObjectWidgetState();
}

class _ObjectWidgetState extends State<_ObjectWidget> {
  static Set<double> assistAngles = <double>{
    0,
    pi / 4,
    pi / 2,
    3 * pi / 4,
    pi,
    5 * pi / 4,
    3 * pi / 2,
    7 * pi / 4,
    2 * pi
  };

  /// The last controller value in the widget tree.
  /// Updated by [didChangeDependencies] and used in [dispose].
  PainterController? controller;

  /// Calculates the scale for the [InteractiveViewer] in the widget tree, and scales
  double transformationScale = 1;

  /// Getter for extra amount of padding added around each object to make it easier to interact with.
  double get objectPadding =>
      settings.selectionIndicatorSettings.padding / transformationScale;

  /// Getter for the duration of fade-in and out animations for the object controls.
  static Duration get controlsTransitionDuration =>
      const Duration(milliseconds: 100);

  /// Getter for the size of the corner controls.
  /// Uses the size specified in accessibilityControls settings.
  double get controlsSize =>
      settings.accessibilityControls.controlSize / transformationScale;

  /// Getter for the stretch controls settings.
  StretchControlsSettings get stretchControlsSettings =>
      settings.stretchControlsSettings;

  /// Keeps track of the initial local focal point when scaling starts.
  ///
  /// This is used to offset the movement of the drawable correctly.
  Map<int, Offset> drawableInitialLocalFocalPoints = {};

  /// Keeps track of the initial drawable when scaling starts.
  ///
  /// This is used to calculate the new rotation angle and
  /// degree relative to the initial drawable.
  Map<int, ObjectDrawable> initialScaleDrawables = {};

  /// Keeps track of widgets that have assist lines assigned to them.
  ///
  /// This is used to provide haptic feedback when the assist line appears.
  Map<ObjectDrawableAssist, Set<int>> assistDrawables = {
    for (var e in ObjectDrawableAssist.values) e: <int>{}
  };

  /// Keeps track of which controls are being used.
  ///
  /// Used to highlight the controls when they are in use.
  Map<int, bool> controlsAreActive = {
    for (var e in List.generate(8, (index) => index)) e: false
  };

  /// Keeps track of the initial local position when a control is clicked.
  ///
  /// This is used to calculate deltas for smooth scaling without jumps.
  Map<int, Offset> controlInitialLocalPositions = {};

  /// Subscription to the events coming from the controller.
  StreamSubscription<PainterEvent>? controllerEventSubscription;

  /// Getter for the list of [ObjectDrawable]s in the controller
  /// to make code more readable.
  List<ObjectDrawable> get drawables => PainterController.of(context)
      .value
      .drawables
      .whereType<ObjectDrawable>()
      .toList();

  /// A flag on whether to cancel controls animation or not.
  /// This is used to cancel the animation after the selected object
  /// drawable is deleted.
  bool cancelControlsAnimation = false;

  @override
  void initState() {
    super.initState();

    // Listen to the stream of events from the paint controller
    WidgetsBinding.instance.addPostFrameCallback((timestamp) {
      controllerEventSubscription =
          PainterController.of(context).events.listen((event) {
        // When an [RemoveDrawableEvent] event is received and removed drawable is the selected object
        // cancel the animation.
        if (event is SelectedObjectDrawableRemovedEvent) {
          setState(() {
            cancelControlsAnimation = true;
          });
        }
      });

      // Listen to transformation changes of [InteractiveViewer].
      PainterController.of(context)
          .transformationController
          .addListener(onTransformUpdated);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller = PainterController.of(context);
  }

  @override
  void dispose() {
    // Cancel subscription to events from painter controller
    controllerEventSubscription?.cancel();
    controller?.transformationController.removeListener(onTransformUpdated);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final drawables = this.drawables;
    final drawableAirTransformable =
        controller?.selectedObjectDrawable != null &&
            controller?.shapeSettings.factory == null;
    final selectedDrawableEntry = drawableAirTransformable
        ? MapEntry<int, ObjectDrawable>(
            drawables.indexOf(controller!.selectedObjectDrawable!),
            controller!.selectedObjectDrawable!)
        : MapEntry<int, ObjectDrawable>(
            0,
            TextDrawable(
              position: const Offset(0, 0),
              text: '',
            ));

    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          // Background gesture detector for deselection and air-transforming
          Positioned.fill(
              child: GestureDetector(
                  onTap: onBackgroundTapped,
                  onScaleStart: drawableAirTransformable
                      ? (details) =>
                          onDrawableScaleStart(selectedDrawableEntry, details)
                      : null,
                  onScaleUpdate: drawableAirTransformable
                      ? (details) =>
                          onDrawableScaleUpdate(selectedDrawableEntry, details)
                      : null,
                  onScaleEnd: drawableAirTransformable
                      ? (_) => onDrawableScaleEnd(selectedDrawableEntry)
                      : null,
                  child: widget.child)),

          // Render each drawable with its controls using the extracted helper method
          ...drawables
              .asMap()
              .entries
              .map((entry) => _buildDrawableWidget(entry, constraints)),
        ],
      );
    });
  }

  /// Builds a single drawable widget with all its controls.
  /// This method has been extracted to reduce complexity and improve readability.
  Widget _buildDrawableWidget(
      MapEntry<int, ObjectDrawable> entry, BoxConstraints constraints) {
    final drawable = entry.value;
    final selected = drawable == controller?.selectedObjectDrawable;

    // Use ObjectLayoutCalculator to compute all layout properties
    final layout = ObjectLayoutCalculator(
      drawable: drawable,
      constraints: constraints,
      objectPadding: objectPadding,
      transformationScale: transformationScale,
      stretchControlsSettings: stretchControlsSettings,
      isSelected: selected,
      cornerControlsSize: controlsSize,
      cornerControlsOffset:
          settings.accessibilityControls.cornerOffset / transformationScale,
      showCornerControls: settings.accessibilityControls.showRotationControl ||
          settings.accessibilityControls.showScaleControl,
    );

    final contentWidget = SizedBox(
      width: layout.contentSize.width,
      height: layout.contentSize.height,
    );

    return Positioned(
      top: layout.containerTopLeft.dy,
      left: layout.containerTopLeft.dx,
      child: Transform.rotate(
        angle: drawable.rotationAngle,
        transformHitTests: true,
        child: _buildDrawableContent(
          entry: entry,
          drawable: drawable,
          selected: selected,
          contentWidget: contentWidget,
          layout: layout,
          constraints: constraints,
        ),
      ),
    );
  }

  /// Builds the content for a drawable (either with or without controls).
  Widget _buildDrawableContent({
    required MapEntry<int, ObjectDrawable> entry,
    required ObjectDrawable drawable,
    required bool selected,
    required Widget contentWidget,
    required ObjectLayoutCalculator layout,
    required BoxConstraints constraints,
  }) {
    // If free-style drawing is enabled, just render with padding
    if (freeStyleSettings.mode != FreeStyleMode.none &&
        freeStyleSettings.mode != FreeStyleMode.eraseObject) {
      return Padding(
        padding: EdgeInsets.all(layout.innerPadding),
        child: contentWidget,
      );
    }

    // Otherwise, render with gesture detector and optionally controls
    return MouseRegion(
      cursor:
          drawable.locked ? MouseCursor.defer : SystemMouseCursors.allScroll,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => tapDrawable(drawable),
        onScaleStart: freeStyleSettings.mode == FreeStyleMode.eraseObject
            ? null
            : (details) => onDrawableScaleStart(entry, details),
        onScaleUpdate: freeStyleSettings.mode == FreeStyleMode.eraseObject
            ? null
            : (details) => onDrawableScaleUpdate(entry, details),
        onScaleEnd: freeStyleSettings.mode == FreeStyleMode.eraseObject
            ? null
            : (_) => onDrawableScaleEnd(entry),
        child: AnimatedSwitcher(
          duration: controlsTransitionDuration,
          child: selected && settings.selectionIndicatorSettings.enabled
              ? ObjectControlsContainer(
                  contentWidget: contentWidget,
                  drawable: drawable,
                  layout: layout,
                  settings: settings,
                  transformationScale: transformationScale,
                  controlsSize: controlsSize,
                  controlsAreActive: controlsAreActive,
                  initialScaleDrawables: initialScaleDrawables,
                  entryKey: entry.key,
                  showRotationControl:
                      settings.accessibilityControls.showRotationControl,
                  showScaleControl:
                      settings.accessibilityControls.showScaleControl,
                  // Scale control callbacks
                  onScaleControlPanStart: (index, details) =>
                      onScaleControlPanStart(index, entry, details),
                  onScaleControlPanUpdate: (index, details) =>
                      onScaleControlPanUpdate(index, entry, details,
                          constraints, index == 0 || index == 1),
                  onScaleControlPanEnd: (index, details) =>
                      onScaleControlPanEnd(index, entry, details),
                  // Rotation control callbacks
                  onRotationControlPanStart: (index, details) =>
                      onRotationControlPanStart(index, entry, details),
                  onRotationControlPanUpdate: (index, details) =>
                      onRotationControlPanUpdate(
                          entry, details, layout.contentSize),
                  onRotationControlPanEnd: (index, details) =>
                      onRotationControlPanEnd(index, entry, details),
                  // Image stretch control callbacks
                  onImageStretchControlPanStart: layout
                          .shouldRenderStretchControls
                      ? (index, details) =>
                          onImageStretchControlPanStart(index, entry, details)
                      : null,
                  onImageStretchControlPanUpdate:
                      layout.shouldRenderStretchControls
                          ? (index, details) => onImageStretchControlPanUpdate(
                              entry,
                              details,
                              constraints,
                              index == 4 || index == 5
                                  ? Axis.vertical
                                  : Axis.horizontal,
                              index == 4 || index == 6)
                          : null,
                  onImageStretchControlPanEnd:
                      layout.shouldRenderStretchControls
                          ? (index, details) =>
                              onImageStretchControlPanEnd(index, entry, details)
                          : null,
                  // Resize control callbacks
                  onResizeControlPanStart: drawable is Sized2DDrawable
                      ? (index, details) =>
                          onResizeControlPanStart(index, entry, details)
                      : null,
                  onResizeControlPanUpdate: drawable is Sized2DDrawable
                      ? (index, details) => onResizeControlPanUpdate(
                          entry,
                          details,
                          constraints,
                          index == 4 || index == 5
                              ? Axis.vertical
                              : Axis.horizontal,
                          index == 4 || index == 6)
                      : null,
                  onResizeControlPanEnd: drawable is Sized2DDrawable
                      ? (index, details) =>
                          onResizeControlPanEnd(index, entry, details)
                      : null,
                )
              : Padding(
                  padding: EdgeInsets.all(layout.innerPadding),
                  child: contentWidget,
                ),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          layoutBuilder: (child, previousChildren) {
            if (cancelControlsAnimation) {
              cancelControlsAnimation = false;
              return child ?? const SizedBox();
            }
            return AnimatedSwitcher.defaultLayoutBuilder(
                child, previousChildren);
          },
        ),
      ),
    );
  }

  /// Getter for the [ObjectSettings] from the controller to make code more readable.
  ObjectSettings get settings =>
      PainterController.of(context).value.settings.object;

  /// Getter for the [FreeStyleSettings] from the controller to make code more readable.
  ///
  /// This is used to disable object movement, scaling and rotation
  /// when free-style drawing is enabled.
  FreeStyleSettings get freeStyleSettings =>
      PainterController.of(context).value.settings.freeStyle;

  /// Triggers when the user taps an empty space.
  ///
  /// Deselects the selected object drawable.
  /// If single object mode is enabled, deselection is prevented.
  void onBackgroundTapped() {
    // Don't allow deselection in single object mode
    if (settings.singleObjectMode) {
      return;
    }

    SelectedObjectDrawableUpdatedNotification(null).dispatch(context);

    setState(() {
      controller?.deselectObjectDrawable();
    });
  }

  /// Callback when an object is tapped.
  ///
  /// Dispatches an [ObjectDrawableNotification] that the object was tapped.
  void tapDrawable(ObjectDrawable drawable) {
    if (drawable.locked) return;

    if (controller?.selectedObjectDrawable == drawable) {
      ObjectDrawableReselectedNotification(drawable).dispatch(context);
    } else {
      SelectedObjectDrawableUpdatedNotification(drawable).dispatch(context);
    }

    setState(() {
      controller?.selectObjectDrawable(drawable);
    });
  }

  /// Callback when the object drawable starts being moved, scaled and/or rotated.
  ///
  /// Saves the initial point of interaction and drawable to be used on update events.
  void onDrawableScaleStart(
      MapEntry<int, ObjectDrawable> entry, ScaleStartDetails details) {
    if (!widget.interactionEnabled) return;

    final index = entry.key;
    final drawable = entry.value;

    if (index < 0 || drawable.locked) return;

    setState(() {
      controller?.selectObjectDrawable(entry.value);
    });

    // For ImageDrawable objects, ensure the scale property is synchronized with scaleX and scaleY
    if (drawable is ImageDrawable) {
      // Use the average of scaleX and scaleY as the base scale for uniform operations
      final averageScale = (drawable.scaleX + drawable.scaleY) / 2;
      final synchronizedDrawable = drawable.copyWith(scale: averageScale);
      initialScaleDrawables[index] = synchronizedDrawable;
    } else {
      initialScaleDrawables[index] = drawable;
    }

    // When the gesture detector is rotated, the hit test details are not transformed with it
    // This causes events from rotated objects to behave incorrectly
    // So, a [Matrix4] is used to transform the needed event details to be consistent with
    // the current rotation of the object
    final rotateOffset = Matrix4.rotationZ(drawable.rotationAngle)
      ..translate(details.localFocalPoint.dx, details.localFocalPoint.dy)
      ..rotateZ(-drawable.rotationAngle);
    drawableInitialLocalFocalPoints[index] =
        Offset(rotateOffset[12], rotateOffset[13]);

    updateDrawable(drawable, drawable, newAction: true);
  }

  /// Callback when the object drawable finishes movement, scaling and rotation.
  ///
  /// Cleans up the object information.
  void onDrawableScaleEnd(MapEntry<int, ObjectDrawable> entry) {
    if (!widget.interactionEnabled) return;

    final index = entry.key;

    // Using the index instead of [entry.value] is to prevent an issue
    // when an update and end events happen before the UI is updated,
    // the [entry.value] is the old drawable before it was updated
    // This causes updating the entry in this method to sometimes fail
    // To get around it, the object is fetched directly from the drawables
    // in the controller
    final drawable = drawables[index];

    // Clean up
    drawableInitialLocalFocalPoints.remove(index);
    initialScaleDrawables.remove(index);
    for (final assistSet in assistDrawables.values) {
      assistSet.remove(index);
    }

    // Remove any assist lines the object has
    final newDrawable = drawable.copyWith(assists: {});

    updateDrawable(drawable, newDrawable);
  }

  /// Callback when the object drawable is moved, scaled and/or rotated.
  ///
  /// Calculates the next position, scale and rotation of the object depending on the event details.
  void onDrawableScaleUpdate(
      MapEntry<int, ObjectDrawable> entry, ScaleUpdateDetails details) {
    if (!widget.interactionEnabled) return;

    final index = entry.key;
    final drawable = entry.value;
    if (index < 0) return;

    final initialDrawable = initialScaleDrawables[index];
    // When the gesture detector is rotated, the hit test details are not transformed with it
    // This causes events from rotated objects to behave incorrectly
    // So, a [Matrix4] is used to transform the needed event details to be consistent with
    // the current rotation of the object
    final initialLocalFocalPoint =
        drawableInitialLocalFocalPoints[index] ?? Offset.zero;

    if (initialDrawable == null) return;

    final initialPosition = initialDrawable.position - initialLocalFocalPoint;
    final initialRotation = initialDrawable.rotationAngle;

    // When the gesture detector is rotated, the hit test details are not transformed with it
    // This causes events from rotated objects to behave incorrectly
    // So, a [Matrix4] is used to transform the needed event details to be consistent with
    // the current rotation of the object
    final rotateOffset = Matrix4.identity()
      ..rotateZ(initialRotation)
      ..translate(details.localFocalPoint.dx, details.localFocalPoint.dy)
      ..rotateZ(-initialRotation);
    final position =
        initialPosition + Offset(rotateOffset[12], rotateOffset[13]);

    // Calculate scale of object reference to the initial object scale
    final scale = initialDrawable.scale * details.scale;

    // For ImageDrawable objects, calculate the scale factor to apply to both scaleX and scaleY
    double scaleFactor = 1.0;
    if (initialDrawable is ImageDrawable) {
      // The details.scale is cumulative, so we need to calculate the factor relative to the initial state
      // The initial state has scale = (scaleX + scaleY) / 2, and we want to apply the same factor to both
      scaleFactor = details.scale;
    }

    // Calculate the rotation of the object reference to the initial object rotation
    // and normalize it so that its between 0 and 2*pi
    var rotation = (initialRotation + details.rotation).remainder(pi * 2);
    if (rotation < 0) rotation += pi * 2;

    // The center point of the widget
    final center = this.center;

    // The angle from [assistAngles] the object's current rotation is close
    final double? closestAssistAngle;

    // If layout assist is enabled, calculate the positional and rotational assists
    if (settings.layoutAssist.enabled) {
      calculatePositionalAssists(
        settings.layoutAssist,
        index,
        position,
        center,
      );
      closestAssistAngle = calculateRotationalAssist(
        settings.layoutAssist,
        index,
        rotation,
      );
    } else {
      closestAssistAngle = null;
    }

    // The set of assists for the object
    // If layout assist is disabled, it is empty
    final assists = settings.layoutAssist.enabled
        ? assistDrawables.entries
            .where((element) => element.value.contains(index))
            .map((e) => e.key)
            .toSet()
        : <ObjectDrawableAssist>{};

    // Do not display the rotational assist if the user is using less that 2 pointers
    // So, rotational assist lines won't show if the user is only moving the object
    if (details.pointerCount < 2) assists.remove(ObjectDrawableAssist.rotation);

    // Snap the object to the horizontal/vertical center if its is near it
    // and layout assist is enabled
    final assistedPosition = Offset(
      assists.contains(ObjectDrawableAssist.vertical) ? center.dx : position.dx,
      assists.contains(ObjectDrawableAssist.horizontal)
          ? center.dy
          : position.dy,
    );

    // Snap the object rotation to the nearest angle from [assistAngles] if its near it
    // and layout assist is enabled
    final assistedRotation = assists.contains(ObjectDrawableAssist.rotation) &&
            closestAssistAngle != null
        ? closestAssistAngle.remainder(pi * 2)
        : rotation;

    final newDrawable = drawable.copyWith(
      position: assistedPosition,
      scale: scale,
      rotation: assistedRotation,
      assists: assists,
    );

    // For ImageDrawable objects, also update scaleX and scaleY proportionally
    if (drawable is ImageDrawable &&
        newDrawable is ImageDrawable &&
        initialDrawable is ImageDrawable) {
      // Apply the scale factor to the initial scaleX and scaleY values
      final imageDrawable = newDrawable.copyWith(
        scaleX: initialDrawable.scaleX * scaleFactor,
        scaleY: initialDrawable.scaleY * scaleFactor,
      );
      updateDrawable(drawable, imageDrawable);
      return;
    }

    updateDrawable(drawable, newDrawable);
  }

  /// Calculates whether the object entered or exited the horizontal and vertical assist areas.
  void calculatePositionalAssists(ObjectLayoutAssistSettings settings,
      int index, Offset position, Offset center) {
    // Horizontal
    //
    // If the object is within the enter distance from the center dy and isn't marked
    // as a drawable with a horizontal assist, mark it
    if ((position.dy - center.dy).abs() < settings.positionalEnterDistance &&
        !(assistDrawables[ObjectDrawableAssist.horizontal]?.contains(index) ??
            false)) {
      assistDrawables[ObjectDrawableAssist.horizontal]?.add(index);
      settings.hapticFeedback.impact();
    }
    // Otherwise, if the object is outside the exit distance from the center dy and is marked as
    // as a drawable with a horizontal assist, un-mark it
    else if ((position.dy - center.dy).abs() >
            settings.positionalExitDistance &&
        (assistDrawables[ObjectDrawableAssist.horizontal]?.contains(index) ??
            false)) {
      assistDrawables[ObjectDrawableAssist.horizontal]?.remove(index);
    }

    // Vertical
    //
    // If the object is within the enter distance from the center dx and isn't marked
    // as a drawable with a vertical assist, mark it
    if ((position.dx - center.dx).abs() < settings.positionalEnterDistance &&
        !(assistDrawables[ObjectDrawableAssist.vertical]?.contains(index) ??
            false)) {
      assistDrawables[ObjectDrawableAssist.vertical]?.add(index);
      settings.hapticFeedback.impact();
    }
    // Otherwise, if the object is outside the exit distance from the center dx and is marked as
    // as a drawable with a vertical assist, un-mark it
    else if ((position.dx - center.dx).abs() >
            settings.positionalExitDistance &&
        (assistDrawables[ObjectDrawableAssist.vertical]?.contains(index) ??
            false)) {
      assistDrawables[ObjectDrawableAssist.vertical]?.remove(index);
    }
  }

  /// Calculates whether the object entered or exited the rotational assist range.
  ///
  /// Returns the angle the object is closest to if it is inside the assist range.
  double? calculateRotationalAssist(
      ObjectLayoutAssistSettings settings, int index, double rotation) {
    // Calculates all angles from [assistAngles] in the exit range of rotational assist
    final closeAngles = assistAngles
        .where(
            (angle) => (rotation - angle).abs() < settings.rotationalExitAngle)
        .toList();

    // If the object is close to at least one assist angle
    if (closeAngles.isNotEmpty) {
      // If the object is also in the enter range of rotational assist and isn't marked
      // as a drawable with a rotational assist, mark it
      if (closeAngles.any((angle) =>
              (rotation - angle).abs() < settings.rotationalEnterAngle) &&
          !(assistDrawables[ObjectDrawableAssist.rotation]?.contains(index) ??
              false)) {
        assistDrawables[ObjectDrawableAssist.rotation]?.add(index);
        settings.hapticFeedback.impact();
      }
      // Return the angle the object is close to
      return closeAngles[0];
    }

    // Otherwise, if the object is not in the exit range of any assist angles,
    // but is marked as a drawable with rotational assist, un-mark it
    if (closeAngles.isEmpty &&
        (assistDrawables[ObjectDrawableAssist.rotation]?.contains(index) ??
            false)) {
      assistDrawables[ObjectDrawableAssist.rotation]?.remove(index);
    }

    return null;
  }

  /// Returns the center point of the painter widget.
  ///
  /// Uses the [GlobalKey] for the painter from [controller].
  Offset get center {
    final renderBox = PainterController.of(context)
        .painterKey
        .currentContext
        ?.findRenderObject() as RenderBox?;
    final center = renderBox == null
        ? Offset.zero
        : Offset(
            renderBox.size.width / 2,
            renderBox.size.height / 2,
          );
    return center;
  }

  /// Replaces a drawable with a new one.
  void updateDrawable(ObjectDrawable oldDrawable, ObjectDrawable newDrawable,
      {bool newAction = false}) {
    setState(() {
      PainterController.of(context)
          .replaceDrawable(oldDrawable, newDrawable, newAction: newAction);
    });
  }

  void onRotationControlPanStart(int controlIndex,
      MapEntry<int, ObjectDrawable> entry, DragStartDetails details) {
    setState(() {
      controlsAreActive[controlIndex] = true;
    });
    onDrawableScaleStart(
        entry,
        ScaleStartDetails(
          pointerCount: 2,
          localFocalPoint: entry.value.position,
        ));
  }

  void onRotationControlPanUpdate(MapEntry<int, ObjectDrawable> entry,
      DragUpdateDetails details, Size size) {
    final index = entry.key;
    final initial = initialScaleDrawables[index];
    if (initial == null) return;
    final initialOffset = Offset((size.width / 2), (-size.height / 2));
    final initialAngle = atan2(initialOffset.dx, initialOffset.dy);
    final angle = atan2((details.localPosition.dx + initialOffset.dx),
        (details.localPosition.dy + initialOffset.dy));
    final rotation = initialAngle - angle;
    onDrawableScaleUpdate(
        entry,
        ScaleUpdateDetails(
          pointerCount: 2,
          rotation: rotation,
          scale: 1,
          localFocalPoint: entry.value.position,
        ));
  }

  void onRotationControlPanEnd(int controlIndex,
      MapEntry<int, ObjectDrawable> entry, DragEndDetails details) {
    setState(() {
      controlsAreActive[controlIndex] = false;
    });
    onDrawableScaleEnd(entry);
  }

  void onScaleControlPanStart(int controlIndex,
      MapEntry<int, ObjectDrawable> entry, DragStartDetails details) {
    setState(() {
      controlsAreActive[controlIndex] = true;
      // Store the initial click position in the control's coordinate space
      controlInitialLocalPositions[controlIndex] = details.localPosition;
    });
    onDrawableScaleStart(
        entry,
        ScaleStartDetails(
          pointerCount: 1,
          localFocalPoint: entry.value.position,
        ));
  }

  void onScaleControlPanUpdate(
      int controlIndex,
      MapEntry<int, ObjectDrawable> entry,
      DragUpdateDetails details,
      BoxConstraints constraints,
      [bool isReversed = true]) {
    final index = entry.key;
    final initial = initialScaleDrawables[index];
    if (initial == null) return;

    // Get the initial click position on the control
    final initialClickPos =
        controlInitialLocalPositions[controlIndex] ?? Offset.zero;

    // Calculate the delta from where you initially clicked
    final delta = details.localPosition.dx - initialClickPos.dx;

    // Use the delta as the length (how far you've dragged from the initial click)
    final length = delta * (isReversed ? -1 : 1);
    final initialSize = initial.getSize(maxWidth: constraints.maxWidth);
    final initialLength = initialSize.width / 2;
    final double scale = initialLength == 0
        ? (length * 2)
        : ((length + initialLength) / initialLength);
    onDrawableScaleUpdate(
        entry,
        ScaleUpdateDetails(
          pointerCount: 1,
          rotation: 0,
          scale: scale.clamp(ObjectDrawable.minScale, double.infinity),
          localFocalPoint: entry.value.position,
        ));
  }

  void onScaleControlPanEnd(int controlIndex,
      MapEntry<int, ObjectDrawable> entry, DragEndDetails details) {
    setState(() {
      controlsAreActive[controlIndex] = false;
      // Clean up the stored initial position
      controlInitialLocalPositions.remove(controlIndex);
    });
    onDrawableScaleEnd(entry);
  }

  void onResizeControlPanStart(int controlIndex,
      MapEntry<int, ObjectDrawable> entry, DragStartDetails details) {
    setState(() {
      controlsAreActive[controlIndex] = true;
    });
    onDrawableScaleStart(
        entry,
        ScaleStartDetails(
          pointerCount: 1,
          localFocalPoint: entry.value.position,
        ));
  }

  void onResizeControlPanUpdate(MapEntry<int, ObjectDrawable> entry,
      DragUpdateDetails details, BoxConstraints constraints, Axis axis,
      [bool isReversed = true]) {
    final index = entry.key;

    final drawable = entry.value;

    if (drawable is! Sized2DDrawable) return;

    final initial = initialScaleDrawables[index];
    if (initial is! Sized2DDrawable?) return;

    if (initial == null) return;
    final vertical = axis == Axis.vertical;
    final length =
        ((vertical ? details.localPosition.dy : details.localPosition.dx) *
            (isReversed ? -1 : 1));
    final initialLength = vertical ? initial.size.height : initial.size.width;

    final totalLength = (length / initial.scale + initialLength)
        .clamp(0, double.infinity) as double;

    // When the gesture detector is rotated, the hit test details are not transformed with it
    // This causes events from rotated objects to behave incorrectly
    // So, a [Matrix4] is used to transform the needed event details to be consistent with
    // the current rotation of the object

    final offsetPosition = Offset(
      vertical ? 0 : (isReversed ? -1 : 1) * length / 2,
      vertical ? (isReversed ? -1 : 1) * length / 2 : 0,
    );

    final rotateOffset = Matrix4.identity()
      ..rotateZ(initial.rotationAngle)
      ..translate(offsetPosition.dx, offsetPosition.dy)
      ..rotateZ(-initial.rotationAngle);
    final position = Offset(rotateOffset[12], rotateOffset[13]);

    final newDrawable = drawable.copyWith(
      size: Size(
        vertical ? drawable.size.width : totalLength,
        vertical ? totalLength : drawable.size.height,
      ),
      position: initial.position + position,
    );

    updateDrawable(drawable, newDrawable);
  }

  void onResizeControlPanEnd(int controlIndex,
      MapEntry<int, ObjectDrawable> entry, DragEndDetails details) {
    setState(() {
      controlsAreActive[controlIndex] = false;
    });
    onDrawableScaleEnd(entry);
  }

  /// A callback that is called when a transformation occurs in the [InteractiveViewer] in the widget tree.
  void onTransformUpdated() {
    setState(() {
      final m4storage =
          PainterController.of(context).transformationController.value;
      transformationScale = math.sqrt(m4storage[8] * m4storage[8] +
          m4storage[9] * m4storage[9] +
          m4storage[10] * m4storage[10]);
    });
  }

  /// Image stretch control pan start handler
  void onImageStretchControlPanStart(int controlIndex,
      MapEntry<int, ObjectDrawable> entry, DragStartDetails details) {
    setState(() {
      controlsAreActive[controlIndex] = true;
    });
    onDrawableScaleStart(
        entry,
        ScaleStartDetails(
          pointerCount: 1,
          localFocalPoint: entry.value.position,
        ));
  }

  /// Image stretch control pan update handler
  void onImageStretchControlPanUpdate(MapEntry<int, ObjectDrawable> entry,
      DragUpdateDetails details, BoxConstraints constraints, Axis axis,
      [bool isReversed = true]) {
    final index = entry.key;
    final drawable = entry.value;

    if (drawable is! ImageDrawable) return;

    final initial = initialScaleDrawables[index];
    if (initial == null || initial is! ImageDrawable) return;

    final vertical = axis == Axis.vertical;
    final length =
        ((vertical ? details.localPosition.dy : details.localPosition.dx) *
            (isReversed ? -1 : 1));

    // Calculate the new scale based on the drag distance for the specific axis
    final initialSize = initial.getSize(maxWidth: constraints.maxWidth);
    final initialLength = vertical ? initialSize.height : initialSize.width;

    final scaleFactor =
        initialLength == 0 ? 1.0 : (length / initialLength + 1.0);
    final newScaleFactor =
        scaleFactor.clamp(ObjectDrawable.minScale, double.infinity);

    // Apply scaling only to the specific axis
    final newScaleX =
        vertical ? initial.scaleX : initial.scaleX * newScaleFactor;
    final newScaleY =
        vertical ? initial.scaleY * newScaleFactor : initial.scaleY;

    // Calculate the new position to keep the opposite edge fixed
    final offsetPosition = Offset(
      vertical ? 0 : (isReversed ? -1 : 1) * length / 2,
      vertical ? (isReversed ? -1 : 1) * length / 2 : 0,
    );

    // Apply rotation transformation to the offset
    final rotateOffset = Matrix4.identity()
      ..rotateZ(initial.rotationAngle)
      ..translate(offsetPosition.dx, offsetPosition.dy)
      ..rotateZ(-initial.rotationAngle);
    final position = Offset(rotateOffset[12], rotateOffset[13]);

    final newDrawable = drawable.copyWith(
      scaleX: newScaleX,
      scaleY: newScaleY,
      position: initial.position + position,
    );

    updateDrawable(drawable, newDrawable);
  }

  /// Image stretch control pan end handler
  void onImageStretchControlPanEnd(int controlIndex,
      MapEntry<int, ObjectDrawable> entry, DragEndDetails details) {
    setState(() {
      controlsAreActive[controlIndex] = false;
    });
    onDrawableScaleEnd(entry);
  }
}
