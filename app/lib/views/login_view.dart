import 'dart:math';
import 'package:app/providers/appearance_provider.dart';
import 'package:flutter/material.dart';
import 'package:app/views/home_view.dart';
import 'package:flutter/rendering.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import '../server/server_manager.dart';
import '../utils/log.dart';
import 'login/login_core.dart';
import '../style/layout.dart';
import './dialog/flex_setting_dialog.dart';
import 'basic_widget_wrapper.dart';
import 'package:app/routes/app_route.dart';
import 'package:app/utils/app_runtime_data.dart';
import 'package:app/views/common/app_button.dart';
import 'package:app/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginView extends StatelessWidget {
  static const LOGIN_ROUTE_NAME = '/login_view';
  static const REGISTER_ROUTE_NAME = '/register_view';
  late final Widget child;

  LoginView(this.child);

  @override
  Widget build(BuildContext context) {
    return BasicWidgetWrapper(builder: (context) {
      return LayoutBuilder(builder: ((context, constraints) {
        return buildDesktopBody(context, constraints);
      }));
    });
  }

  Widget buildMobileBody(BuildContext context, BoxConstraints constraints) {
    return Center(
      child: Text('Not Implemented'),
    );
  }

  Widget buildDesktopBody(BuildContext context, BoxConstraints constraints) {
    return DesktopLoginView(
      child: child,
      constraints: constraints,
      stacks: [buildSettingButton(context)],
    );
  }

  Widget buildSettingButton(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: AppButton(
        onTap: () {
          showDialog(
              context: context,
              builder: (context) {
                return FlexSettingDialog(AppLayout.loginSettingItems);
              });
        },
        icon: Icons.settings,
        tip: LocaleKeys.user_setting.tr(),
      ),
    );
  }
}

class DesktopLoginView extends StatefulWidget {
  late final Widget child;
  late final BoxConstraints constraints;
  late final List<Widget> stacks;
  DesktopLoginView(
      {required this.child, required this.constraints, this.stacks = const []});

  @override
  State<DesktopLoginView> createState() {
    return DesktopLoginViewState();
  }
}

class DesktopLoginViewState extends State<DesktopLoginView> with RouteAware {
  @override
  Widget build(BuildContext context) {
    double bodyWidth = widget.constraints.maxHeight;
    return Material(
        type: MaterialType.transparency,
        child: Container(
            color: Colors.white,
            child: Stack(
              children: [
                Center(
                  child: Container(
                    color: Colors.white,
                    width: bodyWidth,
                    child: widget.child,
                  ),
                ),
              ]..addAll(widget.stacks),
            )));
  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(
        this, ModalRoute.of(context) as Route<dynamic>); //订阅
    super.didChangeDependencies();
  }

  @override
  void didPush() {}

  @override
  void dispose() {
    routeObserver.unsubscribe(this); //取消订阅
    super.dispose();
  }
}
