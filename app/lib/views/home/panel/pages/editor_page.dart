import 'dart:convert';

import 'package:app/generated/p01.pb.dart';
import 'package:app/pages/folder_manager.dart';
import 'package:app/providers/appearance_provider.dart';
import 'package:app/style/layout.dart';
import 'package:app/views/home_view.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/home_provider.dart';
import '../../../common/spacing.dart';
import '../../../../utils/log.dart';

class EditorPageHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<HomeProvider, String>(
        selector: (p0, p1) => p1.lastSelectPage,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, value, child) {
          return Selector<HomeProvider, List<HomeEvent>>(
            builder: (context, event, child) {
              if (value.isEmpty) {
                return Container();
              }

              FolderManager folderManager = GetIt.I.get<FolderManager>();
              List<PageMemoryCache> pageChain = [];
              folderManager.getPagesChain(value, pageChain);

              final scrollController = ScrollController();
              return Flexible(
                  child: Scrollbar(
                      controller: scrollController,
                      child: ListView.separated(
                          controller: scrollController,
                          itemBuilder: (context, index) {
                            return InkWell(
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                    pageChain[pageChain.length - index - 1]
                                        .selfPageProfile
                                        .name),
                              ),
                              onTap: () {
                                GetIt.I.get<HomeProvider>().selectPage(
                                    pageChain[pageChain.length - index - 1]
                                        .selfPageProfile
                                        .uuid);
                              },
                            );
                          },
                          separatorBuilder: (context, index) {
                            return Icon(
                              Icons.keyboard_double_arrow_right_rounded,
                              color: GetIt.I.get<AppearanceProvider>().color,
                            );
                          },
                          itemCount: pageChain.length,
                          scrollDirection: Axis.horizontal)));
            },
            shouldRebuild: (previous, next) {
              return next.contains(HomeEvent.UpdateEditorHead);
            },
            selector: (p0, p1) => p1.homeEvent,
          );
        });
  }
}

class EditorPage extends StatefulWidget {
  EditorPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EditorPageState();
  }
}

class EditorPageState extends State<EditorPage>
    with SingleTickerProviderStateMixin {
  late ScrollController scrollController;
  late Ticker _ticker;
  late quill.QuillController controller;
  int lastHashCode = 0;
  String uuid = "";

  @override
  void dispose() {
    // TODO: implement dispose
    scrollController.dispose();
    _ticker.dispose();
    controller.dispose();

    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scrollController = ScrollController();
    controller = quill.QuillController(
      document: quill.Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );
    lastHashCode = 0;

    _ticker = createTicker((elapsed) {
      if (lastHashCode == 0) {
        return;
      }

      int newHashCode = controller.document.toDelta().hashCode;
      if (newHashCode != lastHashCode) {
        FolderManager folderManager = GetIt.I.get<FolderManager>();

        lastHashCode = newHashCode;

        folderManager.updatePageDetail(
            uuid, jsonEncode(controller.document.toDelta().toJson()));
      }
    });
    _ticker.start();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<HomeProvider, String>(
      selector: (p0, p1) => p1.lastSelectPage,
      shouldRebuild: (previous, next) => next != "",
      builder: (context, value, child) {
        uuid = value;
        return buildDocument(context, value);
      },
    );
  }

  Widget buildDocument(BuildContext context, String page) {
    FolderManager folderManager = GetIt.I.get<FolderManager>();
    PageMemoryCache pageMemoryCache = folderManager.findPageMemoryCache(page)!;
    assert(pageMemoryCache.selfPageDetail != null);

    if (pageMemoryCache.selfPageDetail!.content.isEmpty == false) {
      controller.document = quill.Document.fromJson(
          jsonDecode(pageMemoryCache.selfPageDetail!.content) as List<dynamic>);
    } else {
      controller.document = quill.Document();
    }

    lastHashCode = controller.document.toDelta().hashCode;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _renderEditor(controller),
        _renderToolbar(controller),
      ],
    );
  }

  Widget _renderEditor(quill.QuillController controller) {
    final editor = quill.QuillEditor(
      controller: controller,
      focusNode: FocusNode(),
      scrollable: true,
      paintCursorAboveText: true,
      autoFocus: true,
      expands: false,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      readOnly: false,
      scrollBottomInset: 0,
      scrollController: scrollController,
    );

    return Expanded(
      child: editor,
    );
  }

  Widget _renderToolbar(quill.QuillController controller) {
    return quill.QuillToolbar.basic(controller: controller);
  }
}
