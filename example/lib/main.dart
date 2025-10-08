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
    final isEraseMode = useListenableSelector(
      controller,
      () => controller.freeStyleMode == FreeStyleMode.erase,
    );
    final strokeWidth = useListenableSelector(
      controller,
      () => controller.freeStyleSettings.strokeWidth,
    );

    final imagePickerNotifier = ref.read(appImagePickerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Outfit Creator')),
      body: Column(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: canUndo ? () => controller.undo() : null,
                    child: Text(
                      'Undo',
                      style: TextStyle(
                        color: canUndo ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: canRedo ? () => controller.redo() : null,
                    child: Text(
                      'Redo',
                      style: TextStyle(
                        color: canRedo ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              TextButton(
                child: Text(
                  'Flip',
                ),
                onPressed: () => controller.flipSelectedImageHorizontally(),
              ),
              TextButton(
                child: Text(
                  'Erase',
                  style: TextStyle(
                    color: isEraseMode ? Colors.red : null,
                  ),
                ),
                onPressed: () => controller.freeStyleMode =
                    isEraseMode ? FreeStyleMode.none : FreeStyleMode.erase,
              ),
            ],
          ),
          if (isEraseMode) ...[
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
          const Spacer(),
          TextButton(
            child: const Text('Add photo'),
            onPressed: () async {
              final pickedImage = await imagePickerNotifier.pickFromGallery();
              if (pickedImage != null) {
                final image = await pickedImage.toUiImage();

                controller.addImage(
                  image,
                  Size(
                    min(painterSide.value, image.width.toDouble()),
                    min(painterSide.value, image.height.toDouble()),
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
              final image = await controller.renderImage(Size(1920, 1920));
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
        settings: PainterSettings(freeStyle: FreeStyleSettings(strokeWidth: 5)),
      ),
    ).value;
