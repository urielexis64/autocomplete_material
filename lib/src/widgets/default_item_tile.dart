import 'package:autocomplete_material/src/utils/sizes.dart';
import 'package:flutter/material.dart';

/// A default item tile widget for displaying items in a list.
class DefaultItemTile<T> extends StatelessWidget {
  const DefaultItemTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.isSelected,
    required this.itemToString,
  });

  final T item;
  final VoidCallback onTap;
  final bool isSelected;
  final String Function(T)? itemToString;

  String get title => itemToString?.call(item) ?? item.toString();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey(item),
      title: Text(title),
      selected: isSelected,
      /// Make this customizable.
      selectedColor: Theme.of(context).colorScheme.onSurface,
      /// Make this customizable.
      selectedTileColor: Colors.grey[300],
      contentPadding: const EdgeInsets.only(right: Sizes.p8, left: Sizes.p32),
      onTap: onTap,
    );
  }
}
