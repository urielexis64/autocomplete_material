import 'package:autocomplete_material/autocomplete_material.dart';
import 'package:autocomplete_material/src/widgets/default_item_tile.dart';
import 'package:autocomplete_material/src/overlay/utils/item_selector.dart';
import 'package:autocomplete_material/src/utils/sizes.dart';
import 'package:flutter/material.dart';

/// A widget that displays a list of items for selection.
///
/// This widget is used to display a list of items that can be selected by the user.
/// It supports filtering, custom item builders, and creatable options.
class SyncListView<T> extends StatelessWidget {
  const SyncListView({
    super.key,
    required this.onSelected,
    required this.textFieldFocusNode,
    required this.textController,
    required this.isMultiSelect,
    required this.filteredItems,
    required this.closeOnSelect,
    required this.hasCreatable,
    required this.selectedItems,
    this.itemToString,
    this.creatableOptions,
    this.itemBuilder,
    this.query,
  });

  final Iterable<T> filteredItems;
  final String Function(T item)? itemToString;
  final CreatableOptions? creatableOptions;
  final Function(T item, bool isSelected) onSelected;
  final FocusNode textFieldFocusNode;

  final TextEditingController textController;
  final bool isMultiSelect;

  ///TODO: Create a type for this
  final Widget Function(
    BuildContext context,
    T item,
    VoidCallback onTap,
    bool isSelected,
  )? itemBuilder;

  /// TODO: Make this a default value
  final bool closeOnSelect;

  final bool hasCreatable;
  final List<T> selectedItems;
  final String? query;

  @override
  Widget build(BuildContext context) {
    bool isSelected(T item, List<T> selectedItems) => isItemSelected(
          item: item,
          controller: textController,
          isMultiSelect: isMultiSelect,
          selectedItems: selectedItems,
          itemToString: itemToString,
        );

    void onTap(T item, List<T> selectedItems) {
      onSelected.call(
        item,
        isSelected(item, selectedItems),
      );

      if (closeOnSelect) {
        textFieldFocusNode.unfocus();
      }
    }

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: Sizes.p8),
      children: [
        if (hasCreatable)
          GestureDetector(
            onTap: () {
              /// TODO: Are we sure query is not null at this point?
              final item = creatableOptions?.queryToObject(query!);
              onSelected.call(item, false);
              if (closeOnSelect) {
                textFieldFocusNode.unfocus();
              }
            },
            child: creatableOptions!.widgetBuilder?.call(query) ??
                ListTile(
                  title: Text('Add "$query"'),
                ),
          ),
        ...filteredItems.map(
          (item) {
            if (itemBuilder != null) {
              return itemBuilder!(
                context,
                item,
                () => onTap(item, selectedItems),
                isSelected(item, selectedItems),
              );
            }

            return DefaultItemTile(
              key: ValueKey(item),
              item: item,
              itemToString: itemToString,
              isSelected: isSelected(item, selectedItems),
              onTap: () => onTap(item, selectedItems),
            );
          },
        ),
      ],
    );
  }
}
