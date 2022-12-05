import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';

import 'package:app/style/layout.dart';
import 'package:app/utils/log.dart';

import 'package:app/utils/app_config.dart';
import 'package:app/generated/p01.pb.dart';

enum ServerRunMode {
  RunOffline,
  RunOnline;
}

class AppRuntimeData {
  UserProfile _userProfile = UserProfile();
  set userProfile(UserProfile value) {
    _userProfile = value;
  }

  UserProfile get userProfile => _userProfile;

  late ServerRunMode _runMode;
  set runMode(ServerRunMode value) {
    _runMode = value;
  }

  ServerRunMode get runMode => _runMode;
}
