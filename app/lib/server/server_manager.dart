import 'package:app/generated/p01.pb.dart';
import 'package:app/providers/home_provider.dart';
import 'package:app/utils/app_runtime_data.dart';
import 'package:app/utils/log.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get_it/get_it.dart';

import 'app_server.dart';
import 'remote_server.dart';
import 'local_server.dart';
import 'package:app/pages/folder_manager.dart';

enum ServerType {
  LocalServer,
  RemoteServer,
}

class ServerManager {
  late Map<ServerType, AppServer> _servers;
  ServerManager() {
    _servers = {};
    _servers[ServerType.LocalServer] = LocalServer();
    _servers[ServerType.RemoteServer] = RemoteServer();
  }

  Future<bool> login(String account, String password, bool offline) async {
    AppServer authServer = offline
        ? _servers[ServerType.LocalServer]!
        : _servers[ServerType.RemoteServer]!;

    UserProfile userProfile = await authServer.login(account, password);
    GetIt.I.get<AppRuntimeData>().runMode =
        offline ? ServerRunMode.RunOffline : ServerRunMode.RunOnline;

    GetIt.I.get<AppRuntimeData>().userProfile = userProfile;

    UserFolder userFolder = await authServer.getUserFolder();
    GetIt.I.get<FolderManager>().userFolder = userFolder;

    return true;
  }

  Future<bool> register(
      String account, String password, bool offline, String cdkey) async {
    AppServer authServer = offline
        ? _servers[ServerType.LocalServer]!
        : _servers[ServerType.RemoteServer]!;

    UserProfile userProfile =
        await authServer.register(account, password, cdkey);
    GetIt.I.get<AppRuntimeData>().runMode =
        offline ? ServerRunMode.RunOffline : ServerRunMode.RunOnline;
    GetIt.I.get<AppRuntimeData>().userProfile = userProfile;

    UserFolder userFolder = await authServer.getUserFolder();
    GetIt.I.get<FolderManager>().userFolder = userFolder;

    return true;
  }

  Future<void> logout() async {
    AppServer authServer =
        GetIt.I.get<AppRuntimeData>().runMode == ServerRunMode.RunOffline
            ? _servers[ServerType.LocalServer]!
            : _servers[ServerType.RemoteServer]!;

    await authServer.logout();
  }

  Future<bool> modifyNickname(String nickname) async {
    AppServer authServer =
        GetIt.I.get<AppRuntimeData>().runMode == ServerRunMode.RunOffline
            ? _servers[ServerType.LocalServer]!
            : _servers[ServerType.RemoteServer]!;

    UserProfile userProfile = await authServer.modifyNickname(nickname);
    GetIt.I.get<AppRuntimeData>().userProfile.nickname = userProfile.nickname;
    GetIt.I.get<HomeProvider>().homeEvent = [HomeEvent.UpdateNickname];
    return true;
  }

  Future<bool> updateUserFolder() async {
    AppServer authServer =
        GetIt.I.get<AppRuntimeData>().runMode == ServerRunMode.RunOffline
            ? _servers[ServerType.LocalServer]!
            : _servers[ServerType.RemoteServer]!;

    await authServer.updateUserFolder();

    return true;
  }

  Future<bool> getUserPage(String uuid) async {
    FolderManager folderManager = GetIt.I.get<FolderManager>();
    PageMemoryCache pageMemoryCache = folderManager.findPageMemoryCache(uuid)!;
    if (pageMemoryCache.selfPageDetail != null) {
      Log.debug("page detail exists");
      return true;
    }

    Log.debug("pull page detail start");
    AppServer authServer =
        GetIt.I.get<AppRuntimeData>().runMode == ServerRunMode.RunOffline
            ? _servers[ServerType.LocalServer]!
            : _servers[ServerType.RemoteServer]!;

    PageDetail pageDetail = await authServer.getUserPage(uuid);
    Log.debug("pull page detail finish");

    folderManager.storePageDetail(uuid, pageDetail);

    return true;
  }

  Future<bool> updateUserPages(List<String> pages) async {
    AppServer authServer =
        GetIt.I.get<AppRuntimeData>().runMode == ServerRunMode.RunOffline
            ? _servers[ServerType.LocalServer]!
            : _servers[ServerType.RemoteServer]!;

    await authServer.updateUserPages(pages);

    return true;
  }

  Future<bool> deleteUserPages(List<String> pages) async {
    AppServer authServer =
        GetIt.I.get<AppRuntimeData>().runMode == ServerRunMode.RunOffline
            ? _servers[ServerType.LocalServer]!
            : _servers[ServerType.RemoteServer]!;

    await authServer.deleteUserPages(pages);

    return true;
  }
}
