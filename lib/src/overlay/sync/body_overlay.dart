import 'package:autocomplete_material/src/models/overlay_decoration.dart';
import 'package:autocomplete_material/src/utils/constants.dart';
import 'package:flutter/material.dart';

/// A widget that creates a body overlay for the autocomplete material.
///
/// This widget is used to display the overlay of the autocomplete material
/// when the user interacts with the input field.
///
/// It uses a [LayerLink] to link the overlay to the input field and
/// a [RenderBox] to get the size and position of the input field.
/// It also uses an [OverlayDecoration] to customize the appearance of the overlay.
/// The overlay is positioned above or below the input field depending on the available space.
/// The overlay is constrained to a maximum height and can be customized with a background color,
/// border radius, and elevation.
class BodyOverlay extends StatelessWidget {
  const BodyOverlay({
    super.key,
    required this.layerLink,
    required this.renderBox,
    required this.overlayDecoration,
    required this.height,
    required this.keyboardHeight,
    required this.child,
  });

  final LayerLink layerLink;
  final RenderBox renderBox;
  final OverlayDecoration overlayDecoration;
  final double height;
  final double keyboardHeight;
  final Widget child;

  double get _defaultMaxHeight => Constants.defaultOverlayMaxHeight;

  Size get size => renderBox.size;

  BoxConstraints get constraints =>
      overlayDecoration.constraints ??
      BoxConstraints(maxHeight: _defaultMaxHeight);

  bool get hasSpaceBelow =>
      renderBox.localToGlobal(Offset.zero).dy +
          size.height +
          Constants.defaultOverlayMaxHeight +
          keyboardHeight <
      height;

  Alignment get targetAnchor =>
      hasSpaceBelow ? Alignment.bottomCenter : Alignment.topCenter;

  Alignment get followerAnchor =>
      hasSpaceBelow ? Alignment.topCenter : Alignment.bottomCenter;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      width: size.width,
      child: CompositedTransformFollower(
        link: layerLink,
        showWhenUnlinked: false,
        targetAnchor: targetAnchor,
        followerAnchor: followerAnchor,
        offset: Offset(0, hasSpaceBelow ? 0 : -10),
        child: ConstrainedBox(
          constraints: constraints,
          child: Material(
            elevation: overlayDecoration.elevation,
            borderRadius: overlayDecoration.borderRadius,
            color: overlayDecoration.backgroundColor,
          ),
        ),
      ),
    );
  }
}
