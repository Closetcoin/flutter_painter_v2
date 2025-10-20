import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'events/selected_object_drawable_removed_event.dart';
import '../views/widgets/painter_controller_widget.dart';
import 'actions/actions.dart';
import 'background_remover/background_remover_util.dart';
import 'drawables/image_drawable.dart';
import 'events/events.dart';
import 'drawables/background/background_drawable.dart';
import 'drawables/object_drawable.dart';
import 'settings/settings.dart';
import '../views/painters/painter.dart';

import 'drawables/drawable.dart';

/// Controller used to control a [FlutterPainter] widget.
///
/// * IMPORTANT: *
/// Each [FlutterPainter] should have its own controller.
class PainterController extends ValueNotifier<PainterControllerValue> {
  /// A controller for an event stream which widgets will listen to.
  ///
  /// This will dispatch events that represent actions, such as adding a new text drawable.
  final StreamController<PainterEvent> _eventsSteamController;

  /// This key will be used by the [FlutterPainter] widget assigned this controller.
  ///
  /// * IMPORTANT: *
  /// DO NOT ASSIGN this key on any widget,
  /// it is automatically used inside the [FlutterPainter] controlled by `this`.
  ///
  /// However, you can use to to grab information about the render object, etc...
  final GlobalKey painterKey;

  /// This controller will be used by the [InteractiveViewer] in [FlutterPainter] to notify
  /// children widgets of transformation changes.
  ///
  /// * IMPORTANT: *
  /// DO NOT ASSIGN this controller to any widget,
  /// it is automatically used inside the [InteractiveViewer] in [FlutterPainter] controller by `this`.
  ///
  /// However, you can use it to grab information about the transformations.
  final TransformationController transformationController;

  /// Whether the controller is currently removing a background from an image.
  bool _isRemovingBackground = false;

  /// Whether the controller is currently removing a background from an image.
  ///
  /// This can be used in the UI to show loading indicators.
  bool get isRemovingBackground => _isRemovingBackground;

  /// Whether the controller is currently performing smart crop on an image.
  bool _isSmartCropping = false;

  /// Whether the controller is currently performing smart crop on an image.
  ///
  /// This can be used in the UI to show loading indicators.
  bool get isSmartCropping => _isSmartCropping;

  /// Whether the currently selected object has had its background removed.
  ///
  /// Returns `true` if the selected drawable is an [ImageDrawable] with
  /// [ImageDrawable.backgroundRemoved] set to true, `false` otherwise.
  bool get selectedObjectBackgroundRemoved {
    final selected = selectedObjectDrawable;
    return selected is ImageDrawable && selected.backgroundRemoved;
  }

  /// Create a [PainterController].
  ///
  /// The behavior of a [FlutterPainter] widget is controlled by [settings].
  /// The controller can be initialized with a list of [drawables]
  /// to be painted without user interaction.
  /// It can also accept a [background] to be painted.
  /// Without it, the background will be transparent.
  PainterController({
    PainterSettings settings = const PainterSettings(),
    List<Drawable>? drawables = const [],
    BackgroundDrawable? background,
  }) : this.fromValue(PainterControllerValue(
            settings: settings,
            drawables: drawables ?? const [],
            background: background));

  /// Create a [PainterController] from a [PainterControllerValue].
  PainterController.fromValue(PainterControllerValue value)
      : _eventsSteamController = StreamController<PainterEvent>.broadcast(),
        painterKey = GlobalKey(),
        transformationController = TransformationController(),
        super(value);

  /// The stream of [PainterEvent]s dispatched from this controller.
  ///
  /// This stream is for children widgets of [FlutterPainter] to listen to external events.
  /// For example, adding a new text drawable.
  Stream<PainterEvent> get events => _eventsSteamController.stream;

  /// Setting this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set background(BackgroundDrawable? background) =>
      value = value.copyWith(background: background);

