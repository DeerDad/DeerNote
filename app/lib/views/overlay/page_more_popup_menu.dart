import 'package:flutter/material.dart';
import 'base/popup_menu.dart';
import 'package:dartz/dartz.dart';
import '../../generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

enum PageMorePopupMenuAction {
  rename,
  delete,
}

extension PageMorePopupMenuActionExtension on PageMorePopupMenuAction {
  String get name {
    switch (this) {
      case PageMorePopupMenuAction.rename:
        return LocaleKeys.rename.tr();
      case PageMorePopupMenuAction.delete:
        return LocaleKeys.move_to_recycle_bin.tr();
    }
  }
}

class PageMorePopupMenu with PopupMenu<PageMorePopupMenuActionWrapper> {
  final Function(PageMorePopupMenuAction) onSelected;
  final _items = PageMorePopupMenuAction.values
      .map((action) => PageMorePopupMenuActionWrapper(action))
      .toList();
  String get identifier => 'PageMorePopupMenu';

  PageMorePopupMenu({
    required this.onSelected,
  });

  @override
  List<PageMorePopupMenuActionWrapper> get items => _items;

  @override
  void Function(PageMorePopupMenuActionWrapper p1) get selectCallback =>
      (result) {
        onSelected(result.inner);
      };
}

class PageMorePopupMenuActionWrapper extends ActionItem {
  final PageMorePopupMenuAction inner;

  PageMorePopupMenuActionWrapper(this.inner);

  @override
  String get name => inner.name;
}
