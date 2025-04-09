import 'package:autocomplete_material/src/models/creatable_options.dart';
import 'package:autocomplete_material/src/models/overlay_decoration.dart';
import 'package:autocomplete_material/src/overlay/sync/sync_list_view.dart';
import 'package:flutter/material.dart';

/// A widget that builds a list of items for selection in an overlay.
///
/// This widget is used to display a list of items that can be selected by the user.
/// It supports filtering, custom item builders, and creatable options.
///
/// The [SyncListBuilder] widget is a generic widget that takes a list of items
/// and displays them in a list format. It also provides options for filtering
/// the list based on user input, as well as the ability to create new items
class SyncListBuilder<T> extends StatelessWidget {
  const SyncListBuilder({
    super.key,
    required this.items,
    required this.overlayDecoration,
    required this.selectedItemsNotifier,
    required this.onSelected,
    required this.closeOnSelect,
    required this.textFieldFocusNode,
    required this.textController,
    required this.isMultiSelect,
    this.filter,
    this.textFieldNotifier,
    this.itemToString,
    this.creatableOptions,
    this.itemBuilder,
  });

  /// TODO: create specific classes for these parameters
  final Future<List<T>> items;
  final ValueNotifier<String?>? textFieldNotifier;
  final OverlayDecoration overlayDecoration;
  final bool Function(T item, String? query)? filter;
  final String Function(T item)? itemToString;
  final CreatableOptions? creatableOptions;
  final ValueNotifier<List<T>> selectedItemsNotifier;
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: items,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return overlayDecoration.loadingWidget;
        }

        if (snapshot.hasError) {
          return overlayDecoration.errorWidget;
        }

        final finalItems = snapshot.data as List<T>;

        return ValueListenableBuilder<String?>(
          valueListenable: textFieldNotifier!,
          builder: (context, query, child) {
            final filteredItems = filter != null

                /// TODO: Move this into a separate function / Util
                ? finalItems.where((element) {
                    final stringItem =
                        itemToString?.call(element) ?? element.toString();
                    query = (query ?? '').toLowerCase();
                    return stringItem.toLowerCase().contains(query!);
                  })
                : finalItems;

            /// TODO: Move this into a separate function / Util
            final hasCreatable = (creatableOptions?.isCreatable.call(query!) ??
                    false) &&
                !finalItems.any((item) => itemToString?.call(item) == query) &&
                query != null;

            if (filteredItems.isEmpty && !hasCreatable) {
              return overlayDecoration.emptyWidget;
            }

            return ValueListenableBuilder(
              valueListenable: selectedItemsNotifier,
              builder: (
                context,
                selectedItems,
                child,
              ) =>
                  SyncListView(
                filteredItems: filteredItems,
                hasCreatable: hasCreatable,
                selectedItems: selectedItems,
                query: query,
                onSelected: onSelected,
                textFieldFocusNode: textFieldFocusNode,
                isMultiSelect: isMultiSelect,
                textController: textController,
                closeOnSelect: closeOnSelect,
                itemBuilder: itemBuilder,
                itemToString: itemToString,
                creatableOptions: creatableOptions,
              ),
            );
          },
        );
      },
    );
  }
}