  /// Queues used to track the actions performed on drawables in the controller.
  /// This is used to [undo] and [redo] actions.
  Queue<ControllerAction> performedActions = DoubleLinkedQueue(),
      unperformedActions = DoubleLinkedQueue();

  /// Uses the [PainterControllerWidget] inherited widget to fetch the [PainterController] instance in this context.
  /// This is used internally in the library to fetch the controller at different widgets.
  static PainterController of(BuildContext context) {
    return PainterControllerWidget.of(context).controller;
  }

  /// Add the [drawables] to the controller value drawables.
  ///
  /// If [newAction] is `true`, the action is added as an independent action
  /// and can be [undo]ne in the future. If it is `false`, the action is connected to the
  /// previous action and is merged with it.
  ///
  /// If `singleObjectMode` is enabled in object settings and any of the drawables
  /// being added are [ObjectDrawable]s, all existing [ObjectDrawable]s will be
  /// removed before adding the new ones.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  void addDrawables(Iterable<Drawable> drawables, {bool newAction = true}) {
    // If single object mode is enabled and we're adding object drawables,
    // remove existing object drawables first
    if (value.settings.object.singleObjectMode) {
      final addingObjectDrawables =
          drawables.any((drawable) => drawable is ObjectDrawable);
      if (addingObjectDrawables) {
        final existingObjectDrawables =
            value.drawables.whereType<ObjectDrawable>().toList();
        if (existingObjectDrawables.isNotEmpty) {
          // Remove all existing object drawables
          for (final drawable in existingObjectDrawables) {
            removeDrawable(drawable, newAction: false);
          }
        }
      }
    }

