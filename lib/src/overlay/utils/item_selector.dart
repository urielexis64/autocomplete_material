import 'package:flutter/material.dart';

/// Returns true if the [item] is considered selected based on the current state.
bool isItemSelected<T>({
  required T item,
  required bool isMultiSelect,
  required List<T> selectedItems,
  required TextEditingController controller,
  String? Function(T)? itemToString,
}) {
  if (isMultiSelect) return selectedItems.contains(item);

  final itemStr = itemToString?.call(item) ?? item.toString();
  return itemStr == controller.text;
}
