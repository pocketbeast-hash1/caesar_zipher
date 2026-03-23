import "package:caesar_zipher/models/global_state_model.dart";
import "package:caesar_zipher/widgets/load_codes_button.dart";
import "package:flutter/material.dart";
import "package:fluttertoast/fluttertoast.dart";
import "package:caesar_zipher/widgets/toast_context.dart";
import "package:provider/provider.dart";

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    MaterialApp(
      builder: FToastBuilder(),
      home: MainApp(),
      navigatorKey: navigatorKey,
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ToastContext(
        child: Center(
          child: ChangeNotifierProvider(
            create: (context) => GlobalStateModel(),
            child: LoadCodesButton(),
          ),
        ),
      ),
    );
  }
}
