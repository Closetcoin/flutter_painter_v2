import 'package:flutter/material.dart';
import '../../../controllers/helpers/border_box_shadow.dart';
import '../../../controllers/helpers/renderer_check/renderer_check.dart';
import '../../../controllers/settings/settings.dart';

/// Renders the selection indicator (border and shadow) around a selected object.
class ObjectSelectionIndicator extends StatelessWidget {
  final SelectionIndicatorSettings settings;
  final double transformationScale;

  const ObjectSelectionIndicator({
    Key? key,
    required this.settings,
    required this.transformationScale,
  }) : super(key: key);

  double get borderWidth => settings.borderWidth / transformationScale;
  double get blurRadius => settings.shadowBlurRadius / transformationScale;
  double get borderRadius => settings.borderRadius / transformationScale;
  Offset get shadowOffset => settings.shadowOffset / transformationScale;

  @override
  Widget build(BuildContext context) {
    if (usingHtmlRenderer) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: settings.borderColor,
            width: borderWidth,
          ),
          boxShadow: settings.shadowBlurRadius > 0
              ? [
                  BorderBoxShadow(
                    color: settings.shadowColor,
                    blurRadius: blurRadius,
                    offset: shadowOffset,
                  )
                ]
              : null,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: settings.borderColor,
          width: borderWidth,
        ),
        boxShadow: settings.shadowBlurRadius > 0
            ? [
                BorderBoxShadow(
                  color: settings.shadowColor,
                  blurRadius: blurRadius,
                  offset: shadowOffset,
                )
              ]
            : null,
      ),
    );
  }
}
