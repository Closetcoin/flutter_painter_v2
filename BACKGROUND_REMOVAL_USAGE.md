# Background Removal - Simple Usage

## Overview

Background removal is now fully integrated into the `PainterController` with a super simple API. Just call one method!

## Quick Start

```dart
// Remove background from selected image
await controller.removeBackgroundFromSelected();
```

That's it! The controller handles everything internally.

## Features

### ✅ Loading State

The controller exposes a `bool isRemovingBackground` getter:

```dart
// In your UI
final isRemoving = useListenableSelector(
  controller,
  () => controller.isRemovingBackground,
);

ElevatedButton(
  onPressed: isRemoving ? null : () => removeBackground(),
  child: isRemoving 
      ? CircularProgressIndicator()
      : Text('Remove Background'),
)
```

### ✅ Error Handling

Use the `onError` callback:

```dart
await controller.removeBackgroundFromSelected(
  onError: (error) {
    print('Failed: $error');
    // Show error to user
  },
);
```

### ✅ Undo/Redo

Automatically supported:

```dart
// Remove background
await controller.removeBackgroundFromSelected();

// Undo - restores original instantly!
controller.undo();

// Redo - reapplies processed version instantly!
controller.redo();
```

### ✅ Transformations Preserved

All drawable properties are automatically preserved:
- Position
- Scale  
- Rotation
- Flip state
- Any other transformations

## Complete Example

```dart
class MyWidget extends HookWidget {
  final PainterController controller;

  @override
  Widget build(BuildContext context) {
    // Listen to loading state
    final isRemoving = useListenableSelector(
      controller,
      () => controller.isRemovingBackground,
    );

    return Column(
      children: [
        ElevatedButton(
          onPressed: isRemoving ? null : () => _removeBackground(context),
          child: isRemoving
              ? CircularProgressIndicator()
              : Text('Remove Background'),
        ),
        
        // Undo/Redo buttons
        IconButton(
          icon: Icon(Icons.undo),
          onPressed: controller.canUndo ? () => controller.undo() : null,
        ),
      ],
    );
  }

  Future<void> _removeBackground(BuildContext context) async {
    final success = await controller.removeBackgroundFromSelected(
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      },
    );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Background removed!')),
      );
    }
  }
}
```

## Advanced Options

```dart
await controller.removeBackgroundFromSelected(
  threshold: 0.5,        // 0..1 (higher removes more; default 0.5)
  smoothMask: true,      // Smooth mask edges (default true)
  enhanceEdges: true,    // Extra edge refinement (default true)
  padPx: 6,              // Transparent border padding (default 6)
  onError: (error) {     // Error callback
    print('Failed: $error');
  },
);
```

## Initialization

The background remover initializes automatically on first use. If you want to initialize it earlier (e.g., during app startup):

```dart
import 'package:flutter_painter_v2/src/controllers/background_remover/image_background_remover_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Optional: Initialize background remover early
  await BackgroundRemoverUtil.initialize();
  
  runApp(MyApp());
}
```

## What Changed from Riverpod

- ❌ No more Riverpod provider
- ❌ No more passing backgroundRemover callback
- ✅ Static utility class (internal)
- ✅ Controller handles everything
- ✅ `isRemovingBackground` getter for loading state
- ✅ `onError` callback for error handling

## Key Files

- `lib/src/controllers/background_remover/image_background_remover_provider.dart` - Static utility
- `lib/src/controllers/actions/remove_background_action.dart` - Undoable action
- `lib/src/controllers/painter_controller.dart` - `removeBackgroundFromSelected()` method
- `example/lib/background_removal_example.dart` - Complete working example
