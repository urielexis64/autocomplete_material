import 'package:autocomplete_material/autocomplete_material.dart';
import 'package:flutter/material.dart';

/// This class creates a single select autocomplete widget.
/// It gives to the parent widget to handle the callback when the user selects an item.
class SingleSelectAutocomplete extends StatelessWidget {
  SingleSelectAutocomplete({
    super.key,
    required this.onChanged,
  });

  /// Callback function to handle the selected item.
  final Function(String? selectedItem) onChanged;

  final List<String> items = ['a', 'b', 'c', 'd', 'e'];

  @override
  Widget build(BuildContext context) {
    return AutocompleteMaterial.single(
      key: Key('SingleSelectAutocomplete'),
      items: items,
      decoration: InputDecoration(
        labelText: 'Select an item',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      onChanged: onChanged,
      filter: (item, String? query) {
        return true;
      },
      overlayDecoration: OverlayDecoration(
        backgroundColor: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}
