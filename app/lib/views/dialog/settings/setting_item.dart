import 'package:flutter/material.dart';

class SettingItem {
  String getItemTitle() {
    return 'SettingItem';
  }

  Widget getItemPanel(BuildContext context) {
    return Container(
      color: Colors.red,
    );
  }
}
