import 'package:app/views/login/login_core.dart';
import 'package:flutter/material.dart';
import 'package:app/views/home_view.dart';
import 'package:app/views/login_view.dart';
import 'package:app/utils/log.dart';

final RouteObserver<Route<dynamic>> routeObserver = RouteObserver();

class AppRoute extends NavigatorObserver {
  AppRoute._internal();
  static final AppRoute _appRoute = AppRoute._internal();
  factory AppRoute() => _appRoute;

  /// 静态路由（无参数）
  static final Map<String, WidgetBuilder> _routes = {
    LoginView.LOGIN_ROUTE_NAME: (_) =>
        LoginView(LoginCore(LoginViewMode.LoginMode)),
    LoginView.REGISTER_ROUTE_NAME: (_) =>
        LoginView(LoginCore(LoginViewMode.RegisterMode)),
    HomeView.ROUTE_NAME: (_) => HomeView(),
  };

  Map<String, WidgetBuilder> get routes => _routes;
}

AppRoute appRoute = AppRoute();
