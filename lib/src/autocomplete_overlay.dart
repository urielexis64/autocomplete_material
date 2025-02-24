import 'package:autocomplete_material/src/models/creatable_options.dart';
import 'package:autocomplete_material/src/models/overlay_decoration.dart';
import 'package:autocomplete_material/src/utils/constants.dart';
import 'package:flutter/material.dart';

class AutocompleteOverlay<T> extends OverlayEntry {
  final LayerLink layerLink;
  final RenderBox renderBox;

  final Future<List<T>> items;
  final ValueNotifier<List<T>> selectedItemsNotifier;
  final ValueNotifier<String?>? textFieldNotifier;
  final FocusNode textFieldFocusNode;
  final TextEditingController textController;
  final bool closeOnSelect;
  // ignore: avoid_positional_boolean_parameters
  final Function(T item, bool isSelected) onSelected;
  final Future<List<T>> Function(String? query)? onAsyncQuery;
  final Widget Function(
    BuildContext context,
    T item,
    VoidCallback onTap,
    bool isSelected,
  )? itemBuilder;
  final String Function(T item)? itemToString;
  final OverlayDecoration overlayDecoration;
  final String? Function(T item)? groupBy;
  final Widget Function(String? group)? groupByBuilder;
  final bool Function(T item, String? query)? filter;
  final CreatableOptions? creatableOptions;
  final bool isMultiSelect;
  List<T> cachedItems = [];

