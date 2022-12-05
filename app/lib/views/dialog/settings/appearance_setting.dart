import 'package:app/utils/app_config.dart';
import 'package:flutter/material.dart';
import './setting_item.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../common/spacing.dart';
import 'package:app/providers/appearance_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:app/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class AppearanceSettingItem extends SettingItem {
  static const String SETTING_NAME = 'APPEARANCE';
  String getItemTitle() {
    return LocaleKeys.appearance.tr();
  }

  Widget getItemPanel(BuildContext context) {
    AppConfig appConfig = AppConfig();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              height: 50,
              child: FittedBox(
                  fit: BoxFit.fitHeight,
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                titlePadding: const EdgeInsets.all(0),
                                contentPadding: const EdgeInsets.all(0),
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25))),
                                content: SingleChildScrollView(
                                  child: SlidePicker(
                                    pickerColor: appConfig.getColor(),
                                    enableAlpha: false,
                                    onColorChanged: (value) {
                                      appConfig.setColor(value);
                                    },
                                    indicatorBorderRadius:
                                        const BorderRadius.vertical(
                                            top: Radius.circular(25)),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Text(
                          LocaleKeys.color.tr(),
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: appConfig.getColor(),
                          shadowColor: appConfig.getColor().withOpacity(1),
                          elevation: 10,
                        ),
                      ),
                    ],
                  ))),
        ],
      ),
    );
  }
}
