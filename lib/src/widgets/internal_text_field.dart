part of '../autocomplete_material.dart';

class _InternalTextField extends StatelessWidget {
  const _InternalTextField({
    required this.textEditingController,
    required this.textFieldFocusNode,
    this.layerLink,
    this.decoration,
    this.onTap,
  });

  final TextEditingController textEditingController;
  final FocusNode textFieldFocusNode;
  final LayerLink? layerLink;
  final InputDecoration? decoration;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textField = TextField(
      controller: textEditingController,
      focusNode: textFieldFocusNode,
      onTap: onTap,
      decoration: decoration,
    );
    if (layerLink == null) {
      return AbsorbPointer(
        child: ColoredBox(
          color: Colors.transparent,
          child: textField,
        ),
      );
    }

    return CompositedTransformTarget(
      link: layerLink!,
      child: textField,
    );
  }
}
