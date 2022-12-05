import 'package:app/style/layout.dart';
import 'package:flutter/material.dart';
import 'app_overlay.dart';
import 'list_overlay.dart';
import '../../common/spacing.dart';
import 'package:dartz/dartz.dart';
import 'package:app/providers/appearance_provider.dart';
import 'package:get_it/get_it.dart';

/// Specifies how overlay are anchored to the SourceWidget
enum AnchorDirection {
  // Corner aligned with a corner of the SourceWidget
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  center,

  // Edge aligned with a edge of the SourceWidget
  topWithLeftAligned,
  topWithCenterAligned,
  topWithRightAligned,
  rightWithTopAligned,
  rightWithCenterAligned,
  rightWithBottomAligned,
  bottomWithLeftAligned,
  bottomWithCenterAligned,
  bottomWithRightAligned,
  leftWithTopAligned,
  leftWithCenterAligned,
  leftWithBottomAligned,

  // Custom position
  custom,
}

abstract class PopupMenu<T extends ActionItem> {
  List<T> get items;
  String get identifier => toString();
  void Function(T) get selectCallback;

  void show(
    BuildContext buildContext, {
    BuildContext? anchorContext,
    AnchorDirection anchorDirection = AnchorDirection.bottomWithLeftAligned,
    Offset? anchorOffset,
  }) {
    final widgets = items
        .map(
          (action) => ActionCell<T>(
            action: action,
            itemHeight: AppLayout.popupMenuItemHeight,
            onSelected: (action) {
              AppOverlay.of(buildContext).removeItem(identifier);
              selectCallback(action);
            },
          ),
        )
        .toList();

    ListOverlay.showWithAnchor(
      buildContext,
      identifier: identifier,
      itemCount: widgets.length,
      itemBuilder: (context, index) => widgets[index],
      anchorContext: anchorContext ?? buildContext,
      anchorDirection: anchorDirection,
      width: AppLayout.popupMenuItemWidth,
      height: widgets.length *
          (AppLayout.popupMenuItemHeight + ActionListSizes.padding * 2),
      anchorOffset: anchorOffset,
    );
  }
}

abstract class ActionItem {
  String get name;
}

class ActionListSizes {
  static double itemHPadding = 10;
  static double padding = 6;
}

class ActionCell<T extends ActionItem> extends StatelessWidget {
  final T action;
  final Function(T) onSelected;
  final double itemHeight;
  const ActionCell({
    Key? key,
    required this.action,
    required this.onSelected,
    required this.itemHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      height: AppLayout.popupMenuItemHeight,
      width: AppLayout.popupMenuItemWidth,
      child: InkWell(
          onTap: () => onSelected(action),
          child: SizedBox(
              height: AppLayout.popupMenuItemHeight,
              width: AppLayout.popupMenuItemWidth,
              child: Padding(
                  padding: EdgeInsets.only(
                    left: 10,
                  ),
                  child: Text(action.name,
                      style: TextStyle(
                          color: GetIt.I.get<AppearanceProvider>().color))))),
    );
  }
}
