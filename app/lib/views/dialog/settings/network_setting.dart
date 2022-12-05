import 'dart:math';

import 'package:app/providers/appearance_provider.dart';
import 'package:app/utils/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import './setting_item.dart';
import '../../common/spacing.dart';
import 'package:app/providers/appearance_provider.dart';
import 'package:app/providers/locale_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app/generated/locale_keys.g.dart';

class RangeNumberInputFormatter extends TextInputFormatter {
  final int maxValue;
  final int minValue;
  RangeNumberInputFormatter({this.maxValue = 65535, this.minValue = 1});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    int value = newValue.text.isEmpty ? 0 : int.parse(newValue.text);
    value = min(max(minValue, value), maxValue);
    return TextEditingValue(
      text: value.toString(),
      selection: newValue.selection,
    );
  }
}

class NetworkSettingItem extends SettingItem {
  static const String SETTING_NAME = 'NETWORK';

  String getItemTitle() {
    return LocaleKeys.network.tr();
  }

  Widget getItemPanel(BuildContext context) {
    AppConfig appConfig = AppConfig();
    TextEditingController hostEditing =
        TextEditingController(text: appConfig.host());
    TextEditingController portEditing =
        TextEditingController(text: appConfig.port().toString());
    bool hostDirty = false;
    bool portDirty = false;
    return StatefulBuilder(builder: (context, setState) {
      return Material(
          child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                height: 50,
                child: FittedBox(
                    fit: BoxFit.fitHeight,
                    child: Row(children: [
                      Container(
                          width: 200,
                          child: TextFormField(
                            onChanged: (value) {
                              setState(
                                () {
                                  hostDirty = true;
                                },
                              );
                            },
                            controller: hostEditing,
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: LocaleKeys.server_address.tr(),
                              labelStyle: TextStyle(
                                  color:
                                      GetIt.I.get<AppearanceProvider>().color),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        GetIt.I.get<AppearanceProvider>().color,
                                    width: 0.0),
                              ),
                            ),
                          )),
                      HSpace(10),
                      Checkbox(
                          activeColor: GetIt.I.get<AppearanceProvider>().color,
                          value: !hostDirty,
                          onChanged: !hostDirty
                              ? null
                              : (value) {
                                  setState(
                                    () {
                                      appConfig.setHost(hostEditing.text);
                                      hostDirty = false;
                                    },
                                  );
                                }),
                    ]))),
            Container(
                height: 50,
                child: FittedBox(
                    fit: BoxFit.fitHeight,
                    child: Row(
                      children: [
                        Container(
                            width: 50,
                            child: TextFormField(
                              onChanged: (value) {
                                setState(
                                  () {
                                    portDirty = true;
                                  },
                                );
                              },
                              controller: portEditing,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                                RangeNumberInputFormatter()
                              ],
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: LocaleKeys.server_port.tr(),
                                labelStyle: TextStyle(
                                    color: GetIt.I
                                        .get<AppearanceProvider>()
                                        .color),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: GetIt.I
                                          .get<AppearanceProvider>()
                                          .color,
                                      width: 0.0),
                                ),
                              ),
                            )),
                        HSpace(10),
                        Checkbox(
                            activeColor:
                                GetIt.I.get<AppearanceProvider>().color,
                            value: !portDirty,
                            onChanged: !portDirty
                                ? null
                                : (value) {
                                    setState(
                                      () {
                                        appConfig.setPort(
                                            int.parse(portEditing.text));
                                        portDirty = false;
                                      },
                                    );
                                  }),
                      ],
                    ))),
          ],
        ),
      ));
    });
  }
}
