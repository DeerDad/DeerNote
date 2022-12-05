import 'dart:io';
import 'dart:math';
import 'package:app/style/layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/views/home/panel/pages/editor_page.dart';
import 'package:app/views/home/menu/home_menu.dart';
import 'package:app/views/home/menu/home_menu.dart';
import 'package:app/views/home/panel/panel_stack.dart';
import 'package:app/providers/home_provider.dart';
import 'package:app/utils/log.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flutter/src/gestures/recognizer.dart';
import 'package:app/style/layout.dart';

class HomeCore extends StatefulWidget {
  @override
  HomeCoreState createState() => HomeCoreState();
}

class HomeCoreState extends State<HomeCore> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(child: buildBody(context));
  }

  Widget buildBody(BuildContext context) {
    var menu = buildMenu();
    var menuResizer = buildMenuResizer(context);
    var panelStack = PanelStack();

    return layoutWidgets(context,
        menu: menu, panelStack: panelStack, menuResizer: menuResizer);
  }

  Widget buildMenu() {
    return HomeMenu();
  }

  Widget buildMenuResizer(
    BuildContext context,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
          dragStartBehavior: DragStartBehavior.down,
          onPanUpdate: ((details) {
            setState(() {
              AppLayout.dynamicMenuWidth += details.delta.dx;
              AppLayout.dynamicMenuWidth = max(AppLayout.dynamicMenuWidth,
                  0 - AppLayout.dynamicMenuWidthDelta);
              AppLayout.dynamicMenuWidth = min(
                  AppLayout.dynamicMenuWidth, AppLayout.dynamicMenuWidthDelta);
            });
          }),
          behavior: HitTestBehavior.translucent,
          child: SizedBox(
            width: 10,
            height: MediaQuery.of(context).size.height,
          )),
    );
  }

  Widget layoutWidgets(BuildContext context,
      {required Widget menu,
      required Widget panelStack,
      required Widget menuResizer}) {
    return Selector<HomeProvider, bool>(
        selector: (p0, p1) => p1.menuCollapsed,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, value, child) {
          double menuWidth = AppLayout.menuWidth + AppLayout.dynamicMenuWidth;
          return Stack(children: [
            menu
                .positioned(
                    left: value ? -menuWidth : 0,
                    top: 0,
                    width: menuWidth,
                    bottom: 0,
                    animate: true)
                .animate(AppLayout.animDuration, Curves.easeOut),
            panelStack
                .constrained(minWidth: 500)
                .positioned(
                    left: value ? 0 : menuWidth,
                    right: 0,
                    bottom: 0,
                    top: 0,
                    animate: true)
                .animate(AppLayout.animDuration, Curves.easeOut),
            menuResizer.positioned(left: menuWidth - 5),
          ]);
        });
  }
}
