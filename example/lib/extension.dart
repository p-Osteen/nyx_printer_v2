
import 'package:flutter/material.dart';

/// Extension to add an onTap handler to any [Widget].
extension OnTapExtension on Widget {
  /// Wraps the widget in a [GestureDetector] to handle tap events.
  ///
  /// [onTap] is the callback executed when the widget is tapped.
  /// [key] is an optional key for the [GestureDetector].
  Widget onTap(VoidCallback onTap, {Key? key}) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: this,
    );
  }
}
