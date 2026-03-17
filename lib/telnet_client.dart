import "dart:async";
import "package:ctelnet/ctelnet.dart";
import "package:caesar_zipher/app_logger.dart";

class TelnetConfig {
  String printerHost;
  int printerPort;
  String barcodeFieldName;

  TelnetConfig(this.printerHost, this.printerPort, this.barcodeFieldName);
}

abstract class TelnetClient {
  static CTelnetClient? _client;
  static Stream<Message>? _stream;
  static StreamSubscription<Message>? _sub;
  static String _lastResponse = "";
  static DateTime _lastResponseDate = DateTime.now();

  static Future<void> connect(TelnetConfig config) async {
    if (_client != null && _client!.connected) return;

    _client = CTelnetClient(
      host: config.printerHost,
      port: config.printerPort,
      onConnect: () {
        AppLogger.logger.i("printer connected");
      },
      onDisconnect: () {
        AppLogger.logger.i("printer disconnected");
      },
      onError: (error) {
        AppLogger.logger.e("error: $error");
      },
    );

    _stream = await _client!.connect();
    _sub = _stream!.listen(_onData);
  }

  static Future<void> disconnect() async {
    _sub?.cancel();
    await _client?.disconnect();

    _stream = null;
    _sub = null;
    _client = null;
  }

  static void _onData(Message msg) {
    _lastResponse = msg.text;
    _lastResponseDate = DateTime.now();
    AppLogger.logger.d("data: $_lastResponse");
  }

  static Future<String> sendCommand(String command, {int timeout = 5}) async {
    DateTime prevResponse = _lastResponseDate;

    _client?.send("$command\r\n");

    DateTime endTimeout = DateTime.now().add(Duration(seconds: timeout));
    while (!DateTime.now().isAfter(endTimeout) &&
        !_lastResponseDate.isAfter(prevResponse)) {
      await Future.delayed(Duration(milliseconds: 50));
    }

    return _lastResponseDate.isAfter(prevResponse) ? _lastResponse : "";
  }
}
