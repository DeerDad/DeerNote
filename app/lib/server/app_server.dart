import 'package:app/generated/p01.pb.dart';
import 'package:app/generated/p01.pb.dart';

abstract class AppServer {
  Future<UserProfile> login(String account, String password);
  Future<UserProfile> register(String account, String password, String cdkey);
  Future<EmptyMessage> logout();
  Future<UserProfile> modifyNickname(String nickname);
  Future<UserFolder> getUserFolder();
  Future<EmptyMessage> updateUserFolder();
  Future<PageDetail> getUserPage(String uuid);
  Future<EmptyMessage> updateUserPages(List<String> pages);
  Future<EmptyMessage> deleteUserPages(List<String> pages);
}
