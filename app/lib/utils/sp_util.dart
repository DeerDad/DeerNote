import 'dart:convert';
import 'shared_preferences.dart';

class SpUtil {
  static String foldersKeyPostfix = '_folders'; // eg. bill_folders
  static String noteKeyPrefix = 'note_'; // eg. note_xxx.xxx
  static String userLocalConfigKey = 'user_local_config';

  static String usersTableKey = 'users_table_';

  static void saveFolders(String folders) async {
    await appSP.setString(foldersKeyPostfix, folders);
  }

  static String? getFolders() {
    return appSP.getString(foldersKeyPostfix);
  }

  static Future<bool> saveUserTable(String name, String value) {
    return appSP.setString('${usersTableKey}${name}', value);
  }

  static String? getUserTable(String value) {
    return appSP.getString('${usersTableKey}${value}');
  }

  static String? getUserLocalConfig() {
    return appSP.getString(userLocalConfigKey);
  }

  static Future<bool> saveUserLocalConfig(String value) {
    return appSP.setString(userLocalConfigKey, value);
  }
}
