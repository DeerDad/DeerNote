import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/appearance_provider.dart';
import '../providers/locale_provider.dart';
import '../utils/log.dart';

class BasicWidgetWrapper extends StatelessWidget {
  late Widget Function(BuildContext context) builder;
  BasicWidgetWrapper({required this.builder});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppearanceProvider>(
      builder: (context, value, child) {
        return Consumer<LocaleProvider>(
          builder: (context, value, child) {
            return builder(context);
          },
        );
      },
    );
  }
}
