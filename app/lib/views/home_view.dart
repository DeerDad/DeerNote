import 'dart:io';
import 'package:app/pages/folder_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/views/home/home_core.dart';
import '../utils/log.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flutter/src/gestures/recognizer.dart';
import '../providers/home_provider.dart';
import 'package:app/views/basic_widget_wrapper.dart';
import 'package:app/style/layout.dart';
import 'package:app/routes/app_route.dart';
import 'package:app/utils/app_runtime_data.dart';
import 'package:get_it/get_it.dart';

class HomeView extends StatefulWidget {
  static const ROUTE_NAME = '/home_view';

  @override
  HomeViewState createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: GetIt.I.get<HomeProvider>())
      ],
      child: BasicWidgetWrapper(
        builder: (context) {
          return buildDesktopBody(context);
        },
      ),
    );
  }

  Widget buildDesktopBody(BuildContext context) {
    return DesktopHomeView();
  }

  Widget buildMobileBody(BuildContext context) {
    return Center(
      child: Text('Not Implemented'),
    );
  }
}

class DesktopHomeView extends StatefulWidget {
  @override
  State<DesktopHomeView> createState() {
    return DesktopHomeViewState();
  }
}

class DesktopHomeViewState extends State<DesktopHomeView> with RouteAware {
  @override
  Widget build(BuildContext context) {
    return BasicWidgetWrapper(
      builder: (context) {
        return HomeCore();
      },
    );
  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(
        this, ModalRoute.of(context) as Route<dynamic>); //订阅
    super.didChangeDependencies();
  }

  @override
  void didPush() {
    GetIt.I.get<HomeProvider>().clear();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this); //取消订阅
    super.dispose();
  }
}
