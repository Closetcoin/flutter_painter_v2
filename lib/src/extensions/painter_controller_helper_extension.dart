import 'package:flutter/widgets.dart';
import '../controllers/factories/shape_factory.dart';

import '../controllers/painter_controller.dart';
import '../controllers/settings/settings.dart';
import '../controllers/drawables/drawables.dart';
import '../controllers/actions/move_drawable_action.dart';

/// Adds extra getters and setters in [PainterController] to make it easier to use.
///
/// This was made as an extension to not clutter up the [PainterController] class even more.
extension PainterControllerHelper on PainterController {
  /// The current painter settings directly from `value`.
  PainterSettings get settings => value.settings;

  /// The current background drawable directly from `value`.
  BackgroundDrawable? get background => value.background;

  /// The unmodifiable list of drawables directly from `value`.
  List<Drawable> get drawables => value.drawables;

  /// The object settings directly from the painter settings.
  ObjectSettings get objectSettings => settings.object;

  /// The text settings directly from the painter settings.
  TextSettings get textSettings => settings.text;

  /// The free-style settings directly from the painter settings.
  FreeStyleSettings get freeStyleSettings => settings.freeStyle;

  /// The shape settings directly from the painter settings.
  ShapeSettings get shapeSettings => settings.shape;

  /// The scale settings directly from the painter settings.
  ScaleSettings get scaleSettings => settings.scale;

  /// The current painter settings directly from `value`.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set settings(PainterSettings settings) =>
      value = value.copyWith(settings: settings);

