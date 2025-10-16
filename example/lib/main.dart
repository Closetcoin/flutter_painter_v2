import 'dart:async';
import 'dart:math';

import 'package:example/app_image.dart';
import 'package:example/app_image_picker_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_painter_v2/flutter_painter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      final appContainer = ProviderContainer();

      runApp(
        UncontrolledProviderScope(container: appContainer, child: MyApp()),
      );
    },
    (error, st) {
      print('Uncaught error: $error');
      print('Stack trace: $st');
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const OutfitCreatorScreen(),
    );
  }
}

class OutfitCreatorScreen extends HookConsumerWidget {
  const OutfitCreatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final painterSide = useState(0.0);
    final isRendering = useState(false);
    final controller = _usePainterController();
    final canUndo = useListenableSelector(controller, () => controller.canUndo);
    final canRedo = useListenableSelector(controller, () => controller.canRedo);
    final canFlipSelected = useListenableSelector(
      controller,
      () => controller.canFlipSelected,
    );
    final canMoveSelectedBackward = useListenableSelector(
      controller,
      () => controller.canMoveSelectedBackward,
    );
    final canMoveSelectedForward = useListenableSelector(
      controller,
      () => controller.canMoveSelectedForward,
    );
    final canMoveSelectedToBack = useListenableSelector(
      controller,
      () => controller.canMoveSelectedToBack,
    );
    final canMoveSelectedToFront = useListenableSelector(
      controller,
      () => controller.canMoveSelectedToFront,
    );
    final hasSelectedDrawable = useListenableSelector(
      controller,
      () => controller.hasSelectedDrawable,
    );
    final hasDrawables = useListenableSelector(
      controller,
      () => controller.hasDrawables,
    );
    final isObjectEraseMode = useListenableSelector(
      controller,
      () => controller.isObjectEraseMode,
    );
    final selectedHasErasePaths = useListenableSelector(
      controller,
      () => controller.selectedHasErasePaths,
    );
    final strokeWidth = useListenableSelector(
      controller,
      () => controller.freeStyleSettings.strokeWidth,
    );
    final showSelectionIndicator = useListenableSelector(
      controller,
      () => controller.objectSettings.selectionIndicatorSettings.enabled,
    );
    final singleObjectMode = useListenableSelector(
      controller,
      () => controller.objectSettings.singleObjectMode,
    );
    final isRemovingBackground = useListenableSelector(
      controller,
      () => controller.isRemovingBackground,
    );

