import 'dart:math';

import 'package:app/generated/p01.pb.dart';
import 'package:app/providers/appearance_provider.dart';
import 'package:app/server/server_manager.dart';
import 'package:app/utils/app_config.dart';
import 'package:app/utils/app_runtime_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import './setting_item.dart';
import '../../common/spacing.dart';
import 'package:app/providers/appearance_provider.dart';
import 'package:app/providers/locale_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:app/utils/log.dart';
import 'package:app/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class NicknameSettingItem extends SettingItem {
  static const String SETTING_NAME = 'NICKNAME';

  String getItemTitle() {
    return LocaleKeys.user_profile.tr();
  }

  Widget getItemPanel(BuildContext context) {
    UserProfile userProfile = GetIt.I.get<AppRuntimeData>().userProfile;
    TextEditingController nicknameEditing =
        TextEditingController(text: userProfile.nickname);
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
                            onFieldSubmitted: (newValue) async {
                              ServerManager sm = GetIt.I.get<ServerManager>();
                              sm.modifyNickname(newValue);
                              Navigator.of(context).pop();
                            },
                            controller: nicknameEditing,
                            decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: LocaleKeys.nickname.tr(),
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
                    ]))),
          ],
        ),
      ));
    });
  }
}
