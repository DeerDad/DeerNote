import 'package:app/generated/locale_keys.g.dart';
import 'package:app/views/common/spacing.dart';
import 'package:flutter/material.dart';
import './setting_item.dart';
import '../../../generated/codegen_loader.g.dart';
import '../../../utils/app_config.dart';
import 'package:app/providers/appearance_provider.dart';
import 'package:app/providers/locale_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSelection extends StatefulWidget {
  const LanguageSelection({
    Key? key,
  }) : super(key: key);

  @override
  State<LanguageSelection> createState() => LanguageSelectionState();
}

class LanguageSelectionState extends State<LanguageSelection> {
  Color currHoverColor = Colors.white.withOpacity(0.0);
  void hoverExitLanguage() {
    setState(() {
      currHoverColor = Colors.white.withOpacity(0.0);
    });
  }

  void hoverEnterLanguage() {
    setState(() {
      currHoverColor = Colors.white.withOpacity(0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    AppConfig appConfig = AppConfig();
    List<Locale> testLocales =
        CodegenLoader.mapLocales.keys.map((e) => Locale(e)).toList();
    return Container(
      child: DropdownButton<Locale>(
        value: appConfig.getLocale(),
        onChanged: (val) async {
          await context.setLocale(val!);
          setState(() {
            appConfig.setLocale(val);
          });
        },
        items: testLocales.map((locale) {
          return DropdownMenuItem<Locale>(
            value: locale,
            child: Text(
              locale.toLanguageTag(),
              style: TextStyle(color: GetIt.I.get<AppearanceProvider>().color),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class LocaleSettingItem extends SettingItem {
  static const String SETTING_NAME = 'LOCALE';

  String getItemTitle() {
    return LocaleKeys.locale.tr();
  }

  Widget getItemPanel(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              height: 50,
              child: FittedBox(
                  fit: BoxFit.fitHeight,
                  child: Row(
                    children: [
                      Text(
                        LocaleKeys.language.tr(),
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            color: GetIt.I.get<AppearanceProvider>().color),
                      ),
                      HSpace(10),
                      const Material(child: LanguageSelection()),
                    ],
                  ))),
        ],
      ),
    );
  }
}
