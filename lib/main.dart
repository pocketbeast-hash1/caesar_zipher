import 'package:caesar_zipher/app_logger.dart';
import 'package:flutter/material.dart';
import "telnet_client.dart";

void main() {
    runApp(const MainApp());
}

class MainApp extends StatelessWidget {
    const MainApp({super.key});

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            home: Scaffold(
                body: Center(
                    child: Row(
                        children: [

                            TextButton(
                                onPressed: () async {
                                    await TelnetClient.connect(TelnetConfig("192.168.2.153", 20000, "DataDM"));
                                }, 
                                child: Text("CONNECT TO PRINTER")
                            ),
                            TextButton(
                                onPressed: () async {
                                    await TelnetClient.disconnect();
                                }, 
                                child: Text("DISCONNECT FROM PRINTER")
                            ),
                            TextButton(
                                onPressed: () async {
                                    var response = await TelnetClient.sendCommand("GST");
                                    AppLogger.logger.d("response from printer: $response");
                                }, 
                                child: Text("SEND COMMAND TO PRINTER")
                            )

                        ],
                    ),
                ),
            ),
        );
    }
}
