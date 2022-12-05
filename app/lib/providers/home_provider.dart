import 'package:app/pages/folder_manager.dart';
import 'package:flutter/material.dart';
import 'package:app/generated/p01.pb.dart';
import 'package:get_it/get_it.dart';
import 'package:app/server/server_manager.dart';
import 'package:app/utils/log.dart';

enum HomeMode {
  BlankMode,
  PageMode,
  RecycleBinMode,
}

enum HomeEvent {
  None,
  UpdateNickname,
  UpdateUserFolder,
  UpdateRecycleBin,
  UpdateEditorHead,
}

class HomeProvider extends ChangeNotifier {
  bool _menuCollapsed = false;

  set menuCollapsed(bool value) {
    _menuCollapsed = value;
    notifyListeners();
  }

  bool get menuCollapsed => _menuCollapsed;

  HomeMode _homeMode = HomeMode.BlankMode;

  clear() {
    _homeMode = HomeMode.BlankMode;
    _lastSelectedPage = "";
  }

  set homeMode(HomeMode value) {
    _homeMode = value;
    notifyListeners();
  }

  HomeMode get homeMode => _homeMode;

  String _lastSelectedPage = "";

  selectPage(String page) {
    if (page.isEmpty) {
      _lastSelectedPage = page;
      _homeMode = HomeMode.BlankMode;
      notifyListeners();
    } else {
      // 先确保page detail拉回来了
      ServerManager serverManager = GetIt.I.get<ServerManager>();
      serverManager.getUserPage(page).then((value) {
        _lastSelectedPage = page;
        _homeMode = HomeMode.PageMode;
        notifyListeners();
      });
    }
  }

  String get lastSelectPage => _lastSelectedPage;

  List<HomeEvent> _homeEvent = [HomeEvent.None];
  set homeEvent(List<HomeEvent> events) {
    _homeEvent = events;
    notifyListeners();
  }

  List<HomeEvent> get homeEvent => _homeEvent;
}
