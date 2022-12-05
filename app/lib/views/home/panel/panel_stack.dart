import 'package:app/views/basic_widget_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/home_provider.dart';
import 'package:app/views/home_view.dart';
import 'base_panel.dart';
import '../panel/pages/editor_page.dart';
import '../panel/pages/recyclebin_page.dart';
import '../panel/pages/blank_page.dart';
import '../../../utils/log.dart';

class PanelStack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return buildBody(context);
  }

  Widget buildBody(BuildContext context) {
    return Selector<HomeProvider, HomeMode>(
        selector: (p0, p1) => p1.homeMode,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, value, child) {
          return BasePanel(
            head: BasicWidgetWrapper(builder: (context) {
              return BuildPanelHead(context, value);
            }),
            body: BuildPanelBody(context, value),
          );
        });
  }

  Widget BuildPanelHead(BuildContext context, HomeMode mode) {
    switch (mode) {
      case HomeMode.PageMode:
        {
          return EditorPageHeader();
        }
        break;
      case HomeMode.RecycleBinMode:
        {
          return RecycleBinPageHead();
        }
      case HomeMode.BlankMode:
      default:
        {
          return Container();
        }
        break;
    }
  }

  Widget BuildPanelBody(BuildContext context, HomeMode mode) {
    switch (mode) {
      case HomeMode.PageMode:
        {
          return EditorPage();
        }
        break;
      case HomeMode.RecycleBinMode:
        {
          return RecycleBinPage();
        }
        break;
      case HomeMode.BlankMode:
      default:
        {
          return BlankPage();
        }
        break;
    }
  }
}
