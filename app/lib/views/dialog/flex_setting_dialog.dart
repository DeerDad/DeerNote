import 'package:app/utils/app_error.dart';
import 'package:app/views/dialog/settings/setting_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../common/spacing.dart';
import '../../utils/log.dart';
import '../../style/layout.dart';
import './settings/locale_setting.dart';
import './settings/network_setting.dart';
import 'settings/appearance_setting.dart';
import 'package:app/providers/appearance_provider.dart';
import 'package:app/providers/locale_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:app/views/basic_widget_wrapper.dart';
import 'package:app/views/dialog/settings/nickname_setting.dart';
import 'package:app/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class FlexSettingDialog extends StatefulWidget {
  SettingItem getItem(String name) {
    switch (name) {
      case LocaleSettingItem.SETTING_NAME:
        {
          return LocaleSettingItem();
        }
      case NetworkSettingItem.SETTING_NAME:
        {
          return NetworkSettingItem();
        }
      case AppearanceSettingItem.SETTING_NAME:
        {
          return AppearanceSettingItem();
        }
      case NicknameSettingItem.SETTING_NAME:
        {
          return NicknameSettingItem();
        }
      default:
        {
          return SettingItem();
        }
    }
  }

  final List<String> items;
  FlexSettingDialog(this.items);

  @override
  State<FlexSettingDialog> createState() {
    // TODO: implement createState
    return FlexSettingDialogState();
  }
}

class FlexSettingDialogState extends State<FlexSettingDialog> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BasicWidgetWrapper(builder: (context) {
      return buildBody(context);
    });
  }

  Widget buildLeft(BuildContext context) {
    return Material(
        child: ListView.builder(
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        SettingItem settingItem = widget.getItem(widget.items[index]);
        return ListTile(
          selectedTileColor: GetIt.I.get<AppearanceProvider>().color,
          selectedColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          minLeadingWidth: 0,
          selected: selectedIndex == index,
          title: FittedBox(
              fit: BoxFit.fitWidth, child: Text(settingItem.getItemTitle())),
          onTap: () {
            if (selectedIndex == index) {
              return;
            }

            setState(() {
              selectedIndex = index;
            });
          },
        );
      },
    ));
  }

  Widget buildRight(BuildContext context) {
    SettingItem settingItem = widget.getItem(widget.items[selectedIndex]);
    return settingItem.getItemPanel(context);
  }

  Widget buildBody(BuildContext context) {
    return Center(
        child: ConstrainedBox(
      constraints: BoxConstraints(
          minHeight: AppLayout.settingDialogHeight,
          maxHeight: AppLayout.settingDialogHeight,
          minWidth: AppLayout.settingDialogWidth,
          maxWidth: AppLayout.settingDialogWidth),
      child: Container(
        color: Colors.white,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                SizedBox(
                  height: AppLayout.settingDialogTitleHeight,
                  child: FittedBox(
                    fit: BoxFit.fitHeight,
                    child: Text(
                      LocaleKeys.user_setting.tr(),
                      style: TextStyle(
                          decoration: TextDecoration.none,
                          color: GetIt.I.get<AppearanceProvider>().color),
                    ),
                  ),
                ),
                Divider(
                  height: AppLayout.settingDialogDividerHeight,
                ),
                Row(
                  children: [
                    Expanded(
                        flex: AppLayout.settingLeftFlex,
                        child: Container(
                          height: AppLayout.settingDialogHeight -
                              AppLayout.settingDialogTitleHeight -
                              AppLayout.settingDialogDividerHeight,
                          child: buildLeft(context),
                        )),
                    VerticalDivider(),
                    Expanded(
                        flex: AppLayout.settingRightFlex,
                        child: Container(
                          color: Colors.white,
                          child: Container(
                            height: AppLayout.settingDialogHeight -
                                AppLayout.settingDialogTitleHeight -
                                AppLayout.settingDialogDividerHeight,
                            child: buildRight(context),
                          ),
                        ))
                  ],
                )
              ],
            );
          },
        ),
      ),
    ));
  }
}
