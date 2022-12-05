import 'package:flutter/material.dart';

const overlayContainerPadding = EdgeInsets.all(12);

class OverlayContainer extends StatelessWidget {
  final Widget child;
  final BoxConstraints? constraints;
  final EdgeInsets padding;
  const OverlayContainer({
    required this.child,
    this.constraints,
    this.padding = overlayContainerPadding,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        padding: padding,
        constraints: constraints,
        child: child,
      ),
    );
  }
}
