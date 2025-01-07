import 'package:flutter/material.dart';

class OverlayDecoration {
  final Widget loadingWidget;
  final Widget emptyWidget;
  final Widget errorWidget;
  final Widget? headerWidget;
  final Widget? footerWidget;
  final Widget dividerWidget;
  final Color backgroundColor;
  final BorderRadius borderRadius;
  final double elevation;
  final BoxConstraints? constraints;

  const OverlayDecoration({
    this.loadingWidget = const Center(
      child: CircularProgressIndicator.adaptive(),
    ),
    this.emptyWidget = const Center(child: Text('No results found')),
    this.errorWidget = const Center(child: Text('Error')),
    this.headerWidget,
    this.footerWidget,
    this.dividerWidget = const Divider(),
    this.backgroundColor = Colors.white,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
    this.elevation = 4,
    this.constraints,
  });
}