    final imagePickerNotifier = ref.read(appImagePickerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Outfit Creator')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: _ExpandedSquare(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    painterSide.value = min(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );

                    return SizedBox.square(
                      dimension: painterSide.value,
                      child: FlutterPainter(controller: controller),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton(
                        onPressed: canUndo ? () => controller.undo() : null,
                        child: Text('Undo'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: canRedo ? () => controller.redo() : null,
                        child: Text('Redo'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: canFlipSelected
                            ? () => controller.flipSelectedImageHorizontally()
                            : null,
                        child: Text('Flip'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: canMoveSelectedBackward
                            ? () => controller.sendSelectedBackward()
                            : null,
                        child: Text('Send Backward'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: canMoveSelectedForward
                            ? () => controller.sendSelectedForward()
                            : null,
                        child: Text('Send Forward'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: canMoveSelectedToBack
                            ? () => controller.sendSelectedToBack()
                            : null,
                        child: Text('Send to Back'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: canMoveSelectedToFront
                            ? () => controller.sendSelectedToFront()
                            : null,
                        child: Text('Send to Front'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: hasSelectedDrawable
                            ? () => controller.removeSelectedDrawable()
                            : null,
                        child: Text('Remove'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: hasDrawables
                            ? () => controller.clearDrawables()
                            : null,
                        child: Text('Clear'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: hasSelectedDrawable
                            ? () => controller.freeStyleMode = isObjectEraseMode
                                ? FreeStyleMode.none
                                : FreeStyleMode.eraseObject
                            : null,
                        child: Text(
                          'Erase Object',
                          style: TextStyle(
                            color: isObjectEraseMode ? Colors.red : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: selectedHasErasePaths
                            ? () => controller.clearErasePathsFromSelected()
                            : null,
                        child: Text('Clear Erases'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => controller.objectSettings =
                            controller.objectSettings.copyWith(
                          selectionIndicatorSettings: controller
                              .objectSettings.selectionIndicatorSettings
                              .copyWith(
                            enabled: !showSelectionIndicator,
                          ),
                        ),
                        child: Text(
                          showSelectionIndicator
                              ? 'Hide Indicator'
                              : 'Show Indicator',
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: singleObjectMode
                              ? Colors.blue.withOpacity(0.2)
                              : null,
                        ),
                        onPressed: () => controller.objectSettings =
                            controller.objectSettings.copyWith(
                          singleObjectMode: !singleObjectMode,
                        ),
                        child: Text(
                          singleObjectMode
                              ? 'Single Object: ON'
                              : 'Single Object: OFF',
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: isRemovingBackground
                              ? Colors.blue.withValues(alpha: 0.2)
                              : null,
                        ),
                        onPressed: isRemovingBackground || !hasSelectedDrawable
                            ? null
                            : () {
                                if (controller
                                    .selectedObjectBackgroundRemoved) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Background already removed'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                controller.removeBackgroundFromSelected(
                                  onError: (error) {
                                    if (!context.mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: $error'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  },
                                );
                              },
                        child: isRemovingBackground
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Remove Background'),
                      ),
                    ],
                  ),
                  if (isObjectEraseMode) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Stroke Width'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Slider.adaptive(
                            min: 2,
                            max: 25,
                            value: strokeWidth,
                            onChanged: (value) => controller.freeStyleSettings =
                                controller.freeStyleSettings
                                    .copyWith(strokeWidth: value),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: const Text('Add photo'),
                  onPressed: () async {
                    final pickedImage =
                        await imagePickerNotifier.pickFromGallery();
                    if (pickedImage != null) {
                      final image = await pickedImage.toUiImage();

                      // Calculate the maximum available size accounting for UI chrome
                      final canvasSize =
                          Size(painterSide.value, painterSide.value);
                      final maxContentSize =
                          controller.getMaxContentSize(canvasSize);

                      controller.addImage(
                        image,
                        Size(
                          min(maxContentSize.width, image.width.toDouble()),
                          min(maxContentSize.height, image.height.toDouble()),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: isRendering.value ? Colors.grey : null,
                  ),
                  onPressed: () async {
                    isRendering.value = true;
                    final image =
                        await controller.renderImage(Size(1920, 1920));
                    final bytes = await image.pngBytes;
                    isRendering.value = false;
                    if (!context.mounted) return;

                    if (bytes == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to render image')),
                      );
                      return;
                    }

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Rendered Image'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppImage.memory(
                              memory: bytes,
                              showLoading: true,
                              imageViewerOnTap: true,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: const Text('Render'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _ExpandedSquare extends StatelessWidget {
  final Widget child;

  const _ExpandedSquare({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = min(constraints.maxWidth, constraints.maxHeight);

        return SizedBox.square(dimension: side, child: child);
      },
    );
  }
}

PainterController _usePainterController() => useRef(
      PainterController(
        settings: PainterSettings(
          freeStyle: FreeStyleSettings(strokeWidth: 5),
          object: ObjectSettings(
            autoSelectAfterAdd: true,
            singleObjectMode: true,
            stretchControlsSettings: StretchControlsSettings(
              controlSize: 4.0,
              tapTargetSize: 4,
              controlOffset: 0.0,
              inactiveColor: Colors.white,
              activeColor: Colors.blue,
              borderColor: Colors.blue,
              borderWidth: 1.0,
              controlShape: BoxShape.rectangle,
              enabled: true,
              showVerticalControls: true,
              showHorizontalControls: true,
            ),
            selectionIndicatorSettings: SelectionIndicatorSettings(
              borderRadius: 0,
              borderColor: Colors.blue,
              borderWidth: 2.0,
              padding: 20.0,
              enabled: true,
            ),
          ),
        ),
      ),
    ).value;
