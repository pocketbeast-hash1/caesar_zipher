import "dart:async";
import "package:ctelnet/ctelnet.dart";
import "package:caesar_zipher/app_logger.dart";

typedef OnDataTriggerCallback = void Function(String data);

class TelnetConfig {
  String printerHost;
  int printerPort;
  String barcodeFieldName;

  TelnetConfig(this.printerHost, this.printerPort, this.barcodeFieldName);
}

abstract class TelnetClient {
  static final String responseOK = "ACK";

  static CTelnetClient? _client;
  static Stream<Message>? _stream;
  static StreamSubscription<Message>? _sub;
  static Function? _onDataTrigger;
  static String _lastResponse = "";
  static DateTime _lastResponseDate = DateTime.now();

  static Future<void> connect(
    TelnetConfig config, {
    OnDataTriggerCallback? onDataTrigger,
  }) async {
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

    _onDataTrigger = onDataTrigger;
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

    _onDataTrigger?.call(msg);
  }

  static Future<String> sendCommand(String command, {int timeout = 5}) async {
    DateTime prevResponse = _lastResponseDate;

    _client?.send("$command\r\n");

    DateTime endTimeout = DateTime.now().add(Duration(seconds: timeout));
    while (!DateTime.now().isAfter(endTimeout) &&
        !_lastResponseDate.isAfter(prevResponse)) {
      await Future.delayed(Duration(milliseconds: 50));
    }

    bool gotResponse = _lastResponseDate.isAfter(prevResponse);
    String response = gotResponse ? _lastResponse : "";
    AppLogger.logger.i(
      "Отправлена команда: $command\nОтвет получен: $gotResponse\nОтвет: $response",
    );

    response = response.replaceAll("\r", "");
    response = response.replaceAll("\n", "");

    return response;
  }

  static Future<void> updateJob(Map<String, String> fields) async {
    List<String> commandParts = ["JDA"];

    for (var pair in fields.entries) {
      commandParts.add("${pair.key}=${pair.value}");
    }

    String command = "${commandParts.join("|")}|";
    String response = await sendCommand(command);

    if (response != TelnetClient.responseOK) {
      throw Exception(
        "Некорректный ответ от устройства во время обновления полей задания. Ожидается: ${TelnetClient.responseOK}. Получен: $response",
      );
    }
  }
}
