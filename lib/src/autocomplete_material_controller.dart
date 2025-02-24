import 'dart:async';

import 'package:autocomplete_material/src/autocomplete_material.dart';
import 'package:autocomplete_material/src/autocomplete_overlay.dart';
import 'package:autocomplete_material/src/enums/autocomplete_type.dart';
import 'package:autocomplete_material/src/models/overlay_decoration.dart';
import 'package:flutter/material.dart';

class AutocompleteMaterialController<T> {
  ValueChanged<List<T>?>? multipleDidChange;
  ValueChanged<T?>? singleDidChange;

  late BuildContext context;
  late AutocompleteMaterial<T> widget;
  Timer? _debounce;

  final layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  OverlayEntry? _overlaybackdropEntry;

  final FocusNode textFieldFocusNode = FocusNode();
  final TextEditingController textEditingController = TextEditingController();

  late ValueNotifier<String?> _textNotifier;
  late ValueNotifier<List<T>> selectedItemsNotifier;
  late ValueNotifier<T?> selectedItemNotifier;

  late Future<List<T>> items;

  InputDecoration get decoration =>
      widget.decoration ?? const InputDecoration();
  bool get isActiveOverlay => _overlayEntry != null;

  void initItems() {
    if (widget.asyncItems == null) {
      items = Future.value(widget.items ?? []);
    } else {
      items = widget.asyncItems!();
    }
  }

  void init(
    BuildContext context,
    AutocompleteMaterial<T> widget,
  ) {
    this.context = context;
    this.widget = widget;

    initItems();

    selectedItemsNotifier = ValueNotifier(widget.initialItems ?? []);
    selectedItemNotifier = ValueNotifier(widget.initialItem);
    _textNotifier = ValueNotifier(null);

    final itemAsString = widget.initialItem != null
        ? widget.itemToString?.call(widget.initialItem as T)
        : null;

    if (itemAsString != null) {
      textEditingController.text = itemAsString;
    }

    textEditingController.addListener(() {
      if (widget.debounceDuration != null) {
        checkDebounce();
      } else {
        _textNotifier.value = textEditingController.text;
      }
    });
  }

  void dispose() {
    _debounce?.cancel();
    _textNotifier.dispose();
    selectedItemsNotifier.dispose();
    selectedItemNotifier.dispose();
    textEditingController.dispose();
    textFieldFocusNode.dispose();

    removeOverlay();
  }

  void onTap() {
    if (!(widget.decoration?.enabled ?? true)) {
      return;
    }
    textFieldFocusNode.requestFocus();
    toggleOverlay();
  }

  void clear() {
    if (widget.isMultiSelect) {
      selectedItemsNotifier.value = [];
      widget.onItemsChanged?.call(selectedItemsNotifier.value);
    } else {
      selectedItemNotifier.value = null;
      widget.onChanged?.call(null);
    }
    textEditingController.clear();
    removeOverlay();
  }

  void checkDebounce() {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(widget.debounceDuration!, () {
      _textNotifier.value = textEditingController.text;
    });
  }

  void _addOverlay() {
    if (_overlayEntry == null) {
      _overlayEntry = _getOverlayEntry();
      _overlaybackdropEntry = _createBackdropOverlay();
      if (_overlayEntry != null) {
        Overlay.of(context).insertAll([_overlaybackdropEntry!, _overlayEntry!]);
      }
    }
  }

