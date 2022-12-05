import 'dart:convert';

import 'package:app/views/login/login_core.dart';
import 'package:flutter/material.dart';
import 'app_server.dart';
import 'package:app/generated/p01.pb.dart';

class LocalServer extends AppServer {
  @override
  Future<UserProfile> login(String account, String password) {
    return Future(() => UserProfile());
  }

  @override
  Future<UserProfile> register(String account, String password, String cdkey) {
    return Future(() => UserProfile());
  }

  @override
  Future<EmptyMessage> logout() {
    return Future(() => EmptyMessage());
  }

  @override
  Future<UserProfile> modifyNickname(String nickname) {
    return Future(() => UserProfile());
  }

  @override
  Future<UserFolder> getUserFolder() {
    return Future(() => UserFolder());
  }

  @override
  Future<EmptyMessage> updateUserFolder() {
    return Future(() => EmptyMessage());
  }

  @override
  Future<PageDetail> getUserPage(String uuid) {
    return Future(() => PageDetail());
  }

  @override
  Future<EmptyMessage> updateUserPages(List<String> pages) {
    return Future(() => EmptyMessage());
  }

  @override
  Future<EmptyMessage> deleteUserPages(List<String> pages) {
    return Future(() => EmptyMessage());
  }
}
