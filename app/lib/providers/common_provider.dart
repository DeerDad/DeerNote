import 'package:flutter/material.dart';

class LocalNotifier extends ChangeNotifier {
  void update() {
    notifyListeners();
  }
}
