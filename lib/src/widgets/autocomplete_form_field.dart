import 'package:flutter/material.dart';

class AutocompleteFormField<T> extends StatelessWidget {
  const AutocompleteFormField.single({
    required this.singleSelectBuilder,
    super.key,
    this.initialSingleValue,
    this.singleValidator,
    this.autovalidateMode,
  })  : isMultiple = false,
        multipleValidator = null,
        multipleSelectBuilder = null,
        initialMultipleValue = null;

  const AutocompleteFormField.multiple({
    required this.multipleSelectBuilder,
    super.key,
    this.initialMultipleValue,
    this.multipleValidator,
    this.autovalidateMode,
  })  : isMultiple = true,
        singleValidator = null,
        singleSelectBuilder = null,
        initialSingleValue = null;

  final Widget Function(FormFieldState<List<T>> state)? multipleSelectBuilder;
  final Widget Function(FormFieldState<T> state)? singleSelectBuilder;

  final T? initialSingleValue;
  final List<T>? initialMultipleValue;

  final FormFieldValidator<T>? singleValidator;
  final FormFieldValidator<List<T>>? multipleValidator;

  final AutovalidateMode? autovalidateMode;
  final bool isMultiple;

  @override
  Widget build(BuildContext context) {
    if (isMultiple) {
      return FormField<List<T>>(
        initialValue: initialMultipleValue,
        validator: multipleValidator,
        autovalidateMode: autovalidateMode,
        builder: multipleSelectBuilder!,
      );
    }
    return FormField<T>(
      initialValue: initialSingleValue,
      validator: singleValidator,
      autovalidateMode: autovalidateMode,
      builder: singleSelectBuilder!,
    );
  }
}