  /// The current background drawable directly from `value`.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set background(BackgroundDrawable? background) => value = value.copyWith(
        background: background,
      );

  /// The object settings directly from the painter settings.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set objectSettings(ObjectSettings objectSettings) => value = value.copyWith(
          settings: settings.copyWith(
        object: objectSettings,
      ));

  /// The text settings directly from the painter settings.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set textSettings(TextSettings textSettings) => value = value.copyWith(
          settings: settings.copyWith(
        text: textSettings,
      ));

  /// The free-style settings directly from the painter settings.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set freeStyleSettings(FreeStyleSettings freeStyleSettings) =>
      value = value.copyWith(
          settings: settings.copyWith(
        freeStyle: freeStyleSettings,
      ));

  /// The shape settings directly from the painter settings.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set shapeSettings(ShapeSettings shapeSettings) => value = value.copyWith(
          settings: settings.copyWith(
        shape: shapeSettings,
      ));

  /// The scale settings directly from the painter settings.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set scaleSettings(ScaleSettings scaleSettings) => value = value.copyWith(
          settings: settings.copyWith(
        scale: scaleSettings,
      ));

  /// Accessibility settings for object controls from `value.settings.object` directly.
  AccessibilityControlsSettings get objectAccessibilityControls =>
      value.settings.object.accessibilityControls;

  /// The layout-assist settings of the selected object drawable from `value.settings.object` directly.
  ObjectLayoutAssistSettings get objectLayoutAssist =>
      value.settings.object.layoutAssist;

  /// The text style to be used for text drawables from `value.settings.text` directly.
  TextStyle get textStyle => value.settings.text.textStyle;

  /// The focus node used to edit text drawables text from `value.settings.text` directly.
  FocusNode? get textFocusNode => value.settings.text.focusNode;

  /// The free-style painting mode from `value.settings.freeStyle` directly.
  FreeStyleMode get freeStyleMode => value.settings.freeStyle.mode;

  /// The stroke width used for free-style drawing from `value.settings.freeStyle` directly.
  double get freeStyleStrokeWidth => value.settings.freeStyle.strokeWidth;

  /// The color used for free-style drawing from `value.settings.freeStyle` directly.
  Color get freeStyleColor => value.settings.freeStyle.color;

  /// The paint used to draw shapes from `value.settings.shape` directly.
  Paint? get shapePaint => value.settings.shape.paint;

  /// Whether to draw shapes once or continuously from `value.settings.shape` directly.
  bool get drawShapeOnce => value.settings.shape.drawOnce;

  /// The factory for the shape to be drawn from `value.settings.shape` directly.
  ShapeFactory? get shapeFactory => value.settings.shape.factory;

  /// The minimum scale that the user can "zoom out" to from `value.settings.scale` directly.
  double get minScale => value.settings.scale.minScale;

  /// The maximum scale that the user can "zoom in" to from `value.settings.scale` directly.
  double get maxScale => value.settings.scale.maxScale;

  /// Whether scaling is enabled or not from `value.settings.scale` directly.
  bool get scalingEnabled => value.settings.scale.enabled;

  /// The function used to decide whether to enlarge the object controls or not from `value.settings.object` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set objectAccessibilityControls(
          AccessibilityControlsSettings accessibilityControls) =>
      value = value.copyWith(
          settings: value.settings.copyWith(
              object: value.settings.object.copyWith(
        accessibilityControls: accessibilityControls,
      )));

  /// The layout-assist settings of the selected object drawable from `value.settings.object` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set objectLayoutAssist(ObjectLayoutAssistSettings layoutAssist) =>
      value = value.copyWith(
          settings: value.settings.copyWith(
              object: value.settings.object.copyWith(
        layoutAssist: layoutAssist,
      )));

  /// The text style to be used for text drawables from `value.settings.text` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set textStyle(TextStyle textStyle) => value = value.copyWith(
      settings: value.settings
          .copyWith(text: value.settings.text.copyWith(textStyle: textStyle)));

  /// The focus node used to edit text drawables text from `value.settings.text` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set textFocusNode(FocusNode? focusNode) => value = value.copyWith(
      settings: value.settings
          .copyWith(text: value.settings.text.copyWith(focusNode: focusNode)));

  /// The free-style painting mode from `value.settings.freeStyle` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set freeStyleMode(FreeStyleMode mode) => value = value.copyWith(
          settings: value.settings.copyWith(
              freeStyle: value.settings.freeStyle.copyWith(
        mode: mode,
      )));

  /// The stroke width used for free-style drawing from `value.settings.freeStyle` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set freeStyleStrokeWidth(double strokeWidth) => value = value.copyWith(
          settings: value.settings.copyWith(
              freeStyle: value.settings.freeStyle.copyWith(
        strokeWidth: strokeWidth,
      )));

  /// The color used for free-style drawing from `value.settings.freeStyle` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set freeStyleColor(Color color) => value = value.copyWith(
          settings: value.settings.copyWith(
              freeStyle: value.settings.freeStyle.copyWith(
        color: color,
      )));

  /// The paint used to draw shapes from `value.settings.shape` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set shapePaint(Paint? paint) => value = value.copyWith(
          settings: value.settings.copyWith(
              shape: value.settings.shape.copyWith(
        paint: paint,
      )));

  /// Whether to draw shapes once or continuously from `value.settings.shape` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set drawShapeOnce(bool drawOnce) => value = value.copyWith(
          settings: value.settings.copyWith(
              shape: value.settings.shape.copyWith(
        drawOnce: drawOnce,
      )));

  /// The factory for the shape to be drawn from `value.settings.shape` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set shapeFactory(ShapeFactory? factory) => value = value.copyWith(
          settings: value.settings.copyWith(
              shape: value.settings.shape.copyWith(
        factory: factory,
      )));

  /// The minimum scale that the user can "zoom out" to from `value.settings.scale` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set minScale(double minScale) => value = value.copyWith(
      settings: value.settings
          .copyWith(scale: value.settings.scale.copyWith(minScale: minScale)));

  /// The maximum scale that the user can "zoom in" to from `value.settings.scale` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set maxScale(double maxScale) => value = value.copyWith(
      settings: value.settings
          .copyWith(scale: value.settings.scale.copyWith(maxScale: maxScale)));

  /// Whether scaling is enabled or not from `value.settings.scale` directly.
  ///
  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set scalingEnabled(bool enabled) => value = value.copyWith(
      settings: value.settings
          .copyWith(scale: value.settings.scale.copyWith(enabled: enabled)));

  /// Flips the currently selected [ImageDrawable] horizontally.
  ///
  /// Returns `true` if the selected drawable is an [ImageDrawable] and was flipped successfully,
  /// `false` otherwise (if no drawable is selected or if the selected drawable is not an [ImageDrawable]).
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  bool flipSelectedImageHorizontally() {
    if (!canFlipSelected) return false;
    final selected = selectedObjectDrawable as ImageDrawable;
    replaceDrawable(
      selected,
      selected.copyWith(flipped: !selected.flipped),
    );
    return true;
  }

  /// Removes the currently selected object drawable.
  ///
  /// Returns `true` if a drawable was selected and removed successfully, `false` otherwise.
  ///
  /// If [newAction] is `true`, the action is added as an independent action
  /// and can be [undo]ne in the future. If it is `false`, the action is connected to the
  /// previous action and is merged with it.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  bool removeSelectedDrawable({bool newAction = true}) {
    if (!hasSelectedDrawable) return false;
    return removeDrawable(selectedObjectDrawable!, newAction: newAction);
  }

  /// Whether the currently selected object drawable can be moved forward (toward the front).
  ///
  /// Returns `true` if a drawable is selected and is not already at the front,
  /// `false` otherwise.
  bool get canMoveSelectedForward =>
      selectedObjectDrawable != null &&
      drawables.contains(selectedObjectDrawable!) &&
      drawables.indexOf(selectedObjectDrawable!) < drawables.length - 1;

  /// Whether the currently selected object drawable can be moved backward (toward the back).
  ///
  /// Returns `true` if a drawable is selected and is not already at the back,
  /// `false` otherwise.
  bool get canMoveSelectedBackward =>
      selectedObjectDrawable != null &&
      drawables.indexOf(selectedObjectDrawable!) > 0;

  /// Whether the currently selected object drawable can be moved to the front.
  ///
  /// Returns `true` if a drawable is selected and is not already at the front,
  /// `false` otherwise.
  bool get canMoveSelectedToFront => canMoveSelectedForward;

  /// Whether the currently selected object drawable can be moved to the back.
  ///
  /// Returns `true` if a drawable is selected and is not already at the back,
  /// `false` otherwise.
  bool get canMoveSelectedToBack => canMoveSelectedBackward;

  /// Whether there are any drawables that can be cleared.
  ///
  /// Returns `true` if there is at least one drawable, `false` otherwise.
  bool get hasDrawables => drawables.isNotEmpty;

  /// Whether there is a selected object drawable that can be removed.
  ///
  /// Returns `true` if a drawable is currently selected, `false` otherwise.
  bool get hasSelectedDrawable => selectedObjectDrawable != null;

  /// Whether the currently selected drawable is an [ImageDrawable] that can be flipped.
  ///
  /// Returns `true` if a drawable is selected and it is an [ImageDrawable],
  /// `false` otherwise.
  bool get canFlipSelected => selectedObjectDrawable is ImageDrawable;

  /// Adds an erase path to the currently selected object drawable.
  ///
  /// The [erasePath] is a list of offsets representing points along the erase stroke.
  /// These paths will be applied as masks when drawing the object, making those areas transparent
  /// and revealing what's underneath.
  ///
  /// Returns `true` if a drawable was selected and the erase path was added successfully,
  /// `false` otherwise.
  ///
  /// If [newAction] is `true`, the action is added as an independent action
  /// and can be [undo]ne in the future. If it is `false`, the action is connected to the
  /// previous action and is merged with it.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  bool addErasePathToSelected(List<Offset> erasePath, {bool newAction = true}) {
    if (!hasSelectedDrawable) return false;
    final selected = selectedObjectDrawable!;
    final newEraseMask = List<List<Offset>>.from(selected.eraseMask)
      ..add(erasePath);
    final newDrawable = selected.copyWith(eraseMask: newEraseMask);
    return replaceDrawable(selected, newDrawable, newAction: newAction);
  }

  /// Clears all erase paths from the currently selected object drawable.
  ///
  /// Returns `true` if a drawable was selected and had erase paths that were cleared,
  /// `false` otherwise.
  ///
  /// If [newAction] is `true`, the action is added as an independent action
  /// and can be [undo]ne in the future. If it is `false`, the action is connected to the
  /// previous action and is merged with it.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  bool clearErasePathsFromSelected({bool newAction = true}) {
    if (!hasSelectedDrawable) return false;
    final selected = selectedObjectDrawable!;
    if (selected.eraseMask.isEmpty) return false;
    final newDrawable = selected.copyWith(eraseMask: const []);
    return replaceDrawable(selected, newDrawable, newAction: newAction);
  }

  /// Whether the currently selected object drawable has any erase paths.
  ///
  /// Returns `true` if a drawable is selected and has erase mask paths,
  /// `false` otherwise.
  bool get selectedHasErasePaths =>
      hasSelectedDrawable && selectedObjectDrawable!.eraseMask.isNotEmpty;

  /// Whether the object erase mode is currently active.
  ///
  /// Returns `true` if the free-style mode is set to [FreeStyleMode.eraseObject],
  /// `false` otherwise.
  bool get isObjectEraseMode => freeStyleMode == FreeStyleMode.eraseObject;

  /// Moves a [drawable] to the front (end of the drawables list, drawn on top).
  ///
  /// Returns `true` if the drawable was found and moved successfully, `false` otherwise.
  ///
  /// If [newAction] is `true`, the action is added as an independent action
  /// and can be [undo]ne in the future. If it is `false`, the action is connected to the
  /// previous action and is merged with it.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  bool sendDrawableToFront(Drawable drawable, {bool newAction = true}) {
    final currentIndex = drawables.indexOf(drawable);
    if (currentIndex < 0 || currentIndex == drawables.length - 1) return false;
    return _moveDrawable(drawable, drawables.length - 1, newAction: newAction);
  }

  /// Moves the currently selected object drawable to the front (end of the drawables list, drawn on top).
  ///
  /// Returns `true` if a drawable was selected and moved successfully, `false` otherwise.
  ///
  /// If [newAction] is `true`, the action is added as an independent action
  /// and can be [undo]ne in the future. If it is `false`, the action is connected to the
  /// previous action and is merged with it.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  bool sendSelectedToFront({bool newAction = true}) {
    if (!canMoveSelectedToFront) return false;
    return sendDrawableToFront(selectedObjectDrawable!, newAction: newAction);
  }

  /// Moves a [drawable] to the back (beginning of the drawables list, drawn at the bottom).
  ///
  /// Returns `true` if the drawable was found and moved successfully, `false` otherwise.
  ///
  /// If [newAction] is `true`, the action is added as an independent action
  /// and can be [undo]ne in the future. If it is `false`, the action is connected to the
  /// previous action and is merged with it.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  bool sendDrawableToBack(Drawable drawable, {bool newAction = true}) {
    final currentIndex = drawables.indexOf(drawable);
    if (currentIndex <= 0) return false;
    return _moveDrawable(drawable, 0, newAction: newAction);
  }

  /// Moves the currently selected object drawable to the back (beginning of the drawables list, drawn at the bottom).
  ///
  /// Returns `true` if a drawable was selected and moved successfully, `false` otherwise.
  ///
  /// If [newAction] is `true`, the action is added as an independent action
  /// and can be [undo]ne in the future. If it is `false`, the action is connected to the
  /// previous action and is merged with it.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  bool sendSelectedToBack({bool newAction = true}) {
    if (!canMoveSelectedToBack) return false;
    return sendDrawableToBack(selectedObjectDrawable!, newAction: newAction);
  }

  /// Moves a [drawable] forward by one layer (one index forward in the drawables list).
  ///
  /// Returns `true` if the drawable was found and moved successfully, `false` otherwise.
  ///
  /// If [newAction] is `true`, the action is added as an independent action
  /// and can be [undo]ne in the future. If it is `false`, the action is connected to the
  /// previous action and is merged with it.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  bool sendDrawableForward(Drawable drawable, {bool newAction = true}) {
    final currentIndex = drawables.indexOf(drawable);
    if (currentIndex < 0 || currentIndex >= drawables.length - 1) return false;
    return _moveDrawable(drawable, currentIndex + 1, newAction: newAction);
  }

  /// Moves the currently selected object drawable forward by one layer (one index forward in the drawables list).
  ///
  /// Returns `true` if a drawable was selected and moved successfully, `false` otherwise.
  ///
  /// If [newAction] is `true`, the action is added as an independent action
  /// and can be [undo]ne in the future. If it is `false`, the action is connected to the
  /// previous action and is merged with it.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  bool sendSelectedForward({bool newAction = true}) {
    if (!canMoveSelectedForward) return false;
    return sendDrawableForward(selectedObjectDrawable!, newAction: newAction);
  }

  /// Moves a [drawable] backward by one layer (one index backward in the drawables list).
  ///
  /// Returns `true` if the drawable was found and moved successfully, `false` otherwise.
  ///
  /// If [newAction] is `true`, the action is added as an independent action
  /// and can be [undo]ne in the future. If it is `false`, the action is connected to the
  /// previous action and is merged with it.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  bool sendDrawableBackward(Drawable drawable, {bool newAction = true}) {
    final currentIndex = drawables.indexOf(drawable);
    if (currentIndex <= 0) return false;
    return _moveDrawable(drawable, currentIndex - 1, newAction: newAction);
  }

  /// Moves the currently selected object drawable backward by one layer (one index backward in the drawables list).
  ///
  /// Returns `true` if a drawable was selected and moved successfully, `false` otherwise.
  ///
  /// If [newAction] is `true`, the action is added as an independent action
  /// and can be [undo]ne in the future. If it is `false`, the action is connected to the
  /// previous action and is merged with it.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  bool sendSelectedBackward({bool newAction = true}) {
    if (!canMoveSelectedBackward) return false;
    return sendDrawableBackward(selectedObjectDrawable!, newAction: newAction);
  }

  /// Internal helper method to move a drawable to a specific index.
  bool _moveDrawable(Drawable drawable, int toIndex, {bool newAction = true}) {
    final action = MoveDrawableAction(drawable, toIndex);
    final result = action.perform(this);
    if (result) {
      performedActions.add(action);
      if (!newAction) _mergeAction();
      unperformedActions.clear();
    }
    return result;
  }

  /// Merges a newly added action with the previous action.
  void _mergeAction() {
    if (performedActions.length < 2) return;
    final second = performedActions.removeLast();
    final first = performedActions.removeLast();
    final groupedAction = second.merge(first);

    if (groupedAction != null) performedActions.add(groupedAction);
  }

  /// Snaps the currently selected object drawable to the nearest vertical snap line.
  ///
  /// This aligns the object's horizontal position (X) to either the canvas center or
  /// the center of the nearest object, whichever is closer. The vertical position (Y)
  /// is retained.
  ///
  /// Returns `true` if a drawable was selected and snapped successfully, `false` otherwise.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  bool snapSelectedToVertical() {
    if (!hasSelectedDrawable) return false;
    final selected = selectedObjectDrawable!;

    // Get canvas center
    final renderBox =
        painterKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return false;

    final canvasCenter = Offset(
      renderBox.size.width / 2,
      renderBox.size.height / 2,
    );

    // Find closest vertical target (X position)
    double? closestX;
    double closestDistance = double.infinity;

    // Check canvas center
    final distanceToCenter = (selected.position.dx - canvasCenter.dx).abs();
    if (distanceToCenter < closestDistance) {
      closestX = canvasCenter.dx;
      closestDistance = distanceToCenter;
    }

    // Check other objects' centers
    for (final drawable in drawables) {
      if (drawable == selected || drawable is! ObjectDrawable) continue;

      final distance = (selected.position.dx - drawable.position.dx).abs();
      if (distance < closestDistance) {
        closestX = drawable.position.dx;
        closestDistance = distance;
      }
    }

    // Snap to the closest target if found
    if (closestX != null) {
      replaceDrawable(
        selected,
        selected.copyWith(position: Offset(closestX, selected.position.dy)),
      );
      return true;
    }

    return false;
  }

  /// Snaps the currently selected object drawable to the nearest horizontal snap line.
  ///
  /// This aligns the object's vertical position (Y) to either the canvas center or
  /// the center of the nearest object, whichever is closer. The horizontal position (X)
  /// is retained.
  ///
  /// Returns `true` if a drawable was selected and snapped successfully, `false` otherwise.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  bool snapSelectedToHorizontal() {
    if (!hasSelectedDrawable) return false;
    final selected = selectedObjectDrawable!;

    // Get canvas center
    final renderBox =
        painterKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return false;

    final canvasCenter = Offset(
      renderBox.size.width / 2,
      renderBox.size.height / 2,
    );

    // Find closest horizontal target (Y position)
    double? closestY;
    double closestDistance = double.infinity;

    // Check canvas center
    final distanceToCenter = (selected.position.dy - canvasCenter.dy).abs();
    if (distanceToCenter < closestDistance) {
      closestY = canvasCenter.dy;
      closestDistance = distanceToCenter;
    }

    // Check other objects' centers
    for (final drawable in drawables) {
      if (drawable == selected || drawable is! ObjectDrawable) continue;

      final distance = (selected.position.dy - drawable.position.dy).abs();
      if (distance < closestDistance) {
        closestY = drawable.position.dy;
        closestDistance = distance;
      }
    }

    // Snap to the closest target if found
    if (closestY != null) {
      replaceDrawable(
        selected,
        selected.copyWith(position: Offset(selected.position.dx, closestY)),
      );
      return true;
    }

    return false;
  }
}
