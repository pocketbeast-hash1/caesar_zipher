import "dart:async";
import "package:ctelnet/ctelnet.dart";
import "package:caesar_zipher/app_logger.dart";

typedef OnDataTriggerCallback = void Function(String data);

class PrinterConfig {
  String printerHost;
  int printerPort;
  String barcodeFieldName;
  String gtinFieldName;

  PrinterConfig(this.printerHost, this.printerPort, this.barcodeFieldName, this.gtinFieldName);
}

abstract class PrinterClient {
  static CTelnetClient? _client;
  static String _barcodeFieldName = "";
  static String _gtinFieldName = "";
  static Stream<Message>? _stream;
  static StreamSubscription<Message>? _sub;
  static Function? _onDataTrigger;
  static String _lastResponse = "";
  static DateTime _lastResponseDate = DateTime.now();

  static String get barcodeFieldName => _barcodeFieldName;
  static String get gtinFieldName => _gtinFieldName;

  static Future<void> connect(
    PrinterConfig config, {
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

    _barcodeFieldName = config.barcodeFieldName;
    _gtinFieldName = config.gtinFieldName;

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
    String msgData = msg.text;
    msgData = msgData.replaceAll("\r", "");
    msgData = msgData.replaceAll("\n", "");
    
    _lastResponse = msgData;
    _lastResponseDate = DateTime.now();

    _onDataTrigger?.call(msgData);
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
    AppLogger.logger.d(
      "Отправлена команда: $command\nОтвет получен: $gotResponse\nОтвет: $response",
    );

    return response;
  }

  static Future<void> enablePrintNotification() async {
    String response = await sendCommand("SNO|PRC|1|");
    if (response != PrinterResponse.ok) {
      throw Exception(
        "Не удалось включить уведомления о печати (некорректный ответ). Ожидается: ${PrinterResponse.ok}. Получен: $response",
      );
    }
  }

  static Future<void> enableJobChangedNotification() async {
    String response = await sendCommand("SNO|JOB|1|");
    if (response != PrinterResponse.ok) {
      throw Exception(
        "Не удалось включить уведомления об изменении задания печати (некорректный ответ). Ожидается: ${PrinterResponse.ok}. Получен: $response",
      );
    }
  }

  static Future<void> updateJob(Map<String, String> fields) async {
    List<String> commandParts = ["JDA"];

    for (var pair in fields.entries) {
      commandParts.add("${pair.key}=${pair.value}");
    }

    String command = "${commandParts.join("|")}|";
    String response = await sendCommand(command);

    if (response != PrinterResponse.ok) {
      throw Exception(
        "Некорректный ответ от устройства во время обновления полей задания. Ожидается: ${PrinterResponse.ok}. Получен: $response",
      );
    }
  }

  static Future<Map<String, String>> getCurrentJobData() async {
    Map<String, String> fields = {};

    String content = await sendCommand("GJD");
    List<String> contentParts = content.split("|");
    contentParts.removeRange(0, 2);
    for (String part in contentParts) {
      List<String> pair = part.split("=");
      fields[pair[0]] = pair.length > 1 ? pair[1] : "";
    }

    return fields;
  }
}

abstract class PrinterResponse {
  static final ok = "ACK";
  static final printComplete = "PRC";
  static final jobChanged = "JOB";
}
