import 'package:app/style/layout.dart';
import 'package:flutter/material.dart';
import 'app_overlay.dart';
import 'popup_menu.dart';
import 'overlay_container.dart';

class ListOverlay extends StatelessWidget {
  const ListOverlay({
    Key? key,
    required this.itemBuilder,
    this.itemCount,
    this.controller,
    this.width = double.infinity,
    this.height = double.infinity,
  }) : super(key: key);

  final IndexedWidgetBuilder itemBuilder;
  final int? itemCount;
  final ScrollController? controller;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: AppLayout.popupMenuItemHeight * itemCount!,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Material(
            child: SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemBuilder: itemBuilder,
                itemCount: itemCount,
                controller: controller,
              ),
            ],
          ),
        )));
  }

  static void showWithAnchor(
    BuildContext context, {
    required String identifier,
    required IndexedWidgetBuilder itemBuilder,
    int? itemCount,
    ScrollController? controller,
    double width = double.infinity,
    double height = double.infinity,
    required BuildContext anchorContext,
    AnchorDirection? anchorDirection,
    Offset? anchorOffset,
  }) {
    AppOverlay.of(context).insertWithAnchor(
      widget: ListOverlay(
        itemBuilder: itemBuilder,
        itemCount: itemCount,
        controller: controller,
        width: width,
        height: height,
      ),
      identifier: identifier,
      anchorContext: anchorContext,
      anchorDirection: anchorDirection,
      anchorOffset: anchorOffset,
    );
  }
}