  void removeOverlay({bool clearTextField = true}) {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _overlaybackdropEntry!.remove();
      _overlaybackdropEntry = null;
      textFieldFocusNode.unfocus();

      if (widget.clearOnSelect && clearTextField) {
        textEditingController.clear();
      }

      if (!widget.isMultiSelect &&
          selectedItemNotifier.value != null &&
          textEditingController.text != selectedItemNotifier.value) {
        textEditingController.text =
            widget.itemToString?.call(selectedItemNotifier.value as T) ??
                selectedItemNotifier.value.toString();
      }
    }
  }

  void toggleOverlay() {
    if (_overlayEntry == null) {
      _addOverlay();
    } else {
      removeOverlay();
    }
  }

  InputDecoration getDecoration(FormFieldState state) {
    Widget clearButton = ValueListenableBuilder(
      valueListenable: selectedItemNotifier,
      builder: (context, value1, _) {
        if (value1 == null && !widget.isMultiSelect) {
          return const SizedBox.shrink();
        }
        return ValueListenableBuilder(
          valueListenable: selectedItemsNotifier,
          builder: (context, value2, child) {
            if (value2.isEmpty && widget.isMultiSelect) {
              return const SizedBox.shrink();
            }

            return child!;
          },
          child: IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.clear),
            onPressed: clear,
          ),
        );
      },
    );

    final defaultSuffixIcon = widget.type == AutocompleteType.searchAsync
        ? Icons.search
        : Icons.keyboard_arrow_down_rounded;

    return decoration
        .applyDefaults(Theme.of(state.context).inputDecorationTheme)
        .copyWith(
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              clearButton,
              IconButton(
                onPressed: onTap,
                visualDensity: VisualDensity.compact,
                icon: decoration.suffixIcon ?? Icon(defaultSuffixIcon),
              )
            ],
          ),
          errorText: state.errorText,
          enabled: widget.enabled,
        );
  }

  OverlayEntry _createBackdropOverlay() {
    return OverlayEntry(
      builder: (context) => Positioned(
        left: 0,
        top: 0,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: GestureDetector(onTap: removeOverlay),
      ),
    );
  }

  OverlayEntry _getOverlayEntry() {
    final overlayDecoration =
        widget.overlayDecoration ?? const OverlayDecoration();
    return switch (widget.type) {
      AutocompleteType.searchSync => AutocompleteOverlay(
          renderBox: context.findRenderObject() as RenderBox,
          layerLink: layerLink,
          items: items,
          closeOnSelect: widget.closeOnSelect,
          selectedItemsNotifier: selectedItemsNotifier,
          textFieldNotifier: _textNotifier,
          textController: textEditingController,
          textFieldFocusNode: textFieldFocusNode,
          itemBuilder: widget.itemBuilder,
          overlayDecoration: overlayDecoration,
          groupBy: widget.groupBy,
          groupByBuilder: widget.groupByBuilder,
          filter: widget.filter,
          itemToString: widget.itemToString,
          isMultiSelect: widget.isMultiSelect,
          onSelected: (item, isSelected) {
            isSelected ? removeItem(item) : selectItem(item);

            if (widget.closeOnSelect) {
              removeOverlay();
            }
          },
          isCreatable: widget.isCreatable,
        ),
      AutocompleteType.searchAsync => AutocompleteOverlay.searchAsync(
          renderBox: context.findRenderObject() as RenderBox,
          layerLink: layerLink,
          closeOnSelect: widget.closeOnSelect,
          selectedItemsNotifier: selectedItemsNotifier,
          textFieldNotifier: _textNotifier,
          textController: textEditingController,
          textFieldFocusNode: textFieldFocusNode,
          itemBuilder: widget.itemBuilder,
          itemToString: widget.itemToString,
          isMultiSelect: widget.isMultiSelect,
          onSelected: (item, isSelected) {
            isSelected ? removeItem(item) : selectItem(item);

            if (widget.closeOnSelect) {
              removeOverlay();
            }
          },
          overlayDecoration: overlayDecoration,
          groupBy: widget.groupBy,
          groupByBuilder: widget.groupByBuilder,
          onAsyncQuery: widget.onAsyncQuery,
          isCreatable: widget.isCreatable,
        ),
    };
  }

  void selectItem(T item) {
    if (widget.isMultiSelect) {
      selectedItemsNotifier.value = [...selectedItemsNotifier.value, item];
      widget.onItemsChanged?.call(selectedItemsNotifier.value);
      multipleDidChange?.call(selectedItemsNotifier.value);
    } else {
      textEditingController.text =
          widget.itemToString?.call(item) ?? item.toString();
      selectedItemNotifier.value = item;
      widget.onChanged?.call(item);
      singleDidChange?.call(item);
      removeOverlay(clearTextField: false);
    }
  }

  void removeItem(T item) {
    selectedItemsNotifier.value = [...selectedItemsNotifier.value]
      ..remove(item);
    if (widget.isMultiSelect) {
      widget.onItemsChanged?.call(selectedItemsNotifier.value);
      multipleDidChange?.call(selectedItemsNotifier.value);
    } else {
      singleDidChange?.call(item);
    }
  }
}
