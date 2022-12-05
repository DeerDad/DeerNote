import 'dart:math';

import 'package:app/generated/p01.pb.dart';
import 'package:app/providers/appearance_provider.dart';
import 'package:app/style/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/sliver_persistent_header.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:app/main.dart';
import '../../../common/spacing.dart';
import 'package:app/providers/home_provider.dart';
import 'package:app/pages/folder_manager.dart';
import 'package:app/utils/log.dart';
import 'package:app/views/common/app_button.dart';
import 'package:app/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class RecycleBinPageHead extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      LocaleKeys.recycle_bin.tr(),
    );
  }
}

class RecycleBinPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RecycleBinPageState();
  }
}

class RecycleBinPageState extends State<StatefulWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return buildBody(context);
  }

  Widget buildBody(BuildContext context) {
    return Selector<HomeProvider, List<HomeEvent>>(
      builder: (context, value, child) {
        FolderManager folderManager = GetIt.I.get<FolderManager>();
        List<PageMemoryCache> pages = folderManager.genPagesInRecycleBin();
        int newLength = pages.length + 2;
        return Center(
          child: SizedBox(
              width: AppLayout.recyclePageWidth,
              child: Column(
                children: [
                  VSpace(AppLayout.recyclePageHeadSpace),
                  LimitedBox(
                      maxHeight:
                          min(AppLayout.recyclePageListHeight, newLength * 30),
                      child: ListView.separated(
                        itemCount: newLength,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Container();
                          } else if (index > pages.length) {
                            return Container();
                          }

                          final page = pages[index - 1];
                          return buildRecycleBinListItem(page);
                        },
                        separatorBuilder: (context, index) {
                          return Divider();
                        },
                      )),
                  VSpace(10),
                  buildMenuBar(context),
                ],
              )),
        );
      },
      shouldRebuild: (previous, next) {
        return next.contains(HomeEvent.UpdateRecycleBin);
      },
      selector: (p0, p1) {
        return p1.homeEvent;
      },
    );
  }

  Widget buildMenuBar(BuildContext context) {
    FolderManager folderManager = GetIt.I.get<FolderManager>();
    bool hasSelectedRecycleBinPagesCount =
        folderManager.hasSelectedRecycleBinPagesCount;
    bool hasRecycleBinPagesCount = folderManager.hasRecycleBinPagesCount;

    return Row(
      children: [
        AppButton(
          tip: LocaleKeys.select_all.tr(),
          icon: Icons.library_add_check_rounded,
          overrideColor: hasRecycleBinPagesCount
              ? GetIt.I.get<AppearanceProvider>().color
              : Colors.grey,
          onTap: hasRecycleBinPagesCount
              ? () {
                  FolderManager folderManager = GetIt.I.get<FolderManager>();
                  folderManager.opAllRecycleBinPages(true);
                }
              : null,
        ),
        HSpace(10),
        AppButton(
          tip: LocaleKeys.unselect_all.tr(),
          icon: Icons.library_add_check_outlined,
          overrideColor: hasRecycleBinPagesCount
              ? GetIt.I.get<AppearanceProvider>().color
              : Colors.grey,
          onTap: hasRecycleBinPagesCount
              ? () {
                  FolderManager folderManager = GetIt.I.get<FolderManager>();
                  folderManager.opAllRecycleBinPages(false);
                }
              : null,
        ),
        HSpace(10),
        AppButton(
          tip: LocaleKeys.recover_selected_pages.tr(),
          icon: Icons.recycling_rounded,
          overrideColor: hasSelectedRecycleBinPagesCount
              ? GetIt.I.get<AppearanceProvider>().color
              : Colors.grey,
          onTap: hasSelectedRecycleBinPagesCount
              ? () {
                  FolderManager folderManager = GetIt.I.get<FolderManager>();
                  folderManager.opSelectedRecycleBinPages(false);
                }
              : null,
        ),
        HSpace(10),
        AppButton(
          tip: LocaleKeys.delete_selected_pages.tr(),
          icon: Icons.delete_forever_rounded,
          overrideColor: hasSelectedRecycleBinPagesCount
              ? GetIt.I.get<AppearanceProvider>().color
              : Colors.grey,
          onTap: hasSelectedRecycleBinPagesCount
              ? () {
                  FolderManager folderManager = GetIt.I.get<FolderManager>();
                  folderManager.opSelectedRecycleBinPages(true);
                }
              : null,
        ),
      ],
    );
  }

  Widget buildRecycleBinListItem(PageMemoryCache pageMemoryCache) {
    FolderManager folderManager = GetIt.I.get<FolderManager>();
    PageProfile parentPage = pageMemoryCache.parentPageProfile;

    return Container(
        height: AppLayout.catalogItemGridSize,
        child: Row(children: [
          VerticalDivider(),
          SizedBox(
            width: AppLayout.catalogItemGridSize,
            child: Checkbox(
                activeColor: GetIt.I.get<AppearanceProvider>().color,
                value: pageMemoryCache.recycleBinSelected,
                onChanged: ((value) {
                  setState(
                    () {
                      pageMemoryCache.recycleBinSelected = value!;
                    },
                  );
                })),
          ),
          VerticalDivider(),
          Expanded(
            flex: 1,
            child: Text(pageMemoryCache.selfPageProfile.name),
          ),
          VerticalDivider(),
          Expanded(
              flex: 1,
              child: Text(
                parentPage.name.isEmpty ? "ROOT" : parentPage.name,
                style: TextStyle(
                    decoration: parentPage.deleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none),
              ))
        ]));
  }
}
