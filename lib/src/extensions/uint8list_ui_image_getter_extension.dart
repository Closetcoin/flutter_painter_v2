import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

/// Adds a method to convert a [Uint8List] of image bytes to a [ui.Image].
extension Uint8ListUiImageGetter on Uint8List {
  /// Returns a [ui.Image] from the bytes in `this` object.
  ///
  /// The bytes should be in a format that Flutter can decode (PNG, JPEG, etc.).
  Future<ui.Image> toUiImage() async {
    final completer = Completer<ui.Image>();

    ui.decodeImageFromList(this, (ui.Image image) {
      completer.complete(image);
    });

    return await completer.future;
  }
}
