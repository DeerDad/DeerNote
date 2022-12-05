import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import '../../../utils/log.dart';
import 'popup_menu.dart';
import 'app_overlay_delegate.dart';
import '../../../utils/app_error.dart';

class OverlayItem {
  Widget widget;
  String identifier;
  FocusNode focusNode;

  OverlayItem({
    required this.widget,
    required this.identifier,
    required this.focusNode,
  });

  void dispose() {}
}

class AppOverlay extends StatefulWidget {
  AppOverlay({Key? key, required this.child}) : super(key: key);
  final Widget child;

  static AppLayoutState of(BuildContext context, {bool rootOverlay = false}) {
    AppLayoutState? state = maybeOf(context, rootOverlay: rootOverlay);
    assert(() {
      if (state == null) {
        throw FlutterError(
          'Can\'t find overlay manager in current context, please check if already wrapped by overlay manager.',
        );
      }
      return true;
    }());
    return state!;
  }

  static AppLayoutState? maybeOf(BuildContext context,
      {bool rootOverlay = false}) {
    AppLayoutState? state;
    if (rootOverlay) {
      state = context.findRootAncestorStateOfType<AppLayoutState>();
    } else {
      state = context.findAncestorStateOfType<AppLayoutState>();
    }
    return state;
  }

  @override
  State<StatefulWidget> createState() {
    return AppLayoutState();
  }
}

class AppLayoutState extends State<AppOverlay> {
  List<OverlayItem> items = [];

  insertItem(OverlayItem item) {
    setState(() {
      items.add(item);
    });
  }

  removeItem(String identifier) {
    final index = items.indexWhere((item) => item.identifier == identifier);
    if (index != -1) {
      setState(() {
        final OverlayItem item = items.removeAt(index);
        item.dispose();
      });
    }
  }

  removeAllItems() {
    setState(() {
      if (items.isEmpty) {
        return;
      }

      for (int i = 0; i < items.length; i++) {
        items[i].dispose();
      }

      items.clear();
    });
  }

  handTapBackground() {
    removeAllItems();
  }

  void insertWithAnchor({
    required Widget widget,
    required String identifier,
    required BuildContext anchorContext,
    AnchorDirection? anchorDirection,
    Offset? anchorOffset,
  }) {
    _showOverlay(
      widget: widget,
      identifier: identifier,
      shouldAnchor: true,
      anchorContext: anchorContext,
      anchorDirection: anchorDirection,
      anchorOffset: anchorOffset,
    );
  }

  void _showOverlay({
    required Widget widget,
    required String identifier,
    required bool shouldAnchor,
    Offset? anchorPosition,
    Size? anchorSize,
    AnchorDirection? anchorDirection,
    BuildContext? anchorContext,
    Offset? anchorOffset,
  }) {
    Log.trace("Show overlay: $identifier");
    Widget overlay = widget;
    final offset = anchorOffset ?? Offset.zero;
    final focusNode = FocusNode();
    if (shouldAnchor) {
      assert(
        anchorPosition != null || anchorContext != null,
        'Must provide `anchorPosition` or `anchorContext` to locating overlay.',
      );
      Offset targetAnchorPosition = anchorPosition ?? Offset.zero;
      Size targetAnchorSize = anchorSize ?? Size.zero;
      if (anchorContext != null) {
        RenderObject renderObject = anchorContext.findRenderObject()!;
        assert(
          renderObject is RenderBox,
          'Unexpected non-RenderBox render object caught.',
        );
        final renderBox = renderObject as RenderBox;
        targetAnchorPosition = renderBox.localToGlobal(Offset.zero);
        targetAnchorSize = renderBox.size;
      }
      final anchorRect = Rect.fromLTWH(
        targetAnchorPosition.dx + offset.dx,
        targetAnchorPosition.dy + offset.dy,
        targetAnchorSize.width,
        targetAnchorSize.height,
      );

      overlay = CustomSingleChildLayout(
        delegate: OverlayLayoutDelegate(
          anchorRect: anchorRect,
          anchorDirection:
              anchorDirection ?? AnchorDirection.rightWithTopAligned,
        ),
        child: Focus(focusNode: focusNode, child: widget),
      );
    }

    setState(() {
      items.add(OverlayItem(
        widget: overlay,
        identifier: identifier,
        focusNode: focusNode,
      ));
    });
  }

  Widget? buildBackground(BuildContext context, List<Widget> overlays) {
    Widget? child;
    if (overlays.isNotEmpty) {
      child = Container(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: handTapBackground,
        ),
      );
    }

    return child;
  }

  Widget buildErrorBar(BuildContext context) {
    return AppErrorTip();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [widget.child];
    List<Widget> overlays = items.map((e) => e.widget).toList();
    Widget? background = buildBackground(context, overlays);
    Widget errorTip = buildErrorBar(context);

    if (background != null) {
      children.add(background);
    }

    return Stack(
        children: children
          ..addAll(overlays)
          ..add(errorTip));
  }
}
