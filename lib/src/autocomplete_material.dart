import 'package:autocomplete_material/src/autocomplete_material_controller.dart';
import 'package:autocomplete_material/src/enums/autocomplete_type.dart';
import 'package:autocomplete_material/src/models/autocomplete_decoration.dart';
import 'package:autocomplete_material/src/models/overlay_decoration.dart';
import 'package:autocomplete_material/src/widgets/autocomplete_form_field.dart';
import 'package:autocomplete_material/src/widgets/autocomplete_material_input_base.dart';
import 'package:flutter/material.dart';

part '../src/widgets/internal_text_field.dart';

/// Creates a material autocomplete widget.
///
/// The [AutocompleteMaterial] widget is a material design autocomplete widget
/// that wraps a [TextField] widget. It provides a way to autocomplete a user's
/// input based on a list of options.
class AutocompleteMaterial<T> extends StatefulWidget {
  /// Creates a single selecte material autocomplete widget that searches synchronously
  /// for a list of items.
  const AutocompleteMaterial.single({
    this.validator,
    this.closeOnSelect = true,
    this.items,
    this.itemBuilder,
    this.selectedItemBuilder,
    this.decoration,
    this.autovalidateMode,
    this.debounceDuration,
    this.overlayDecoration,
    this.itemToString,
    this.onChanged,
    this.enabled = true,
    this.initialItem,
    this.categorizedBy,
    super.key,
  })  : initialItems = null,
        multipleValidator = null,
        onAsyncQuery = null,
        isMultiSelect = false,
        onItemsChanged = null,
        type = AutocompleteType.searchSync;

  const AutocompleteMaterial.multiple({
    FormFieldValidator<List<T>>? validator,
    this.closeOnSelect = true,
    this.items,
    this.itemBuilder,
    this.selectedItemBuilder,
    this.decoration,
    this.autovalidateMode,
    this.debounceDuration,
    this.overlayDecoration,
    this.onItemsChanged,
    this.enabled = true,
    this.initialItems,
    this.categorizedBy,
    this.itemToString,
    super.key,
  })  : initialItem = null,
        multipleValidator = validator,
        validator = null,
        onAsyncQuery = null,
        isMultiSelect = true,
        onChanged = null,
        type = AutocompleteType.searchSync;

  const AutocompleteMaterial.searchAsync({
    required this.onAsyncQuery,
    this.validator,
    this.closeOnSelect = true,
    this.itemBuilder,
    this.decoration,
    this.autovalidateMode,
    this.debounceDuration,
    this.overlayDecoration,
    this.itemToString,
    this.onChanged,
    this.enabled = true,
    this.initialItem,
    this.categorizedBy,
    super.key,
  })  : initialItems = null,
        multipleValidator = null,
        items = null,
        isMultiSelect = false,
        selectedItemBuilder = null,
        onItemsChanged = null,
        type = AutocompleteType.searchAsync;

  const AutocompleteMaterial.multipleSearchAsync({
    required this.onAsyncQuery,
    FormFieldValidator<List<T>>? validator,
    this.closeOnSelect = true,
    this.itemBuilder,
    this.selectedItemBuilder,
    this.decoration,
    this.autovalidateMode,
    this.debounceDuration,
    this.overlayDecoration,
    this.onItemsChanged,
    this.enabled = true,
    this.initialItems,
    this.categorizedBy,
    this.itemToString,
    super.key,
  })  : assert(itemToString == null || selectedItemBuilder == null,
            'itemToString and selectedItemBuilder cannot be used together'),
        initialItem = null,
        multipleValidator = validator,
        validator = null,
        items = null,
        isMultiSelect = true,
        onChanged = null,
        type = AutocompleteType.searchAsync;

  final AutocompleteDecoration? decoration;
  final OverlayDecoration? overlayDecoration;
  final List<T>? items;
  final Future<List<T>> Function(String? query)? onAsyncQuery;
  final bool closeOnSelect;
  final AutocompleteType type;
  final bool isMultiSelect;
  final Widget Function(BuildContext context, T item)? itemBuilder;
  final Widget Function(BuildContext context, T item, VoidCallback onRemove)?
      selectedItemBuilder;
  final String? Function(T?)? validator;
  final String? Function(List<T>?)? multipleValidator;
  final AutovalidateMode? autovalidateMode;
  final Duration? debounceDuration;
  final String? Function(T item)? itemToString;
  final ValueChanged<List<T>>? onItemsChanged;
  final ValueChanged<T?>? onChanged;
  final bool enabled;
  final T? initialItem;
  final List<T>? initialItems;
  final dynamic Function(T item)? categorizedBy;

  @override
  State<AutocompleteMaterial<T>> createState() => AutocompleteMaterialState();
}

class AutocompleteMaterialState<T> extends State<AutocompleteMaterial<T>> {
  final AutocompleteMaterialController<T> controller =
      AutocompleteMaterialController<T>();

  @override
  void initState() {
    super.initState();
    controller.init(context, widget, setState);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.onTap,
      child: widget.isMultiSelect
          ? AutocompleteFormField.multiple(
              multipleValidator: widget.multipleValidator,
              autovalidateMode: widget.autovalidateMode,
              initialMultipleValue: widget.initialItems,
              multipleSelectBuilder: (state) {
                return AutocompleteMaterialInputBase(
                  layerLink: controller.layerLink,
                  decoration: controller.getDecoration(state),
                  child: ValueListenableBuilder(
                    valueListenable: controller.selectedItemsNotifier,
                    builder: (context, selectedItems, child) {
                      return Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        children: [
                          ...selectedItems.map(
                            (item) {
                              if (widget.selectedItemBuilder != null) {
                                return widget.selectedItemBuilder!(
                                  context,
                                  item,
                                  () => controller.removeItem(item),
                                );
                              }

                              return Chip(
                                label: Text(widget.itemToString?.call(item) ??
                                    item.toString()),
                                onDeleted: () => controller.removeItem(item),
                              );
                            },
                          ),
                          IntrinsicWidth(
                            stepWidth: 10.0,
                            child: _InternalTextField(
                              textEditingController:
                                  controller.textEditingController,
                              textFieldFocusNode: controller.textFieldFocusNode,
                              hintText: controller.decoration.hintText,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            )
          : AutocompleteFormField<T>.single(
              singleValidator: widget.validator,
              autovalidateMode: widget.autovalidateMode,
              initialSingleValue: widget.initialItem,
              singleSelectBuilder: (state) {
                return AutocompleteMaterialInputBase(
                  layerLink: controller.layerLink,
                  decoration: controller.getDecoration(state),
                  child: _InternalTextField(
                    textEditingController: controller.textEditingController,
                    textFieldFocusNode: controller.textFieldFocusNode,
                    hintText: controller.decoration.hintText,
                  ),
                );
              },
            ),
    );
  }
}
