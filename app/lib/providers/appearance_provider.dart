import 'package:flutter/material.dart';
import '../style/layout.dart';
import 'package:app/utils/log.dart';

class AppearanceProvider extends ChangeNotifier {
  Color _color = AppLayout.defaultColor;

  Color get color => _color;
  set color(Color value) {
    _color = value;
    notifyListeners();
  }
}
