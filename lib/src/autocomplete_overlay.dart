import 'package:autocomplete_material/src/models/overlay_decoration.dart';
import 'package:flutter/material.dart';

class AutocompleteOverlay<T> extends OverlayEntry {
  final LayerLink layerLink;
  final RenderBox renderBox;

  final List<T> items;
  final ValueNotifier<List<T>> selectedItemsNotifier;
  final ValueNotifier<String?>? textFieldNotifier;
  final FocusNode textFieldFocusNode;
  final TextEditingController textFieldEditingController;
  final bool closeOnSelect;
  // ignore: avoid_positional_boolean_parameters
  final Function(T item, bool isSelected) onSelected;
  final Future<List<T>> Function(String? query)? onAsyncQuery;
  final Widget Function(BuildContext context, T item)? itemBuilder;
  final OverlayDecoration overlayDecoration;
  final dynamic Function(T item)? categorizedBy;
  final bool Function(T item, String? query)? filter;

  AutocompleteOverlay({
    required this.layerLink,
    required this.renderBox,
    required this.items,
    required this.selectedItemsNotifier,
    required this.textFieldNotifier,
    required this.textFieldFocusNode,
    required this.textFieldEditingController,
    required this.closeOnSelect,
    required this.onSelected,
    required this.overlayDecoration,
    this.categorizedBy,
    this.filter,
    this.itemBuilder,
  })  : onAsyncQuery = null,
        super(builder: (context) {
          final size = renderBox.size;
          final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
          final hasSpaceBelow = renderBox.localToGlobal(Offset.zero).dy +
                  size.height +
                  175 +
                  keyboardHeight <
              MediaQuery.of(context).size.height;
          return Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: layerLink,
              showWhenUnlinked: false,
              targetAnchor:
                  hasSpaceBelow ? Alignment.bottomCenter : Alignment.topCenter,
              followerAnchor:
                  hasSpaceBelow ? Alignment.topCenter : Alignment.bottomCenter,
              offset: Offset(0, hasSpaceBelow ? 0 : -10),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 175),
                child: Material(
                  elevation: overlayDecoration.elevation,
                  borderRadius: overlayDecoration.borderRadius,
                  color: overlayDecoration.backgroundColor,
                  child: ValueListenableBuilder<String?>(
                      valueListenable: textFieldNotifier!,
                      builder: (context, query, child) {
                        final filteredItems = filter != null
                            ? items.where((item) => filter.call(item, query))
                            : items.where((element) =>
                                element.toString().contains(query ?? ''));
                        if (filteredItems.isEmpty) {
                          return overlayDecoration.emptyWidget;
                        }
                        return ValueListenableBuilder(
                            valueListenable: selectedItemsNotifier,
                            builder: (context, selectedItems, child) {
                              return ListView(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                children: filteredItems.map((item) {
                                  final isSelected =
                                      selectedItems.contains(item);
                                  return ListTile(
                                    key: ValueKey(item),
                                    title: itemBuilder != null
                                        ? itemBuilder.call(context, item)
                                        : Text(item.toString()),
                                    selected: isSelected,
                                    selectedColor:
                                        Theme.of(context).colorScheme.onSurface,
                                    selectedTileColor: Colors.grey[300],
                                    onTap: () {
                                      onSelected.call(item, isSelected);
                                      if (closeOnSelect) {
                                        textFieldFocusNode.unfocus();
                                      }
                                    },
                                  );
                                }).toList(),
                              );
                            });
                      }),
                ),
              ),
            ),
          );
        });

  AutocompleteOverlay.searchAsync({
    required this.layerLink,
    required this.renderBox,
    required this.selectedItemsNotifier,
    required this.textFieldNotifier,
    required this.textFieldFocusNode,
    required this.textFieldEditingController,
    required this.closeOnSelect,
    required this.onSelected,
    required this.onAsyncQuery,
    required this.overlayDecoration,
    this.categorizedBy,
    this.filter,
    this.itemBuilder,
  })  : items = [],
        super(builder: (context) {
          final size = renderBox.size;
          final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
          final hasSpaceBelow = renderBox.localToGlobal(Offset.zero).dy +
                  size.height +
                  175 +
                  keyboardHeight <
              MediaQuery.of(context).size.height;
          return Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: layerLink,
              showWhenUnlinked: false,
              targetAnchor:
                  hasSpaceBelow ? Alignment.bottomCenter : Alignment.topCenter,
              followerAnchor:
                  hasSpaceBelow ? Alignment.topCenter : Alignment.bottomCenter,
              offset: Offset(0, hasSpaceBelow ? 0 : -10),
              child: ValueListenableBuilder<String?>(
                  valueListenable: textFieldNotifier!,
                  builder: (context, text, child) {
                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 175),
                      child: Material(
                        elevation: overlayDecoration.elevation,
                        borderRadius: overlayDecoration.borderRadius,
                        color: overlayDecoration.backgroundColor,
                        child: FutureBuilder(
                            future: (text?.isNotEmpty ?? false)
                                ? onAsyncQuery?.call(text)
                                : null,
                            builder: (context, snapshot) {
                              if (text == null || text.isEmpty) {
                                return const SizedBox();
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return overlayDecoration.loadingWidget;
                              }
                              if (snapshot.hasError) {
                                return overlayDecoration.errorWidget;
                              }
                              final items = snapshot.data as List<T>;

                              return ValueListenableBuilder(
                                  valueListenable: selectedItemsNotifier,
                                  builder: (context, selectedItems, child) {
                                    if (items.isEmpty) {
                                      return overlayDecoration.emptyWidget;
                                    }

                                    if (categorizedBy != null) {
                                      final categorizedItems =
                                          <String, List<T>>{};
                                      for (final item in items) {
                                        final category =
                                            categorizedBy.call(item);
                                        if (category != null) {
                                          if (categorizedItems
                                              .containsKey(category)) {
                                            categorizedItems[category]!
                                                .add(item);
                                          } else {
                                            categorizedItems[category] = [item];
                                          }
                                        }
                                      }

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (overlayDecoration.headerWidget !=
                                              null)
                                            overlayDecoration.headerWidget!,
                                          Flexible(
                                              child: ListView.separated(
                                            shrinkWrap: true,
                                            padding: EdgeInsets.zero,
                                            itemBuilder: (context, index) {
                                              final category = categorizedItems
                                                  .keys
                                                  .toList()[index];
                                              final items =
                                                  categorizedItems[category]!;
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  ListTile(
                                                    title: Text(
                                                      category,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  ListView.separated(
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    shrinkWrap: true,
                                                    padding: EdgeInsets.zero,
                                                    itemBuilder:
                                                        (context, index) {
                                                      final item = items[index];
                                                      final isSelected =
                                                          selectedItems
                                                              .contains(item);

                                                      return ListTile(
                                                        key: ValueKey(item),
                                                        title: itemBuilder !=
                                                                null
                                                            ? itemBuilder.call(
                                                                context, item)
                                                            : Text(item
                                                                .toString()),
                                                        selected: isSelected,
                                                        selectedColor:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .onSurface,
                                                        selectedTileColor:
                                                            Colors.grey[300],
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .only(
                                                          right: 8,
                                                          left: 32,
                                                        ),
                                                        onTap: () {
                                                          onSelected.call(
                                                            item,
                                                            isSelected,
                                                          );
                                                        },
                                                      );
                                                    },
                                                    separatorBuilder: (_, __) =>
                                                        overlayDecoration
                                                            .dividerWidget,
                                                    itemCount: items.length,
                                                  ),
                                                ],
                                              );
                                            },
                                            separatorBuilder: (_, __) =>
                                                overlayDecoration.dividerWidget,
                                            itemCount: categorizedItems.length,
                                          )),
                                          if (overlayDecoration.footerWidget !=
                                              null)
                                            overlayDecoration.footerWidget!,
                                        ],
                                      );
                                    }

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (overlayDecoration.headerWidget !=
                                            null)
                                          overlayDecoration.headerWidget!,
                                        Flexible(
                                          child: ListView.separated(
                                            shrinkWrap: true,
                                            padding: EdgeInsets.zero,
                                            itemBuilder: (context, index) {
                                              final item = items[index];
                                              final isSelected =
                                                  selectedItems.contains(item);

                                              return ListTile(
                                                key: ValueKey(item),
                                                title: itemBuilder != null
                                                    ? itemBuilder.call(
                                                        context, item)
                                                    : Text(item.toString()),
                                                selected: isSelected,
                                                selectedColor: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                                selectedTileColor:
                                                    Colors.grey[300],
                                                onTap: () {
                                                  onSelected.call(
                                                    item,
                                                    isSelected,
                                                  );
                                                },
                                              );
                                            },
                                            separatorBuilder: (_, __) =>
                                                overlayDecoration.dividerWidget,
                                            itemCount: items.length,
                                          ),
                                        ),
                                        if (overlayDecoration.footerWidget !=
                                            null)
                                          overlayDecoration.footerWidget!,
                                      ],
                                    );
                                  });
                            }),
                      ),
                    );
                  }),
            ),
          );
        });
}