    final action = AddDrawablesAction(drawables.toList());
    action.perform(this);
    _addAction(action, newAction);
  }

  /// Inserts the [drawables] to the controller value drawables at the provided [index].
  ///
  /// If [newAction] is `true`, the action is added as an independent action
  /// and can be [undo]ne in the future. If it is `false`, the action is connected to the
  /// previous action and is merged with it.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  void insertDrawables(int index, Iterable<Drawable> drawables,
      {bool newAction = true}) {
    final action = InsertDrawablesAction(index, drawables.toList());
    action.perform(this);
    _addAction(action, newAction);
  }

  /// Replace [oldDrawable] with [newDrawable] in the controller value.
  ///
  /// Returns `true` if [oldDrawable] was found and replaced, `false` otherwise.
  /// If the return value is `false`, the controller value is unaffected.
  ///
  /// If [newAction] is `true`, the action is added as an independent action
  /// and can be [undo]ne in the future. If it is `false`, the action is connected to the
  /// previous action and is merged with it.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  ///
  /// [notifyListeners] will not be called if the return value is `false`.
  bool replaceDrawable(Drawable oldDrawable, Drawable newDrawable,
      {bool newAction = true}) {
    final action = ReplaceDrawableAction(oldDrawable, newDrawable);
    final value = action.perform(this);
    if (value) _addAction(action, newAction);
    return value;
  }

  /// Removes the first occurrence of [drawable] from the controller value.
  ///
  /// Returns `true` if [drawable] was in the controller value, `false` otherwise.
  ///
  /// If [newAction] is `true`, the action is added as an independent action
  /// and can be [undo]ne in the future. If it is `false`, the action is connected to the
  /// previous action and is merged with it.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  ///
  /// [notifyListeners] will not be called if the return value is `false`.
  bool removeDrawable(Drawable drawable, {bool newAction = true}) {
    final action = RemoveDrawableAction(drawable);
    final value = action.perform(this);
    _addAction(action, newAction);
    return value;
  }

  /// Removes the last drawable from the controller value.
  ///
  /// If [newAction] is `true`, the action is added as an independent action
  /// and can be [undo]ne in the future. If it is `false`, the action is connected to the
  /// previous action and is merged with it.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  ///
  /// [notifyListeners] will not be called if there are no drawables in the controller value.
  void removeLastDrawable({bool newAction = true}) {
    removeDrawable(value.drawables.last);
  }

  /// Removes all drawables from the controller value.
  ///
  /// If [newAction] is `true`, the action is added as an independent action
  /// and can be [undo]ne in the future. If it is `false`, the action is connected to the
  /// previous action and is merged with it.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  void clearDrawables({bool newAction = true}) {
    final action = ClearDrawablesAction();
    action.perform(this);
    _addAction(action, newAction);
  }

  /// Groups all drawables in the controller into one drawable.
  ///
  /// This is used when an erase drawable is added, to prevent modifications to previous drawables.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  void groupDrawables({bool newAction = true}) {
    final action = MergeDrawablesAction();
    action.perform(this);
    _addAction(action, newAction);
  }

  void _addAction(ControllerAction action, bool newAction) {
    performedActions.add(action);
    if (!newAction) _mergeAction();
    unperformedActions.clear();
  }

  /// Whether an [undo] operation can be performed or not.
  bool get canUndo => performedActions.isNotEmpty;

  /// Whether a [redo] operation can be performed or not.
  bool get canRedo => unperformedActions.isNotEmpty;

  /// Undoes the last action performed on drawables. The action can later be [redo]ne.
  ///
  /// If [canUndo] is `false`, nothing happens and [notifyListeners] is not called.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  void undo() {
    if (!canUndo) return;
    final action = performedActions.removeLast();
    action.unperform(this);
    unperformedActions.add(action);
    // Notify listeners because canRedo depends on unperformedActions
    // which was just updated after the action's notifyListeners was called
    notifyListeners();
  }

  /// Redoes the last [undo]ne action. The redo operation can be [undo]ne.
  ///
  /// If [canRedo] is `false`, nothing happens and [notifyListeners] is not called.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  void redo() {
    if (!canRedo) return;
    final action = unperformedActions.removeLast();
    action.perform(this);
    performedActions.add(action);
    // Notify listeners because canUndo depends on performedActions
    // which was just updated after the action's notifyListeners was called
    notifyListeners();
  }

  /// Merges a newly added action with the previous action.
  void _mergeAction() {
    if (performedActions.length < 2) return;
    final second = performedActions.removeLast();
    final first = performedActions.removeLast();
    final groupedAction = second.merge(first);

    if (groupedAction != null) performedActions.add(groupedAction);
  }

  /// Dispatches a [AddTextPainterEvent] on `events` stream.
  void addText() {
    _eventsSteamController.add(const AddTextPainterEvent());
  }

  /// Adds an [ImageDrawable] to the center of the painter.
  ///
  /// If [size] is provided, the drawable will scaled to fit that size.
  /// If not, it will take the original image's size.
  ///
  /// If [autoSelectAfterAdd] is `true` in the object settings, the newly added
  /// image will be automatically selected.
  ///
  /// Note that if the painter is not rendered yet (for example, this method was used in the initState method),
  /// the drawable position will be [Offset.zero].
  /// If you face this issue, call this method in a post-frame callback.
  /// ```dart
  /// void initState(){
  ///   super.initState();
  ///   WidgetsBinding.instance?.addPostFrameCallback((timestamp){
  ///     controller.addImage(myImage);
  ///   });
  /// }
  /// ```
  void addImage(ui.Image image, [Size? size]) {
    // Calculate the center of the painter
    final renderBox =
        painterKey.currentContext?.findRenderObject() as RenderBox?;
    final center = renderBox == null
        ? Offset.zero
        : Offset(
            renderBox.size.width / 2,
            renderBox.size.height / 2,
          );

    final ImageDrawable drawable;

    if (size == null) {
      drawable = ImageDrawable(image: image, position: center);
    } else {
      drawable = ImageDrawable.fittedToSize(
          image: image, position: center, size: size);
    }

    addDrawables([drawable]);

    // Auto-select the drawable if the setting is enabled
    if (value.settings.object.autoSelectAfterAdd) {
      selectObjectDrawable(drawable);
    }
  }

  /// Calculates the maximum available size for image content, accounting for
  /// the selection indicator, stretch controls, corner controls, and tap target areas.
  ///
  /// This is useful when adding an image and you want it to fit within the
  /// visible canvas without being cropped by UI elements.
  ///
  /// [canvasSize] is the total size of the painter canvas (e.g., from RenderBox).
  /// [transformationScale] is the current zoom level (defaults to 1.0 for initial sizing).
  ///
  /// Returns a [Size] representing the maximum dimensions available for image content.
  Size getMaxContentSize(Size canvasSize, {double transformationScale = 1.0}) {
    final objectSettings = value.settings.object;
    final stretchControlsSettings = objectSettings.stretchControlsSettings;
    final accessibilityControlsSettings = objectSettings.accessibilityControls;

    // Calculate object padding (selection indicator padding)
    final objectPadding =
        objectSettings.selectionIndicatorSettings.padding / transformationScale;

    // Calculate stretch controls size (clamped between 8.0 and 50.0)
    final stretchControlsSize =
        (stretchControlsSettings.controlSize / transformationScale)
            .clamp(8.0, 50.0);

    // Calculate stretch controls offset
    final stretchControlsOffset =
        stretchControlsSettings.controlOffset / transformationScale;

    // Calculate the extension needed for stretch controls and tap targets
    // This only applies when stretch controls are enabled
    final stretchControlsExtension = stretchControlsSettings.enabled
        ? stretchControlsOffset +
            (stretchControlsSize * stretchControlsSettings.tapTargetSize / 2)
        : 0.0;

    // Calculate corner controls (rotation/scale) size
    final cornerControlsSize =
        accessibilityControlsSettings.controlSize / transformationScale;

    // Calculate corner controls offset
    final cornerControlsOffset =
        accessibilityControlsSettings.cornerOffset / transformationScale;

    // Calculate the extension needed for corner controls
    // This applies when rotation or scale controls are enabled
    final showCornerControls =
        accessibilityControlsSettings.showRotationControl ||
            accessibilityControlsSettings.showScaleControl;
    final cornerControlsExtension = showCornerControls
        ? cornerControlsOffset + (cornerControlsSize / 2)
        : 0.0;

    // Use the max of stretch or corner controls extension (not sum)
    // since they overlap at the corners
    final maxControlsExtension =
        stretchControlsExtension > cornerControlsExtension
            ? stretchControlsExtension
            : cornerControlsExtension;

    // Total padding on each side = objectPadding + maxControlsExtension
    final totalPaddingPerSide = objectPadding + maxControlsExtension;

    // Available content size = canvas size - (padding on both sides)
    final availableWidth = canvasSize.width - (totalPaddingPerSide * 2);
    final availableHeight = canvasSize.height - (totalPaddingPerSide * 2);

    return Size(
      availableWidth.clamp(0.0, double.infinity),
      availableHeight.clamp(0.0, double.infinity),
    );
  }

  /// Removes the background from the currently selected [ImageDrawable].
  ///
  /// This method processes the selected image using the background remover utility.
  /// The action can be undone/redone. All transformations (position, scale, rotation)
  /// are preserved.
  ///
  /// Settings for background removal and cropping are taken from the controller's
  /// [ObjectSettings.backgroundRemoverSettings] and [ObjectSettings.smartCroppingSettings].
  /// You can customize these when creating the controller or update them using
  /// [PainterController.value.settings.object.copyWith].
  ///
  /// **Note:** If the background has already been removed from the selected object,
  /// this method will return `false` without processing. Use [selectedObjectBackgroundRemoved]
  /// to check if background removal has already been applied.
  ///
  /// **Note:** If the selected object has erase masks applied, cropping will be
  /// automatically disabled to preserve the erased areas, regardless of the cropping settings.
  ///
  /// [onError]: Optional callback for error handling.
  ///
  /// Example usage:
  /// ```dart
  /// if (!controller.selectedObjectBackgroundRemoved) {
  ///   await controller.removeBackgroundFromSelected(
  ///     onError: (error) => print('Failed: $error'),
  ///   );
  /// }
  /// ```
  ///
  /// Returns `true` if successful, `false` if no ImageDrawable is selected,
  /// background has already been removed, or removal failed.
  Future<bool> removeBackgroundFromSelected({
    void Function(Object error)? onError,
  }) async {
    final selected = selectedObjectDrawable;
    if (selected is! ImageDrawable) {
      return false;
    }

    // Don't allow removing background if it's already been removed
    if (selected.backgroundRemoved) {
      return false;
    }

    try {
      _isRemovingBackground = true;
      notifyListeners();

      // Get settings from the controller
      final bgSettings = value.settings.object.backgroundRemoverSettings;
      final cropSettings = value.settings.object.smartCroppingSettings;

      // Call the background remover utility (without physical crop)
      final processedImage = await BackgroundRemoverUtil.removeBackground(
        inputImage: selected.image,
        threshold: bgSettings.threshold,
        smoothMask: bgSettings.smoothMask,
        enhanceEdges: bgSettings.enhanceEdges,
        padPx: bgSettings.padPx,
        applyCrop:
            false, // Don't physically crop - we'll use crop properties instead
        alphaThreshold: cropSettings.alphaThreshold,
        marginFrac: cropSettings.marginFrac,
        minSidePx: cropSettings.minSidePx,
        stride: cropSettings.stride,
      );

      // Create a new drawable with the processed image
      // Keep all the same properties (position, scale, rotation, etc.)
      // Set backgroundRemoved flag to true
      ImageDrawable processedDrawable = selected.copyWith(
        image: processedImage,
        backgroundRemoved: true,
      );

      // If smart cropping is enabled, apply crop properties
      // Note: Erase masks are properly handled - they get clipped to the cropped area
      if (cropSettings.enabled) {
        // Calculate smart crop using the processed image
        final byteData = await processedImage.toByteData(
          format: ui.ImageByteFormat.png,
        );

        if (byteData != null) {
          final pngBytes = byteData.buffer.asUint8List();

          final cropRect = await _calculateSmartCropRect(
            pngBytes: pngBytes,
            alphaThreshold: cropSettings.alphaThreshold,
            marginFrac: cropSettings.marginFrac,
            minSidePx: cropSettings.minSidePx,
            stride: cropSettings.stride,
          );

          if (cropRect != null) {
            final imageWidth = processedImage.width.toDouble();
            final imageHeight = processedImage.height.toDouble();

            // Convert crop rect to fractions
            final cropLeft = cropRect.left / imageWidth;
            final cropTop = cropRect.top / imageHeight;
            final cropRight = (imageWidth - cropRect.right) / imageWidth;
            final cropBottom = (imageHeight - cropRect.bottom) / imageHeight;

            // Apply crop values to the drawable
            processedDrawable = processedDrawable.copyWith(
              cropLeft: cropLeft,
              cropTop: cropTop,
              cropRight: cropRight,
              cropBottom: cropBottom,
            );
          }
        }
      }

      // Use the RemoveBackgroundAction for undo/redo support
      final action = RemoveBackgroundAction(selected, processedDrawable);
      final result = action.perform(this);
      if (result) {
        _addAction(action, true);
      }

      return result;
    } catch (error) {
      onError?.call(error);
      return false;
    } finally {
      _isRemovingBackground = false;
      notifyListeners();
    }
  }

  /// Applies a background-removed image to the currently selected [ImageDrawable].
  ///
  /// This creates a [RemoveBackgroundAction] that replaces the selected drawable
  /// with a new one using the [processedImage]. The action can be undone/redone.
  ///
  /// Returns `true` if the background removal was applied successfully, `false` otherwise.
  ///
  /// The [processedImage] should be the result from a background removal process.
  ///
  /// If there is no selected drawable or it's not an [ImageDrawable], returns `false`.
  bool applyBackgroundRemovedImage(ui.Image processedImage) {
    final selected = selectedObjectDrawable;
    if (selected is! ImageDrawable) {
      return false;
    }

    // Create a new drawable with the processed image
    // Keep all the same properties (position, scale, rotation, etc.)
    final processedDrawable = selected.copyWith(image: processedImage);

    // Use the RemoveBackgroundAction for undo/redo support
    final action = RemoveBackgroundAction(selected, processedDrawable);
    final result = action.perform(this);
    if (result) {
      _addAction(action, true);
    }
    return result;
  }

  /// Applies smart crop to the currently selected [ImageDrawable].
  ///
  /// Uses the same algorithm as background removal's smart crop, but instead of
  /// physically cropping the image, it applies crop values to the drawable.
  /// This allows undo/redo and properly handles erase masks.
  ///
  /// The crop finds the bounding box of opaque pixels and creates a square crop
  /// centered on the subject with a margin.
  ///
  /// Settings are taken from [value.settings.object.smartCroppingSettings].
  ///
  /// Returns `true` if successfully applied, `false` if no [ImageDrawable] is selected
  /// or smart crop detection fails.
  Future<bool> smartCropSelected() async {
    final selected = selectedObjectDrawable;
    if (selected is! ImageDrawable) {
      return false;
    }

    try {
      _isSmartCropping = true;
      notifyListeners();

      // Get smart cropping settings
      final cropSettings = value.settings.object.smartCroppingSettings;

      // Convert image to bytes for analysis
      final byteData = await selected.image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) return false;

      final pngBytes = byteData.buffer.asUint8List();

      // Calculate crop rect using the same logic as smart square crop
      final cropRect = await _calculateSmartCropRect(
        pngBytes: pngBytes,
        alphaThreshold: cropSettings.alphaThreshold,
        marginFrac: cropSettings.marginFrac,
        minSidePx: cropSettings.minSidePx,
        stride: cropSettings.stride,
      );

      if (cropRect == null) return false;

      final imageWidth = selected.image.width.toDouble();
      final imageHeight = selected.image.height.toDouble();

      // Convert crop rect to fractions
      final cropLeft = cropRect.left / imageWidth;
      final cropTop = cropRect.top / imageHeight;
      final cropRight = (imageWidth - cropRect.right) / imageWidth;
      final cropBottom = (imageHeight - cropRect.bottom) / imageHeight;

      // Apply crop values to the drawable
      final croppedDrawable = selected.copyWith(
        cropLeft: cropLeft,
        cropTop: cropTop,
        cropRight: cropRight,
        cropBottom: cropBottom,
      );

      replaceDrawable(selected, croppedDrawable);
      return true;
    } catch (e) {
      return false;
    } finally {
      _isSmartCropping = false;
      notifyListeners();
    }
  }

  /// Calculates the smart crop rectangle for an image.
  ///
  /// Returns a [Rect] representing the crop area in pixel coordinates,
  /// or null if detection fails.
  Future<Rect?> _calculateSmartCropRect({
    required Uint8List pngBytes,
    required int alphaThreshold,
    required double marginFrac,
    required int minSidePx,
    required int stride,
  }) async {
    try {
      // Decode using dart:ui
      final codec = await ui.instantiateImageCodec(pngBytes);
      final frame = await codec.getNextFrame();
      final decoded = frame.image;

      final w = decoded.width;
      final h = decoded.height;

      // Get pixel data
      final byteData = await decoded.toByteData();
      if (byteData == null) return null;

      // Find bbox of subject via alpha > threshold (strided for speed)
      int minX = w, minY = h, maxX = -1, maxY = -1;
      final clampedStride = stride.clamp(1, 8);

      for (int y = 0; y < h; y += clampedStride) {
        for (int x = 0; x < w; x += clampedStride) {
          final offset = (y * w + x) * 4;
          final alpha = byteData.getUint8(offset + 3);

          if (alpha > alphaThreshold) {
            if (x < minX) minX = x;
            if (y < minY) minY = y;
            if (x > maxX) maxX = x;
            if (y > maxY) maxY = y;
          }
        }
      }

      // If nothing opaque found, return centered square
      if (maxX < 0 || maxY < 0) {
        final minSide = w < h ? w : h;
        final side = minSide.clamp(minSidePx, minSide);
        final cx = w ~/ 2;
        final cy = h ~/ 2;
        final half = side ~/ 2;
        final left = (cx - half).clamp(0, w - side);
        final top = (cy - half).clamp(0, h - side);

        return Rect.fromLTWH(
          left.toDouble(),
          top.toDouble(),
          side.toDouble(),
          side.toDouble(),
        );
      }

      // Subject bbox (tight)
      final bboxW = maxX - minX + 1;
      final bboxH = maxY - minY + 1;
      final cx = (minX + maxX) ~/ 2;
      final cy = (minY + maxY) ~/ 2;

      // Square that contains the bbox + margin, centered on the bbox center
      final bboxMax = bboxW > bboxH ? bboxW : bboxH;
      int side = (bboxMax * (1.0 + marginFrac)).round();

      // Respect min/max bounds
      final maxSquare = w < h ? w : h;
      if (side < minSidePx) side = minSidePx;
      if (side > maxSquare) side = maxSquare;

      // Place square centered on bbox center, then clamp into image bounds
      int left = (cx - side / 2).floor();
      int top = (cy - side / 2).floor();
      if (left < 0) left = 0;
      if (top < 0) top = 0;
      if (left + side > w) left = w - side;
      if (top + side > h) top = h - side;

      return Rect.fromLTWH(
        left.toDouble(),
        top.toDouble(),
        side.toDouble(),
        side.toDouble(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Renders the background and all other drawables to a [ui.Image] object.
  ///
  /// The size of the output image is controlled by [size].
  /// All drawables will be scaled according to that image size.
  Future<ui.Image> renderImage(Size size) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final painter = Painter(
      drawables: value.drawables,
      scale: painterKey.currentContext?.size ?? size,
      background: value.background,
    );
    painter.paint(canvas, size);
    return await recorder
        .endRecording()
        .toImage(size.width.floor(), size.height.floor());
  }

  /// The currently selected object drawable.
  ObjectDrawable? get selectedObjectDrawable => value.selectedObjectDrawable;

  /// Selects an object drawable from the list of drawables.
  ///
  /// If the [drawable] is not in the list of drawables or is the same as
  /// [selectedObjectDrawable], nothing happens and [notifyListeners] is not called.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  void selectObjectDrawable(ObjectDrawable? drawable) {
    if (drawable == value.selectedObjectDrawable) return;
    if (drawable != null && !value.drawables.contains(drawable)) return;
    value = value.copyWith(
      selectedObjectDrawable: drawable,
    );
  }

  /// Deselects the object drawable from the drawables.
  ///
  /// [isRemoved] is whether the deselection happened because the selected
  /// object drawable was deleted. If so, the controller will send a
  /// [SelectedObjectDrawableRemovedEvent] to listening widgets.
  ///
  /// If [selectedObjectDrawable] is already `null`, nothing happens
  /// and [notifyListeners] is not called.
  ///
  /// In single object mode, deselection is prevented unless the object is being removed.
  ///
  /// Calling this will notify all the listeners of this [PainterController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  void deselectObjectDrawable({bool isRemoved = false}) {
    // In single object mode, prevent deselection unless the object is being removed
    if (value.settings.object.singleObjectMode && !isRemoved) {
      return;
    }

    if (selectedObjectDrawable != null && isRemoved) {
      _eventsSteamController.add(const SelectedObjectDrawableRemovedEvent());
    }
    selectObjectDrawable(null);
  }
}

