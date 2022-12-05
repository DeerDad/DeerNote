import 'dart:async';

import 'package:app/generated/codegen_loader.g.dart';
import 'package:app/providers/home_provider.dart';
import 'package:app/routes/app_route.dart';
import 'package:app/server/server_manager.dart';
import 'package:app/style/layout.dart';
import 'package:app/utils/app_config.dart';
import 'package:app/views/login/login_core.dart';
import 'package:app/views/login_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:provider/provider.dart';

import 'generated/codegen_loader.g.dart';
import 'utils/app_error.dart';
import 'utils/app_runtime_data.dart';
import 'utils/log.dart';
import 'utils/shared_preferences.dart';
import 'views/overlay/base/app_overlay.dart';
import 'providers/appearance_provider.dart';
import 'providers/locale_provider.dart';
import 'package:app/pages/folder_manager.dart';

void main() {
  runZonedGuarded(() async {
    InitAPP().then((value) {
      runApp(providerWrapper(localizationWrapper(MyApp())));
    });
  }, (err, stack) {
    if (err is AppError) {
      // 业务错误
      AppError.HandleError(err);
      Log.warn(err.errorString);
    } else {
      // 内部错误
      AppError appError = AppError(
          errorString: err.toString().trim(),
          errorType: ErrorType.InternalError);
      AppError.HandleError(appError);
      Log.error(err);
      Log.error(stack);
    }
  });
}

Future<void> InitAPP() {
  WidgetsFlutterBinding.ensureInitialized();
  GetIt.I.registerSingleton<AppRuntimeData>(AppRuntimeData());
  GetIt.I.registerSingleton<AppError>(AppError(errorString: ''));
  GetIt.I.registerSingleton<AppearanceProvider>(AppearanceProvider());
  GetIt.I.registerSingleton<LocaleProvider>(LocaleProvider());
  GetIt.I.registerSingleton<HomeProvider>(HomeProvider());
  GetIt.I.registerSingleton<FolderManager>(FolderManager());
  GetIt.I.registerSingleton<ServerManager>(ServerManager());

  return EasyLocalization.ensureInitialized().then((value) {
    Log.debug("EasyLocalization.ensureInitialized");
    return appSP.init();
  }).then((value) {
    Log.debug("EappSP.init");

    Timer.periodic(Duration(seconds: 1), (timer) {
      _1SecTick();
    });

    Timer.periodic(Duration(seconds: 3), (timer) {
      _3SecsTick();
    });

    Timer.periodic(Duration(seconds: 10), (timer) {
      _10SecsTick();
    });

    return AppConfig().initConfig();
  });
}

void _3SecsTick() {}

void _1SecTick() {
  GetIt.I.get<FolderManager>().tick();
}

void _10SecsTick() {}

Widget providerWrapper(Widget child) {
  return MultiProvider(providers: [
    ChangeNotifierProvider.value(value: GetIt.I.get<AppearanceProvider>()),
    ChangeNotifierProvider.value(value: GetIt.I.get<LocaleProvider>()),
  ], child: child);
}

Widget localizationWrapper(Widget child) {
  return EasyLocalization(
      startLocale: AppConfig().getLocale(),
      supportedLocales: [Locale('en'), Locale('zh')],
      path:
          'assets/translations', // <-- change the path of the translation files
      fallbackLocale: Locale('en'),
      saveLocale: false,
      assetLoader: CodegenLoader(),
      child: child);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return AppOverlay(child: child!);
      },
      title: 'DeerNote',
      routes: appRoute.routes,
      home: LoginView(LoginCore(LoginViewMode.LoginMode)),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: AppConfig().getLocale(),
      navigatorObservers: [routeObserver],
    );
  }
}