  AutocompleteOverlay({
    required this.layerLink,
    required this.renderBox,
    required this.items,
    required this.selectedItemsNotifier,
    required this.textFieldNotifier,
    required this.textFieldFocusNode,
    required this.textController,
    required this.closeOnSelect,
    required this.onSelected,
    required this.overlayDecoration,
    required this.isMultiSelect,
    required this.creatableOptions,
    this.groupBy,
    this.groupByBuilder,
    this.filter,
    this.itemBuilder,
    this.itemToString,
  })  : onAsyncQuery = null,
        super(
          builder: (context) {
            bool isItemSelected(T item) {
              if (isMultiSelect) {
                final selectedItems = selectedItemsNotifier.value;
                return selectedItems.contains(item);
              }

              final itemAsString = itemToString?.call(item) ?? item.toString();
              final text = textController.text;

              return itemAsString == text;
            }

            final size = renderBox.size;
            final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
            final hasSpaceBelow = renderBox.localToGlobal(Offset.zero).dy +
                    size.height +
                    Constants.defaultOverlayMaxHeight +
                    keyboardHeight <
                MediaQuery.of(context).size.height;
            return Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: layerLink,
                showWhenUnlinked: false,
                targetAnchor: hasSpaceBelow
                    ? Alignment.bottomCenter
                    : Alignment.topCenter,
                followerAnchor: hasSpaceBelow
                    ? Alignment.topCenter
                    : Alignment.bottomCenter,
                offset: Offset(0, hasSpaceBelow ? 0 : -10),
                child: ConstrainedBox(
                  constraints: overlayDecoration.constraints ??
                      const BoxConstraints(
                        maxHeight: Constants.defaultOverlayMaxHeight,
                      ),
                  child: Material(
                    elevation: overlayDecoration.elevation,
                    borderRadius: overlayDecoration.borderRadius,
                    color: overlayDecoration.backgroundColor,
                    child: FutureBuilder(
                        future: items,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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
                                  ? finalItems
                                      .where((item) => filter.call(item, query))
                                  : finalItems.where((element) {
                                      final stringItem =
                                          itemToString?.call(element) ??
                                              element.toString();
                                      query = (query ?? '').toLowerCase();
                                      return stringItem
                                          .toLowerCase()
                                          .contains(query!);
                                    });

                              final hasCreatable =
                                  (creatableOptions?.isCreatable.call(query!) ??
                                          false) &&
                                      !finalItems.any((item) =>
                                          itemToString?.call(item) == query) &&
                                      query != null;

                              if (filteredItems.isEmpty) {
                                return overlayDecoration.emptyWidget;
                              }
                              return ValueListenableBuilder(
                                valueListenable: selectedItemsNotifier,
                                builder: (context, selectedItems, child) {
                                  return ListView(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    children: [
                                      if (hasCreatable)
                                        creatableOptions!.widgetBuilder
                                                ?.call(query) ??
                                            ListTile(
                                              title: Text('Add "$query!"'),
                                              onTap: () {
                                                final item = creatableOptions
                                                    .queryToObject(query!);
                                                onSelected.call(item, false);
                                                if (closeOnSelect) {
                                                  textFieldFocusNode.unfocus();
                                                }
                                              },
                                            ),
                                      ...filteredItems.map((item) {
                                        final isSelected = isItemSelected(item);

                                        void onTap() {
                                          onSelected.call(item, isSelected);
                                          if (closeOnSelect) {
                                            textFieldFocusNode.unfocus();
                                          }
                                        }

                                        if (itemBuilder != null) {
                                          return itemBuilder(
                                            context,
                                            item,
                                            onTap,
                                            isSelected,
                                          );
                                        }

                                        return ListTile(
                                          key: ValueKey(item),
                                          title: Text(
                                            itemToString?.call(item) ??
                                                item.toString(),
                                          ),
                                          selected: isSelected,
                                          selectedColor: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          selectedTileColor: Colors.grey[300],
                                          onTap: onTap,
                                        );
                                      }).toList(),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        }),
                  ),
                ),
              ),
            );
          },
        );

  AutocompleteOverlay.searchAsync({
    required this.layerLink,
    required this.renderBox,
    required this.selectedItemsNotifier,
    required this.textFieldNotifier,
    required this.textFieldFocusNode,
    required this.textController,
    required this.closeOnSelect,
    required this.onSelected,
    required this.onAsyncQuery,
    required this.overlayDecoration,
    required this.isMultiSelect,
    required this.creatableOptions,
    this.groupBy,
    this.groupByBuilder,
    this.filter,
    this.itemBuilder,
    this.itemToString,
  })  : items = Future.value([]),
        super(
          builder: (context) {
            bool isItemSelected(T item) {
              if (isMultiSelect) {
                final selectedItems = selectedItemsNotifier.value;
                return selectedItems.contains(item);
              }

              final itemAsString = itemToString?.call(item) ?? item.toString();
              final text = textController.text;

              return itemAsString == text;
            }

            final size = renderBox.size;
            final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
            final hasSpaceBelow = renderBox.localToGlobal(Offset.zero).dy +
                    size.height +
                    Constants.defaultOverlayMaxHeight +
                    keyboardHeight <
                MediaQuery.of(context).size.height;
            return Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: layerLink,
                showWhenUnlinked: false,
                targetAnchor: hasSpaceBelow
                    ? Alignment.bottomCenter
                    : Alignment.topCenter,
                followerAnchor: hasSpaceBelow
                    ? Alignment.topCenter
                    : Alignment.bottomCenter,
                offset: Offset(0, hasSpaceBelow ? 0 : -10),
                child: ValueListenableBuilder<String?>(
                  valueListenable: textFieldNotifier!,
                  builder: (context, text, child) {
                    return ConstrainedBox(
                      constraints: overlayDecoration.constraints ??
                          const BoxConstraints(
                              maxHeight: Constants.defaultOverlayMaxHeight),
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

                            final hasCreatable =
                                (creatableOptions?.isCreatable.call(text) ??
                                    false);

                            return ValueListenableBuilder(
                              valueListenable: selectedItemsNotifier,
                              builder: (context, selectedItems, child) {
                                if (items.isEmpty) {
                                  return overlayDecoration.emptyWidget;
                                }

                                if (groupBy != null) {
                                  final groupedItems = <String?, List<T>>{};
                                  for (final item in items) {
                                    final group = groupBy.call(item);

                                    if (groupedItems.containsKey(group)) {
                                      groupedItems[group]!.add(item);
                                    } else {
                                      groupedItems[group] = [item];
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
                                          final group =
                                              groupedItems.keys.toList()[index];
                                          final items = groupedItems[group]!;
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (hasCreatable)
                                                creatableOptions!.widgetBuilder
                                                        ?.call(text) ??
                                                    ListTile(
                                                      title:
                                                          Text('Add "$text"'),
                                                      onTap: () {
                                                        final item =
                                                            creatableOptions
                                                                .queryToObject(
                                                                    text);
                                                        onSelected.call(
                                                            item, false);
                                                        if (closeOnSelect) {
                                                          textFieldFocusNode
                                                              .unfocus();
                                                        }
                                                      },
                                                    ),
                                              if (groupByBuilder != null)
                                                groupByBuilder.call(group),
                                              if (group != null &&
                                                  groupByBuilder == null)
                                                ListTile(
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    horizontal: 8,
                                                  ),
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  dense: true,
                                                  title: Text(
                                                    group,
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
                                                itemBuilder: (context, index) {
                                                  final item = items[index];
                                                  final isSelected =
                                                      isItemSelected(item);

                                                  void onTap() {
                                                    onSelected.call(
                                                        item, isSelected);
                                                    if (closeOnSelect) {
                                                      textFieldFocusNode
                                                          .unfocus();
                                                    }
                                                  }

                                                  if (itemBuilder != null) {
                                                    return itemBuilder(
                                                      context,
                                                      item,
                                                      onTap,
                                                      isSelected,
                                                    );
                                                  }

                                                  return ListTile(
                                                    key: ValueKey(item),
                                                    title: Text(itemToString
                                                            ?.call(item) ??
                                                        item.toString()),
                                                    selected: isSelected,
                                                    selectedColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .onSurface,
                                                    selectedTileColor:
                                                        Colors.grey[300],
                                                    contentPadding:
                                                        const EdgeInsets.only(
                                                      right: 8,
                                                      left: 32,
                                                    ),
                                                    onTap: onTap,
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
                                        itemCount: groupedItems.length,
                                      )),
                                      if (overlayDecoration.footerWidget !=
                                          null)
                                        overlayDecoration.footerWidget!,
                                    ],
                                  );
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (overlayDecoration.headerWidget != null)
                                      overlayDecoration.headerWidget!,
                                    if (hasCreatable)
                                      ListTile(
                                        title: Text('Add "$text"'),
                                        onTap: () {
                                          print(text);
                                        },
                                      ),
                                    Flexible(
                                      child: ListView.separated(
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        itemBuilder: (context, index) {
                                          final item = items[index];
                                          final isSelected =
                                              isItemSelected(item);

                                          void onTap() {
                                            onSelected.call(item, isSelected);
                                            if (closeOnSelect) {
                                              textFieldFocusNode.unfocus();
                                            }
                                          }

                                          if (itemBuilder != null) {
                                            return itemBuilder(
                                              context,
                                              item,
                                              onTap,
                                              isSelected,
                                            );
                                          }

                                          return ListTile(
                                            key: ValueKey(item),
                                            title: Text(
                                              itemToString?.call(item) ??
                                                  item.toString(),
                                            ),
                                            selected: isSelected,
                                            selectedColor: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            selectedTileColor: Colors.grey[300],
                                            onTap: onTap,
                                          );
                                        },
                                        separatorBuilder: (_, __) =>
                                            overlayDecoration.dividerWidget,
                                        itemCount: items.length,
                                      ),
                                    ),
                                    if (overlayDecoration.footerWidget != null)
                                      overlayDecoration.footerWidget!,
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
}