/// The current paint mode, drawables and background values of a [FlutterPainter] widget.
@immutable
class PainterControllerValue {
  /// The current paint mode of the widget.
  final PainterSettings settings;

  /// The list of drawables currently present to be painted.
  final List<Drawable> _drawables;

  /// The current background drawable of the widget.
  final BackgroundDrawable? background;

  /// The currently selected object drawable.
  final ObjectDrawable? selectedObjectDrawable;

  /// Creates a new [PainterControllerValue] with the provided [settings] and [background].
  ///
  /// The user can pass a list of initial [drawables] which will be drawn without user interaction.
  const PainterControllerValue({
    required this.settings,
    List<Drawable> drawables = const [],
    this.background,
    this.selectedObjectDrawable,
  }) : _drawables = drawables;

  /// Getter for the current drawables.
  ///
  /// The returned list is unmodifiable.
  List<Drawable> get drawables => List.unmodifiable(_drawables);

  /// Creates a copy of this value but with the given fields replaced with the new values.
  PainterControllerValue copyWith({
    PainterSettings? settings,
    List<Drawable>? drawables,
    BackgroundDrawable? background =
        _NoBackgroundPassedBackgroundDrawable.instance,
    ObjectDrawable? selectedObjectDrawable =
        _NoObjectPassedBackgroundDrawable.instance,
  }) {
    return PainterControllerValue(
      settings: settings ?? this.settings,
      drawables: drawables ?? _drawables,
      background: background == _NoBackgroundPassedBackgroundDrawable.instance
          ? this.background
          : background,
      selectedObjectDrawable:
          selectedObjectDrawable == _NoObjectPassedBackgroundDrawable.instance
              ? this.selectedObjectDrawable
              : selectedObjectDrawable,
    );
  }

