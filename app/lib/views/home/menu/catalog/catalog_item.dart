import 'dart:math';

import 'package:app/generated/p01.pb.dart';
import 'package:app/providers/home_provider.dart';
import 'package:app/routes/app_route.dart';
import 'package:app/style/layout.dart';
import 'package:app/utils/app_runtime_data.dart';
import 'package:app/views/common/spacing.dart';
import 'package:app/views/home/menu/home_catalog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app/utils/log.dart';
import 'package:flutter/rendering.dart';
import 'package:get_it/get_it.dart';
import 'package:app/providers/appearance_provider.dart';
import 'package:app/pages/folder_manager.dart';
import 'package:app/views/overlay/page_more_popup_menu.dart';
import 'package:protobuf/protobuf.dart';
import 'package:provider/provider.dart';
import 'package:app/views/common/app_button.dart';
import 'package:app/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class CatalogItemGrid extends StatelessWidget {
  late Widget child;

  CatalogItemGrid({required this.child});

  @override
  Widget build(BuildContext context) {
    return LimitedBox(
      child: child,
    );
  }
}

class CatalogItemSeparator extends StatelessWidget {
  late PageMemoryCache pageMemoryCache;
  late int depth;
  late bool front;
  CatalogItemSeparator(
      {required this.depth,
      required this.front,
      required this.pageMemoryCache});

  @override
  Widget build(BuildContext context) {
    FolderManager folderManager = GetIt.I.get<FolderManager>();
    return Row(children: [
      HSpace(AppLayout.catalogItemGridSize * depth),
      DragTarget<PageMemoryCache>(
        builder: (context, candidateItems, rejectedItems) {
          double menuWidth = AppLayout.menuWidth + AppLayout.dynamicMenuWidth;

          return SizedBox(
              height: AppLayout.draggableSeparatorHeight,
              width: max(menuWidth - AppLayout.catalogItemGridSize * depth, 0),
              child: Container(
                color: candidateItems.length > 0
                    ? GetIt.I.get<AppearanceProvider>().color.withAlpha(50)
                    : Colors.transparent,
              ));
        },
        onWillAccept: (data) {
          return folderManager.canAcceptSibling(data!, pageMemoryCache, front);
        },
        onAccept: (PageMemoryCache receiveItem) {
          folderManager.AcceptSibling(receiveItem, pageMemoryCache, front);
        },
      )
    ]);
  }
}

class CatalogItem extends StatefulWidget {
  late PageMemoryCache pageMemoryCache;
  late int depth;

  CatalogItem({required this.depth, required this.pageMemoryCache});

  @override
  State<StatefulWidget> createState() {
    return CatalogItemState();
  }
}

class CatalogItemState extends State<CatalogItem> {
  late GestureTapCallback onTapExpand;

  @override
  void initState() {
    super.initState();
    onTapExpand = () {
      setState(() {
        widget.pageMemoryCache.expanded = !widget.pageMemoryCache.expanded;
      });
    };
  }

  Widget catalogItemOperaionQuickAddSubPage() {
    return AppButton(
      icon: Icons.add,
      tip: LocaleKeys.add_sub_page.tr(),
      onTap: () {
        FolderManager folderManager = GetIt.I.get<FolderManager>();
        folderManager.addNewPage(widget.pageMemoryCache.selfPageProfile);
      },
    );
  }

  Widget catalogItemOperaionMenu() {
    return Builder(builder: (context) {
      return AppButton(
        tip: LocaleKeys.more.tr(),
        icon: Icons.more_horiz,
        onTap: () {
          PageMorePopupMenu menu = PageMorePopupMenu(onSelected: ((p0) {
            switch (p0) {
              case PageMorePopupMenuAction.delete:
                {
                  GetIt.I.get<FolderManager>().moveToRecyclePage(
                      widget.pageMemoryCache.selfPageProfile.uuid);
                }
                break;
              case PageMorePopupMenuAction.rename:
                {
                  widget.pageMemoryCache.edittingName = true;
                  GetIt.I.get<HomeProvider>().homeEvent = [
                    HomeEvent.UpdateUserFolder
                  ];
                }
                break;
            }
          }));
          menu.show(context);
        },
      );
    });
  }

