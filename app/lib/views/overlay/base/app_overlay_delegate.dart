import 'dart:math' as math;
import 'dart:math';
import 'package:flutter/material.dart';
import 'popup_menu.dart';
import 'package:app/style/layout.dart';

class OverlayLayoutDelegate extends SingleChildLayoutDelegate {
  OverlayLayoutDelegate({
    required this.anchorRect,
    required this.anchorDirection,
  });

  final Rect anchorRect;
  final AnchorDirection anchorDirection;

  @override
  bool shouldRelayout(OverlayLayoutDelegate oldDelegate) {
    return anchorRect != oldDelegate.anchorRect ||
        anchorDirection != oldDelegate.anchorDirection;
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    BoxConstraints childConstraints = BoxConstraints.loose(Size(
        min(constraints.maxWidth, AppLayout.popupMenuItemWidth),
        constraints.maxHeight - anchorRect.bottom));
    return childConstraints;
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    Offset position;
    switch (anchorDirection) {
      case AnchorDirection.topLeft:
        position = Offset(
          anchorRect.left - childSize.width,
          anchorRect.top - childSize.height,
        );
        break;
      case AnchorDirection.topRight:
        position = Offset(
          anchorRect.right,
          anchorRect.top - childSize.height,
        );
        break;
      case AnchorDirection.bottomLeft:
        position = Offset(
          anchorRect.left - childSize.width,
          anchorRect.bottom,
        );
        break;
      case AnchorDirection.bottomRight:
        position = Offset(
          anchorRect.right,
          anchorRect.bottom,
        );
        break;
      case AnchorDirection.center:
        position = anchorRect.center;
        break;
      case AnchorDirection.topWithLeftAligned:
        position = Offset(
          anchorRect.left,
          anchorRect.top - childSize.height,
        );
        break;
      case AnchorDirection.topWithCenterAligned:
        position = Offset(
          anchorRect.left + anchorRect.width / 2.0 - childSize.width / 2.0,
          anchorRect.top - childSize.height,
        );
        break;
      case AnchorDirection.topWithRightAligned:
        position = Offset(
          anchorRect.right - childSize.width,
          anchorRect.top - childSize.height,
        );
        break;
      case AnchorDirection.rightWithTopAligned:
        position = Offset(anchorRect.right, anchorRect.top);
        break;
      case AnchorDirection.rightWithCenterAligned:
        position = Offset(
          anchorRect.right,
          anchorRect.top + anchorRect.height / 2.0 - childSize.height / 2.0,
        );
        break;
      case AnchorDirection.rightWithBottomAligned:
        position = Offset(
          anchorRect.right,
          anchorRect.bottom - childSize.height,
        );
        break;
      case AnchorDirection.bottomWithLeftAligned:
        position = Offset(
          anchorRect.left,
          anchorRect.bottom,
        );
        break;
      case AnchorDirection.bottomWithCenterAligned:
        position = Offset(
          anchorRect.left + anchorRect.width / 2.0 - childSize.width / 2.0,
          anchorRect.bottom,
        );
        break;
      case AnchorDirection.bottomWithRightAligned:
        position = Offset(
          anchorRect.right - childSize.width,
          anchorRect.bottom,
        );
        break;
      case AnchorDirection.leftWithTopAligned:
        position = Offset(
          anchorRect.left - childSize.width,
          anchorRect.top,
        );
        break;
      case AnchorDirection.leftWithCenterAligned:
        position = Offset(
          anchorRect.left - childSize.width,
          anchorRect.top + anchorRect.height / 2.0 - childSize.height / 2.0,
        );
        break;
      case AnchorDirection.leftWithBottomAligned:
        position = Offset(
          anchorRect.left - childSize.width,
          anchorRect.bottom - childSize.height,
        );
        break;
      default:
        throw UnimplementedError();
    }
    return Offset(
      math.max(0.0, math.min(size.width - childSize.width, position.dx)),
      math.max(0.0, math.min(size.height - childSize.height, position.dy)),
    );
  }
}
