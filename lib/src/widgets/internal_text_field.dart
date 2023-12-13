part of '../autocomplete_material.dart';

class _InternalTextField extends StatelessWidget {
  const _InternalTextField({
    required this.textEditingController,
    required this.textFieldFocusNode,
    required this.hintText,
  });

  final TextEditingController textEditingController;
  final FocusNode textFieldFocusNode;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.transparent,
      child: AbsorbPointer(
        child: TextField(
          controller: textEditingController,
          focusNode: textFieldFocusNode,
          decoration: InputDecoration(
            hintText: hintText,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