  Widget catalogItemOperationSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CatalogItemGrid(
          child: catalogItemOperaionMenu(),
        ),
        CatalogItemGrid(
          child: catalogItemOperaionQuickAddSubPage(),
        ),
      ],
    );
  }

  Widget getPageSectionHead() {
    FolderManager folderManager = GetIt.I.get<FolderManager>();
    int indexOfFirstUndeletedChild = folderManager
        .indexOfFirstUndeletedChild(widget.pageMemoryCache.selfPageProfile);

    if (indexOfFirstUndeletedChild < 0) {
      return SizedBox.square(
          dimension: AppLayout.catalogItemGridSize,
          child: Center(
              child: Container(
                  height: 5,
                  width: 5,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: GetIt.I.get<AppearanceProvider>().color))));
    } else {
      if (widget.pageMemoryCache.expanded) {
        return AppButton(
          icon: Icons.arrow_drop_down_rounded,
          tip: LocaleKeys.fold.tr(),
          onTap: () {
            setState(() {
              widget.pageMemoryCache.expanded =
                  !widget.pageMemoryCache.expanded;
            });
          },
        );
      } else {
        return AppButton(
          tip: LocaleKeys.unfold.tr(),
          icon: Icons.arrow_right_rounded,
          onTap: () {
            setState(() {
              widget.pageMemoryCache.expanded =
                  !widget.pageMemoryCache.expanded;
            });
          },
        );
      }
    }
  }

  Widget PageNameSection() {
    final _controller = TextEditingController();
    _controller.text = widget.pageMemoryCache.selfPageProfile.name;
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );

    FocusNode focusNode = FocusNode();
    FolderManager folderManager = GetIt.I.get<FolderManager>();
    return StatefulBuilder(builder: ((context, setState) {
      if (!focusNode.hasListeners) {
        focusNode.addListener(
          () {
            setState(
              () {
                widget.pageMemoryCache.edittingName = focusNode.hasFocus;
                folderManager.updatePageName(
                    widget.pageMemoryCache.selfPageProfile.uuid,
                    _controller.text);
              },
            );
          },
        );
      }

      return !widget.pageMemoryCache.edittingName
          ? InkWell(
              child: Text(_controller.text),
              onTap: () {
                GetIt.I
                    .get<HomeProvider>()
                    .selectPage(widget.pageMemoryCache.selfPageProfile.uuid);
              },
            )
          : Expanded(
              child: Container(
                  height: AppLayout.catalogItemGridSize,
                  child: TextField(
                    focusNode: focusNode,
                    autofocus: true,
                    controller: _controller,
                    decoration: InputDecoration(border: InputBorder.none),
                    onSubmitted: (value) {
                      folderManager.updatePageName(
                          widget.pageMemoryCache.selfPageProfile.uuid,
                          _controller.text);
                    },
                  )));
    }));
  }

  Widget catalogItemPageSection() {
    return Row(
      children: [
        HSpace(AppLayout.catalogItemGridSize * widget.depth),
        CatalogItemGrid(child: getPageSectionHead()),
        PageNameSection(),
      ],
    );
  }

  Widget subPagesSection() {
    FolderManager folderManager = GetIt.I.get<FolderManager>();
    int indexOfFirstUndeletedChild = folderManager
        .indexOfFirstUndeletedChild(widget.pageMemoryCache.selfPageProfile);

    if (indexOfFirstUndeletedChild < 0 ||
        widget.pageMemoryCache.expanded == false) {
      return Container();
    }
    PageProfile showPage = widget.pageMemoryCache.selfPageProfile;
    return HomeCatalog.getListView(context, showPage, widget.depth, true);
  }

  Widget DragableWrapperItem(Widget child) {
    return DragTarget<PageMemoryCache>(
      builder: (context, candidateItems, rejectedItems) {
        return LongPressDraggable<PageMemoryCache>(
            data: widget.pageMemoryCache,
            dragAnchorStrategy: pointerDragAnchorStrategy,
            feedback: Builder(
              builder: (context) {
                return Container(
                    height: AppLayout.draggableHeight,
                    child: FittedBox(
                        fit: BoxFit.fitHeight,
                        child: Text(
                          widget.pageMemoryCache.selfPageProfile.name,
                          style: TextStyle(
                              decoration: TextDecoration.none,
                              color: Colors.black.withAlpha(100)),
                        )));
              },
            ),
            child: Container(
              child: child,
              color: candidateItems.isNotEmpty
                  ? GetIt.I.get<AppearanceProvider>().color.withAlpha(50)
                  : Colors.transparent,
            ));
      },
      onWillAccept: (data) {
        FolderManager folderManager = GetIt.I.get<FolderManager>();
        return folderManager.canAcceptIn(data!, widget.pageMemoryCache);
      },
      onAccept: (PageMemoryCache pageMemoryCache) {
        FolderManager folderManager = GetIt.I.get<FolderManager>();
        return folderManager.AcceptIn(pageMemoryCache, widget.pageMemoryCache);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Stack(
        children: [
          DragableWrapperItem(catalogItemPageSection()),
          catalogItemOperationSection()
        ],
      ),
      subPagesSection(),
    ]);
  }
}
