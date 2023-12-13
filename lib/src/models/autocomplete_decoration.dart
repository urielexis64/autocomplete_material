import 'package:flutter/material.dart';

class AutocompleteDecoration extends InputDecoration {
  const AutocompleteDecoration({
    super.border,
    super.enabledBorder,
    super.errorBorder,
    super.focusedBorder,
    super.focusedErrorBorder,
    super.disabledBorder,
    super.labelText = 'Search',
    super.hintText = 'Search',
    super.helperText,
    super.errorText,
    super.counterText,
    super.labelStyle,
    super.hintStyle,
    super.helperStyle,
    super.errorStyle,
    super.counterStyle,
    super.filled,
    super.fillColor,
    super.hintTextDirection,
    super.enabled,
    super.contentPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });
}
