import 'dart:convert';

import 'package:app/pages/folder_manager.dart';
import 'package:app/utils/app_runtime_data.dart';
import 'package:app/views/login/login_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:protobuf/protobuf.dart';
import 'app_server.dart';
import 'package:app/utils/app_config.dart';
import 'package:app/generated/p01.pb.dart';
import 'package:http/http.dart' as http;
import 'http_client_io.dart' if (dart.library.js) 'http_client_web.dart';

import 'package:app/utils/app_error.dart';
import 'package:app/utils/log.dart';

class RemoteServer extends AppServer {
  Map<String, String> headers = {};
  Map<String, String> cookies = {};
  late http.Client _client;
  RemoteServer() {
    _client = HttpClient.createHttpClient();
  }

  void _setCookie(String rawCookie) {
    if (rawCookie.length > 0) {
      int index = rawCookie.indexOf("=");
      if (index <= 0) return;
      List<String> keyValue = [
        rawCookie.substring(0, index),
        rawCookie.substring(index + 1)
      ];
      if (keyValue.length == 2) {
        var key = keyValue[0].trim();
        var value = keyValue[1];

        // ignore keys that aren't cookies
        if (key == 'path' || key == 'expires') return;

        this.cookies[key] = value;
      }
    }
  }

  String _generateCookieHeader() {
    String cookie = "";

    for (var key in cookies.keys) {
      if (cookie.length > 0) cookie += ";";
      cookie += key + "=" + cookies[key]!;
    }

    return cookie;
  }

  void updateCookie(http.Response response) {
    if (response.headers.containsKey('set-cookie') == false) return;
    String allSetCookie = response.headers['set-cookie']!;
    if (allSetCookie != null) {
      var setCookies = allSetCookie.split(',');

      for (var setCookie in setCookies) {
        var cookies = setCookie.split(';');

        for (var cookie in cookies) {
          _setCookie(cookie);
        }
      }

      headers['cookie'] = _generateCookieHeader();
    }
  }

  @override
  Future<UserProfile> login(String account, String password) {
    AppConfig appConfig = AppConfig();

    var url = Uri.http(appConfig.serverAddress(), 'login');
    LoginRequest loginRequest =
        LoginRequest(account: account, password: password);

    return _client.post(url, body: {
      'message': jsonEncode(loginRequest.toProto3Json())
    }).then((response) {
      updateCookie(response);
      if (response.statusCode != 200) {
        throw AppError(errorString: response.body);
      } else {
        UserProfile userProfile = UserProfile();
        userProfile.mergeFromProto3Json(jsonDecode(response.body));
        return userProfile;
      }
    });
  }

  @override
  Future<UserProfile> register(String account, String password, String cdkey) {
    AppConfig appConfig = AppConfig();

    var url = Uri.http(appConfig.serverAddress(), 'register');
    RegisterRequest registerRequest =
        RegisterRequest(account: account, password: password, cdkey: cdkey);

    return _client.post(url, body: {
      'message': jsonEncode(registerRequest.toProto3Json())
    }).then((response) {
      updateCookie(response);
      if (response.statusCode != 200) {
        throw AppError(errorString: response.body);
      } else {
        UserProfile userProfile = UserProfile();
        userProfile.mergeFromProto3Json(jsonDecode(response.body));
        return userProfile;
      }
    });
  }

  @override
  Future<EmptyMessage> logout() {
    AppConfig appConfig = AppConfig();

    var url = Uri.http(appConfig.serverAddress(), 'logout');
    LogoutRequest logoutRequest = LogoutRequest(
        account: GetIt.I.get<AppRuntimeData>().userProfile.account);

    return _client
        .post(url,
            body: {
              'message': jsonEncode(
                logoutRequest.toProto3Json(),
              )
            },
            headers: headers)
        .then((response) {
      updateCookie(response);
      if (response.statusCode != 200) {
        throw AppError(errorString: response.body);
      } else {
        EmptyMessage emptyMessage = EmptyMessage();
        emptyMessage.mergeFromProto3Json(jsonDecode(response.body));
        return emptyMessage;
      }
    });
  }

  @override
  Future<UserProfile> modifyNickname(String nickname) {
    AppConfig appConfig = AppConfig();
    var url = Uri.http(appConfig.serverAddress(), 'modifyUserNickname');

    ModifyNicknameRequest modifyNicknameRequest = ModifyNicknameRequest(
        account: GetIt.I.get<AppRuntimeData>().userProfile.account,
        nickname: nickname);

    return _client
        .post(url,
            body: {'message': jsonEncode(modifyNicknameRequest.toProto3Json())},
            headers: headers)
        .then((response) {
      updateCookie(response);
      if (response.statusCode != 200) {
        throw AppError(errorString: response.body);
      } else {
        UserProfile userProfile = UserProfile();
        userProfile.mergeFromProto3Json(jsonDecode(response.body));
        return userProfile;
      }
    });
  }