  /// Checks if two [PainterControllerValue] objects are equal or not.
  @override
  bool operator ==(Object other) {
    return other is PainterControllerValue &&
        (const ListEquality().equals(_drawables, other._drawables) &&
            background == other.background &&
            settings == other.settings &&
            selectedObjectDrawable == other.selectedObjectDrawable);
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(_drawables),
        background,
        settings,
        selectedObjectDrawable,
      );
}

/// Private class that is used internally to represent no
/// [BackgroundDrawable] argument passed for [PainterControllerValue.copyWith].
class _NoBackgroundPassedBackgroundDrawable extends BackgroundDrawable {
  /// Single instance.
  static const _NoBackgroundPassedBackgroundDrawable instance =
      _NoBackgroundPassedBackgroundDrawable._();

  /// Private constructor.
  const _NoBackgroundPassedBackgroundDrawable._() : super();

  /// Unimplemented implementation of the draw method.
  @override
  void draw(ui.Canvas canvas, ui.Size size) {
    throw UnimplementedError(
        "This background drawable is only to hold the default value in the PainterControllerValue copyWith method, and must not be used otherwise.");
  }
}

/// Private class that is used internally to represent no
/// [BackgroundDrawable] argument passed for [PainterControllerValue.copyWith].
class _NoObjectPassedBackgroundDrawable extends ObjectDrawable {
  /// Single instance.
  static const _NoObjectPassedBackgroundDrawable instance =
      _NoObjectPassedBackgroundDrawable._();

  /// Private constructor.
  const _NoObjectPassedBackgroundDrawable._()
      : super(
          position: const Offset(0, 0),
        );

  @override
  ObjectDrawable copyWith({
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    ui.Offset? position,
    double? rotation,
    double? scale,
    bool? locked,
    List<List<Offset>>? eraseMask,
  }) {
    throw UnimplementedError(
        "This object drawable is only to hold the default value in the PainterControllerValue copyWith method, and must not be used otherwise.");
  }

  @override
  void drawObject(ui.Canvas canvas, ui.Size size) {
    throw UnimplementedError(
        "This object drawable is only to hold the default value in the PainterControllerValue copyWith method, and must not be used otherwise.");
  }

  @override
  ui.Size getSize({double minWidth = 0.0, double maxWidth = double.infinity}) {
    throw UnimplementedError(
        "This object drawable is only to hold the default value in the PainterControllerValue copyWith method, and must not be used otherwise.");
  }
}
