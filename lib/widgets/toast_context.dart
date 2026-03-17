import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import "package:caesar_zipher/main.dart";

late FToast _fToast;

class ToastContext extends StatefulWidget {
  const ToastContext({super.key, required this.child});
  final Widget child;

  @override
  State<ToastContext> createState() => _ToastContextState();

  static void success(String text) {
    _fToast.removeCustomToast();
    _fToast.showToast(
      child: _ToastContainer(
        backgroundColor: Colors.greenAccent,
        icon: Icon(Icons.check),
        text: text,
      ),
    );
  }

  static void error(String text) {
    _fToast.removeCustomToast();
    _fToast.showToast(
      child: _ToastContainer(
        backgroundColor: const Color.fromARGB(255, 251, 134, 134),
        icon: Icon(Icons.error_outline),
        text: text,
      ),
    );
  }

  static void promise(
    Future promise,
    String pending, {
    String? success,
    String? error,
  }) {
    _fToast.removeCustomToast();

    _fToast.showToast(
      child: _ToastContainer(
        backgroundColor: const Color.fromARGB(255, 180, 228, 253),
        icon: Icon(Icons.pending_outlined),
        text: pending,
      ),
      toastDuration: Duration(seconds: 60),
    );

    String finalState = "pending";
    promise
        .then((val) { finalState = "success"; })
        .onError((err, trace) { finalState = "error"; })
        .whenComplete(() {
          _fToast.removeCustomToast();
          if (finalState == "success" && success != null) {
            ToastContext.success(success);
          } else if (finalState == "error" && error != null) {
            ToastContext.error(error);
          }
        });
  }
}

class _ToastContextState extends State<ToastContext> {
  @override
  void initState() {
    super.initState();
    _fToast = FToast();
    _fToast.init(navigatorKey.currentContext!);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _ToastContainer extends StatelessWidget {
  const _ToastContainer({
    required this.backgroundColor,
    required this.icon,
    required this.text,
  });

  final Color backgroundColor;
  final Icon icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: backgroundColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [icon, SizedBox(width: 12.0), Text(text)],
      ),
    );
  }
}
