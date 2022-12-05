import 'package:app/pages/folder_manager.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:flutter/src/widgets/form.dart';
import 'package:app/utils/log.dart';
import 'package:app/views/login_view.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:expandable/expandable.dart';
import 'package:app/generated/p01.pb.dart';
import 'package:app/views/home/menu/catalog/catalog_item.dart';
import 'package:app/providers/home_provider.dart';

class HomeCatalog extends StatelessWidget {
  HomeCatalog({Key? key}) : super(key: key);

  static Widget getListView(BuildContext context, PageProfile pageProfile,
      int depth, bool shrinkWrap) {
    FolderManager folderManager = GetIt.I.get<FolderManager>();

    int indexOfFirstUndeletedChild =
        folderManager.indexOfFirstUndeletedChild(pageProfile);
    int newLength =
        indexOfFirstUndeletedChild < 0 ? 0 : pageProfile.subPages.length + 2;

    return ListView.separated(
      shrinkWrap: shrinkWrap,
      separatorBuilder: (context, index) {
        if (index < indexOfFirstUndeletedChild) {
          return Container();
        }

        if (index == indexOfFirstUndeletedChild) {
          return CatalogItemSeparator(
              depth: depth + 1,
              front: true,
              pageMemoryCache: folderManager
                  .findPageMemoryCache(pageProfile.subPages[index].uuid)!);
        }

        if (pageProfile.subPages[index - 1].deleted) {
          return Container();
        }

        return CatalogItemSeparator(
            depth: depth + 1,
            front: false,
            pageMemoryCache: folderManager
                .findPageMemoryCache(pageProfile.subPages[index - 1].uuid)!);
      },
      itemCount: newLength,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container();
        } else if (index > pageProfile.subPages.length) {
          return Container();
        }

        if (pageProfile.subPages[index - 1].deleted) {
          return Container();
        }

        return CatalogItem(
            depth: depth + 1,
            pageMemoryCache: folderManager
                .findPageMemoryCache(pageProfile.subPages[index - 1].uuid)!);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<HomeProvider, List<HomeEvent>>(
      selector: (p0, p1) {
        return p1.homeEvent;
      },
      shouldRebuild: (previous, next) {
        return next.contains(HomeEvent.UpdateUserFolder);
      },
      builder: (context, value, child) {
        FolderManager folderManager = GetIt.I.get<FolderManager>();
        PageProfile showPage = folderManager.userFolder.rootPage;

        return getListView(context, showPage, -1, false);
      },
    );
  }
}