  @override
  Future<EmptyMessage> updateUserFolder() {
    AppConfig appConfig = AppConfig();
    var url = Uri.http(appConfig.serverAddress(), 'updateUserFolder');

    UpdateUserFolderRequest updateUserFolderRequest = UpdateUserFolderRequest(
        userFolder: GetIt.I.get<FolderManager>().userFolder);

    return _client
        .post(url,
            body: {
              'message': jsonEncode(updateUserFolderRequest.toProto3Json())
            },
            headers: headers)
        .then((response) {
      updateCookie(response);
      if (response.statusCode != 200) {
        throw AppError(errorString: response.body);
      } else {
        EmptyMessage emptyMessage = EmptyMessage();
        emptyMessage.mergeFromProto3Json(jsonDecode(response.body));
        return emptyMessage;
      }
    });
  }

  @override
  Future<UserFolder> getUserFolder() {
    AppConfig appConfig = AppConfig();
    var url = Uri.http(appConfig.serverAddress(), 'getUserFolder');

    GetUserFolderRequest getUserFolderRequest = GetUserFolderRequest(
        account: GetIt.I.get<AppRuntimeData>().userProfile.account);

    return _client
        .post(url,
            body: {'message': jsonEncode(getUserFolderRequest.toProto3Json())},
            headers: headers)
        .then((response) {
      updateCookie(response);
      if (response.statusCode != 200) {
        throw AppError(errorString: response.body);
      } else {
        UserFolder userFolder = UserFolder();
        userFolder.mergeFromProto3Json(jsonDecode(response.body));
        return userFolder;
      }
    });
  }

  @override
  Future<PageDetail> getUserPage(String uuid) {
    AppConfig appConfig = AppConfig();
    var url = Uri.http(appConfig.serverAddress(), 'getUserPage');

    GetUserPageRequest getUserPageRequest = GetUserPageRequest(
        account: GetIt.I.get<AppRuntimeData>().userProfile.account, uuid: uuid);

    return _client
        .post(url,
            body: {'message': jsonEncode(getUserPageRequest.toProto3Json())},
            headers: headers)
        .then((response) {
      updateCookie(response);
      if (response.statusCode != 200) {
        throw AppError(errorString: response.body);
      } else {
        PageDetail pageDetail = PageDetail();
        pageDetail.mergeFromProto3Json(jsonDecode(response.body));
        return pageDetail;
      }
    });
  }

  @override
  Future<EmptyMessage> updateUserPages(List<String> pages) {
    AppConfig appConfig = AppConfig();
    var url = Uri.http(appConfig.serverAddress(), 'updateUserPages');

    FolderManager folderManager = GetIt.I.get<FolderManager>();
    List<PageDetail> pageDetails = pages
        .map((e) => folderManager.findPageMemoryCache(e)!.selfPageDetail!)
        .toList();

    UpdatePageRequest updatePageRequest = UpdatePageRequest(
        account: GetIt.I.get<AppRuntimeData>().userProfile.account,
        pageDetails: pageDetails);

    return _client
        .post(url,
            body: {'message': jsonEncode(updatePageRequest.toProto3Json())},
            headers: headers)
        .then((response) {
      updateCookie(response);
      if (response.statusCode != 200) {
        throw AppError(errorString: response.body);
      } else {
        EmptyMessage emptyMessage = EmptyMessage();
        emptyMessage.mergeFromProto3Json(jsonDecode(response.body));
        return emptyMessage;
      }
    });
  }

  @override
  Future<EmptyMessage> deleteUserPages(List<String> pages) {
    AppConfig appConfig = AppConfig();
    var url = Uri.http(appConfig.serverAddress(), 'deleteUserPages');

    DeletePageRequest deletePageRequest = DeletePageRequest(
        account: GetIt.I.get<AppRuntimeData>().userProfile.account,
        pages: pages);

    return _client
        .post(url,
            body: {'message': jsonEncode(deletePageRequest.toProto3Json())},
            headers: headers)
        .then((response) {
      updateCookie(response);
      if (response.statusCode != 200) {
        throw AppError(errorString: response.body);
      } else {
        EmptyMessage emptyMessage = EmptyMessage();
        emptyMessage.mergeFromProto3Json(jsonDecode(response.body));
        return emptyMessage;
      }
    });
  }
}
