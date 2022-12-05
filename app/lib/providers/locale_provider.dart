import 'package:flutter/material.dart';
import '../style/layout.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = AppLayout.defaultLocale;

  Locale get locale => _locale;
  set locale(Locale value) {
    _locale = value;
    notifyListeners();
  }
}
