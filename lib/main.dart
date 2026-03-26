import "package:caesar_zipher/models/global_state_model.dart";
import "package:caesar_zipher/widgets/wrapper.dart";
import "package:flutter/material.dart";
import "package:fluttertoast/fluttertoast.dart";
import "package:caesar_zipher/widgets/toast_context.dart";
import "package:package_info_plus/package_info_plus.dart";
import "package:provider/provider.dart";

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
GlobalStateModel globalState = GlobalStateModel();

void main() {
  runApp(
    MaterialApp(
      builder: FToastBuilder(),
      home: MainApp(),
      navigatorKey: navigatorKey,
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      globalState.appVersion = info.version;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ToastContext(
        child: Center(
          child: ChangeNotifierProvider(
            create: (context) => globalState,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(width: 1200, height: 800, child: Wrapper()),
            ),
          ),
        ),
      ),
    );
  }
}
