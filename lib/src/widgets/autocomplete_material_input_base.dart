import 'package:flutter/material.dart';

class AutocompleteMaterialInputBase extends StatelessWidget {
  const AutocompleteMaterialInputBase({
    required this.child,
    required this.layerLink,
    required this.decoration,
    super.key,
  });

  final Widget child;
  final LayerLink layerLink;
  final InputDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: layerLink,
      child: InputDecorator(decoration: decoration, child: child),
    );
  }
}
