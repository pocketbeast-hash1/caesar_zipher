import "package:caesar_zipher/app_logger.dart";
import "package:caesar_zipher/widgets/bool_button.dart";
import "package:flutter/material.dart";
import "package:fluttertoast/fluttertoast.dart";
import "telnet_client.dart";
import "package:caesar_zipher/widgets/toast_context.dart";

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
      body: ToastContext(
        child: Center(
          child: Row(
            children: [
              TextButton(
                onPressed: () async {
                  Future<void> promise = TelnetClient.connect(
                    TelnetConfig("192.168.2.153", 20000, "DataDM"),
                  );
                  ToastContext.promise(
                    promise,
                    "pending",
                    success: "success",
                    error: "error",
                  );
                },
                child: Text("CONNECT TO PRINTER"),
              ),
              TextButton(
                onPressed: () async {
                  await TelnetClient.disconnect();
                },
                child: Text("DISCONNECT FROM PRINTER"),
              ),
              TextButton(
                onPressed: () async {
                  var response = await TelnetClient.sendCommand("GST");
                  AppLogger.logger.d("response from printer: $response");
                },
                child: Text("SEND COMMAND TO PRINTER"),
              ),
              TextButton(
                onPressed: () {
                  ToastContext.error(
                    "very very very very very very very very very very very very very very very very long text",
                  );
                },
                child: Text("show toast"),
              ),
              BoolButton(
                btnState: false,
                text: "test",
                onPress: () {
                  //
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
