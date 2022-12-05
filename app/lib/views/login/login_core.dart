import 'dart:developer';

import 'package:app/utils/app_config.dart';
import 'package:app/views/common/app_button.dart';
import 'package:app/views/common/spacing.dart';
import 'package:app/views/login_view.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../server/server_manager.dart';
import '../home_view.dart';
import '../../utils/log.dart';
import '../../style/layout.dart';
import 'package:app/providers/appearance_provider.dart';
import 'package:app/providers/locale_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:app/views/basic_widget_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app/generated/locale_keys.g.dart';
import 'package:grpc/grpc.dart';
import 'package:app/generated/p01.pb.dart';

enum LoginViewMode {
  LoginMode,
  RegisterMode,
}

class LoginCore extends StatefulWidget {
  late final LoginViewMode mode;
  LoginCore(this.mode);

  @override
  State<StatefulWidget> createState() {
    return LoginCoreState();
  }
}

class LoginCoreState extends State<LoginCore> {
  GlobalKey<FormState> _formKey = GlobalKey();
  late FocusNode _passwordFocusNode, _submitFocusNode;
  late TextEditingController _userNameController,
      _passwordController,
      _cdkeyController;
  bool _isShowPassword = false;
  bool _isLoading = false;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();

    _passwordFocusNode = FocusNode();
    _submitFocusNode = FocusNode();
    _userNameController = TextEditingController();
    _passwordController = TextEditingController();
    _cdkeyController = TextEditingController();
  }

  void _showPassword() {
    setState(() {
      _isShowPassword = !_isShowPassword;
    });
  }

  void _doSubmit() {
    _formKey.currentState?.save();
    setState(() {
      _isLoading = true;
    });

    ServerManager sm = GetIt.I.get<ServerManager>();

    if (widget.mode == LoginViewMode.LoginMode) {
      sm
          .login(_userNameController.text, _passwordController.text, _isOffline)
          .then((value) {
        if (value) {
          Navigator.of(context).pushReplacementNamed(HomeView.ROUTE_NAME);
        }
      }).whenComplete(() {
        setState(() {
          _isLoading = false;
        });
      });
    } else {
      sm
          .register(_userNameController.text, _passwordController.text,
              _isOffline, _cdkeyController.text)
          .then((value) {
        if (value) {
          Navigator.of(context).pushReplacementNamed(HomeView.ROUTE_NAME);
        }
      }).whenComplete(() {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  Widget _buildSubmitLoading() {
    return CircularProgressIndicator(
      color: GetIt.I.get<AppearanceProvider>().color,
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      focusNode: _submitFocusNode,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
            GetIt.I.get<AppearanceProvider>().color),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
        child: widget.mode == LoginViewMode.LoginMode
            ? Text(LocaleKeys.login.tr())
            : Text(LocaleKeys.register.tr()),
      ),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _doSubmit();
        }
      },
    );
  }

  Widget buildbody(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: AppLayout.loginTitleFlex,
          child: buildTitle(context),
        ),
        Expanded(
          flex: AppLayout.loginPanelFlex,
          child: buildMainPanel(context),
        ),
      ],
    );
  }

  Widget buildTitle(BuildContext context) {
    return Container();
  }

  Widget buildMainPanel(BuildContext context) {
    return Column(
      children: <Widget>[
        Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Material(
                child: TextFormField(
                  cursorColor: GetIt.I.get<AppearanceProvider>().color,
                  autofocus: true,
                  controller: _userNameController,
                  onEditingComplete: () =>
                      FocusScope.of(context).requestFocus(_passwordFocusNode),
                  validator: (value) {
                    return value!.isEmpty ? 'thisFieldCanNotBeEmpty' : null;
                  },
                  decoration: InputDecoration(
                    label: Text(
                      LocaleKeys.user_name.tr(),
                      style: TextStyle(
                          color: GetIt.I.get<AppearanceProvider>().color),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: GetIt.I.get<AppearanceProvider>().color,
                          width: 0.0),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              VSpace(10),
              Material(
                child: TextFormField(
                  cursorColor: GetIt.I.get<AppearanceProvider>().color,
                  focusNode: _passwordFocusNode,
                  controller: _passwordController,
                  onEditingComplete: () =>
                      FocusScope.of(context).requestFocus(_submitFocusNode),
                  validator: (value) {
                    return value!.isEmpty ? 'thisFieldCanNotBeEmpty' : null;
                  },
                  obscureText: !_isShowPassword,
                  decoration: InputDecoration(
                    suffixIcon: AppButton(
                        icon: _isShowPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        tip: _isShowPassword
                            ? LocaleKeys.hide_password.tr()
                            : LocaleKeys.show_password.tr(),
                        onTap: () => _showPassword()),
                    label: Text(
                      LocaleKeys.user_password.tr(),
                      style: TextStyle(
                          color: GetIt.I.get<AppearanceProvider>().color),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: GetIt.I.get<AppearanceProvider>().color,
                          width: 0.0),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        VSpace(10),
        widget.mode == LoginViewMode.LoginMode
            ? Container()
            : Material(
                child: TextFormField(
                  cursorColor: GetIt.I.get<AppearanceProvider>().color,
                  autofocus: true,
                  controller: _cdkeyController,
                  onEditingComplete: () =>
                      FocusScope.of(context).requestFocus(_passwordFocusNode),
                  decoration: InputDecoration(
                    label: Text(
                      LocaleKeys.cdkey.tr(),
                      style: TextStyle(
                          color: GetIt.I.get<AppearanceProvider>().color),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: GetIt.I.get<AppearanceProvider>().color,
                          width: 0.0),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
        VSpace(10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(
              child: child,
              scale: animation,
            );
          },
          child: _isLoading ? _buildSubmitLoading() : _buildSubmitButton(),
        ),
        VSpace(10),
        getSwitchModeButton(context),
      ],
    );
  }

  TextButton getSwitchModeButton(BuildContext context) {
    if (widget.mode == LoginViewMode.LoginMode) {
      return TextButton(
        onPressed: () => Navigator.of(context)
            .pushReplacementNamed(LoginView.REGISTER_ROUTE_NAME),
        child: RichText(
          text: TextSpan(
            text: LocaleKeys.Im_a_new_user.tr(),
            style: TextStyle(color: Colors.black),
            children: [
              TextSpan(
                text: LocaleKeys.register.tr(),
                style: TextStyle(
                  color: GetIt.I.get<AppearanceProvider>().color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return TextButton(
        onPressed: () => Navigator.of(context)
            .pushReplacementNamed(LoginView.LOGIN_ROUTE_NAME),
        child: RichText(
          text: TextSpan(
            text: LocaleKeys.Im_already_a_member.tr(),
            style: TextStyle(color: Colors.black),
            children: [
              TextSpan(
                text: LocaleKeys.login.tr(),
                style: TextStyle(
                  color: GetIt.I.get<AppearanceProvider>().color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasicWidgetWrapper(
      builder: (context) {
        return buildbody(context);
      },
    );
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _submitFocusNode.dispose();
    _userNameController.dispose();
    _passwordController.dispose();
    _cdkeyController.dispose();
    super.dispose();
  }
}
