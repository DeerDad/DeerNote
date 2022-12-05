import 'package:flutter/material.dart';
import 'package:app/providers/appearance_provider.dart';
import 'package:get_it/get_it.dart';

class AppButton extends StatelessWidget {
  late final IconData icon;
  late final String tip;
  final VoidCallback? onTap;
  Color? overrideColor = null;

  AppButton(
      {required this.icon, required this.tip, this.onTap, this.overrideColor});

  Widget build(BuildContext context) {
    return Tooltip(
      child: InkWell(
        child: Icon(
          icon,
          color: overrideColor ?? GetIt.I.get<AppearanceProvider>().color,
        ),
        onTap: onTap,
      ),
      message: tip,
    );
  }
}
