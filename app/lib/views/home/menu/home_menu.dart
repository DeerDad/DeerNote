import 'dart:developer';
import 'dart:math';

import 'package:app/style/layout.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:styled_widget/styled_widget.dart';
import '../../common/spacing.dart';
import 'home_catalog.dart';
import 'home_headbar.dart';
import 'package:app/utils/log.dart';
import 'package:app/style/layout.dart';

class HomeMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return buildBody();
  }

  // menu head
  // catalog
  // recycler
  Widget buildBody() {
    return LayoutBuilder(builder: (p0, p1) {
      double catalogHeight = max(
          0,
          p1.maxHeight -
              AppLayout.catalogItemGridSize * 2 -
              10 -
              AppLayout.homeMenuDividerHeight);

      return Container(
        color: AppLayout.menuBackgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            HomeHeadBar(),
            const Divider(height: AppLayout.homeMenuDividerHeight),
            Expanded(
              child: HomeCatalog(),
            ),
          ],
        ),
      );
    });
  }
}
