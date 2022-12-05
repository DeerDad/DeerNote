import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:app/views/dialog/settings/nickname_setting.dart';
import 'package:app/views/dialog/settings/locale_setting.dart';
import 'package:app/views/dialog/settings/network_setting.dart';
import 'package:app/views/dialog/settings/appearance_setting.dart';
import 'dart:io' show Platform;
import 'package:time/time.dart';

class AppLayout {
  // login panels
  static int loginTitleFlex = 3;
  static int loginPanelFlex = 7;

  // error panel
  static double errorPanelHeight = 40;
  static const int errorPanelMoveMilliseconds = 500;
  static const int errorPanelStayMilliseconds = 500;
  static const Color errorPanelErrorColor = Color.fromARGB(228, 230, 8, 23);
  static const Color errorPanelWarnColor = Color.fromARGB(223, 246, 206, 8);

  // login setting items
  static const List<String> loginSettingItems = [
    LocaleSettingItem.SETTING_NAME,
    AppearanceSettingItem.SETTING_NAME,
    NetworkSettingItem.SETTING_NAME,
  ];

  static bool isDesktop() {
    return Platform.isLinux || Platform.isMacOS || Platform.isWindows;
  }

  static bool isMobile() {
    return Platform.isAndroid || Platform.isIOS;
  }

  static bool isWeb() {
    return kIsWeb;
  }

  static double settingDialogWidth = loginViewWidth * 0.6;
  static double settingDialogHeight = loginViewHeight * 0.6;
  static double settingDialogTitleHeight = 40;
  static double settingDialogDividerHeight = 1;

  // login panels
  static int settingLeftFlex = 2;
  static int settingRightFlex = 8;

  static const Color defaultColor = Colors.blue;
  static const Locale defaultLocale = Locale('zh');

  // windows size
  static const double loginViewWidth = 640;
  static const double loginViewHeight = 480;

  static const double homeViewWidth = 1280;
  static const double homeViewHeight = 960;

  // home
  static const double menuWidth = 200;
  static Duration animDuration = 0.35.seconds;
  static double dynamicMenuWidth = 0;
  static const double dynamicMenuWidthDelta = 100;
  static const Color menuBackgroundColor = Color.fromARGB(32, 0, 0, 0);

  static const double homeMenuDividerHeight = 16;

  static const double catalogItemGridSize = 20;
  static const List<String> homeSettingItems = [
    LocaleSettingItem.SETTING_NAME,
    AppearanceSettingItem.SETTING_NAME,
  ];

  static const List<String> profileSettingItems = [
    NicknameSettingItem.SETTING_NAME
  ];

  // popup menus
  static const double popupMenuItemHeight = 30;
  static const double popupMenuItemWidth = 100;

  static const double draggableHeight = 30;
  static const double draggableSeparatorHeight = 3;

  // recycle
  static const double recyclePageWidth = 600;
  static const double recyclePageHeadSpace = 100;
  static const double recyclePageListHeight = 500;
}
