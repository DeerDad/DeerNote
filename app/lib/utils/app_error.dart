import 'package:app/views/common/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'log.dart';
import '../style/layout.dart';

enum ErrorType {
  FunctionalError,
  InternalError,
}

class AppError extends Cubit<int> {
  late String errorString;
  late ErrorType errorType;

  AppError(
      {required this.errorString, this.errorType = ErrorType.FunctionalError})
      : super(0) {}

  static HandleError(AppError error) {
    GetIt.I.get<AppError>().copyWith(error);
  }

  copyWith(AppError other) {
    errorString = other.errorString;
    errorType = other.errorType;
    emit(state + 1);
  }
}

class AppErrorTip extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AppErrorTipState();
  }
}

class AppErrorTipState extends State<AppErrorTip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double width = 0;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration:
            const Duration(milliseconds: AppLayout.errorPanelMoveMilliseconds));

    _controller.addListener(() {
      setState(() {
        width = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void runAnimation() async {
    _animation = _controller.drive(
      Tween(
        begin: 0,
        end: AppLayout.errorPanelHeight,
      ),
    );
    _controller.reset();
    await _controller.forward();
    await Future.delayed(
        Duration(milliseconds: AppLayout.errorPanelStayMilliseconds));
    await _controller.reverse();
  }

  IconData getIconData() {
    return GetIt.I.get<AppError>().errorType == ErrorType.FunctionalError
        ? Icons.warning
        : Icons.error;
  }

  Color getColor() {
    return GetIt.I.get<AppError>().errorType == ErrorType.FunctionalError
        ? AppLayout.errorPanelWarnColor
        : AppLayout.errorPanelErrorColor;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return BlocProvider.value(
      value: GetIt.I.get<AppError>(),
      child: BlocListener<AppError, int>(
          listener: (context, state) {
            runAnimation();
          },
          child: Transform.translate(
              offset: Offset(0.0, screenHeight - width),
              child: Container(
                height: AppLayout.errorPanelHeight,
                child: Align(
                  alignment: Alignment.center,
                  child: FittedBox(
                    child: Container(
                        child: Row(
                          children: [
                            Icon(
                              getIconData(),
                              color: getColor(),
                            ),
                            HSpace(10),
                            Text(
                              GetIt.I.get<AppError>().errorString,
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  color: getColor()),
                            )
                          ],
                        ),
                        color: Color.fromARGB(62, 255, 255, 255)),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ))),
    );
  }
}
