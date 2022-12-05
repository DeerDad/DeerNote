import 'package:app/style/layout.dart';
import 'package:app/views/common/spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/home_provider.dart';
import '../../../utils/log.dart';
import 'package:app/providers/appearance_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:app/views/common/app_button.dart';
import 'package:app/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class BasePanel extends StatelessWidget {
  final Widget? head;
  final Widget? body;

  const BasePanel({Key? key, this.head, this.body}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildBody(context);
  }

  Widget buildHead(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Container(
            height: AppLayout.catalogItemGridSize * 2,
            child: Row(
              children: [
                StatefulBuilder(
                  builder: (context, setState) {
                    return AppButton(
                      tip: context.read<HomeProvider>().menuCollapsed
                          ? LocaleKeys.show_catalog.tr()
                          : LocaleKeys.hide_catalog.tr(),
                      icon: context.read<HomeProvider>().menuCollapsed
                          ? Icons.arrow_right_rounded
                          : Icons.arrow_left_rounded,
                      onTap: () {
                        setState(
                          () {
                            bool menuCollapsed =
                                context.read<HomeProvider>().menuCollapsed;
                            context.read<HomeProvider>().menuCollapsed =
                                !menuCollapsed;
                          },
                        );
                      },
                    );
                  },
                ),
                HSpace(AppLayout.catalogItemGridSize),
                head ?? Container()
              ],
            )));
  }

  Widget buildBody(BuildContext context) {
    return Column(children: [
      Container(child: buildHead(context)),
      Divider(),
      Expanded(child: body ?? Container()),
    ]);
  }
}
