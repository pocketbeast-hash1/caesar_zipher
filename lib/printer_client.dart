import "dart:async";
import "package:ctelnet/ctelnet.dart";
import "package:caesar_zipher/app_logger.dart";

typedef OnDataTriggerCallback = void Function(String data);

class PrinterConfig {
  String printerHost;
  int printerPort;
  String barcodeFieldName;
  String gtinFieldName;

  PrinterConfig(
    this.printerHost,
    this.printerPort,
    this.barcodeFieldName,
    this.gtinFieldName,
  );
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

  static void _onData(Message msg) {
    String msgData = msg.text;
    msgData = msgData.replaceAll("\r", "");
    msgData = msgData.replaceAll("\n", "");

    _lastResponse = msgData;
    _lastResponseDate = DateTime.now();

    _onDataTrigger?.call(msgData);
  }

  /// Returm map from string like: `field1=value1|field2=value2|field3=value3|`
  static Map<String, String> _getMapFromStringFields(String content) {
    Map<String, String> fields = {};

    List<String> contentParts = content
        .split("|")
        .where((el) => el.isNotEmpty)
        .toList();
    for (String part in contentParts) {
      List<String> pair = part.split("=");
      fields[pair[0]] = pair.length > 1 ? pair[1] : "";
    }

    return fields;
  }

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

  static Future<String> sendCommand(String command, {int timeout = 5}) async {
    DateTime prevResponse = _lastResponseDate;

    _client?.send("$command\r\n");

    DateTime endTimeout = DateTime.now().add(Duration(seconds: timeout));
    while (!DateTime.now().isAfter(endTimeout) &&
        !_lastResponseDate.isAfter(prevResponse)) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    bool gotResponse = _lastResponseDate.isAfter(prevResponse);
    String response = gotResponse ? _lastResponse : "";
    AppLogger.logger.d(
      "Отправлена команда: $command\nОтвет получен: $gotResponse\nОтвет: $response",
    );

    return response;
  }

  static Future<void> changeState(PrinterStates state) async {
    String response = await sendCommand("SST|${state.state}|");
    if (response != PrinterResponse.ok.value) {
      throw Exception(
        "Не удалось изменить состояние принтера (некорректный ответ). Ожидается: ${PrinterResponse.ok.value}. Получен: $response",
      );
    }
  }

  static Future<PrinterStates> getState() async {
    String response = await sendCommand("GST");
    List<String> parts = response.split("|");
    if (parts.length < 2) return PrinterStates.undefined;

    String stringState = parts[1];
    int? intState = int.tryParse(stringState);
    if (intState == null) return PrinterStates.undefined;

    return PrinterStates.findByValue(intState);
  }

  static Future<void> enableNotification(PrinterNotifications notification) async {
    String response = await sendCommand("SNO|${notification.value}|1|");
    if (response != PrinterResponse.ok.value) {
      throw Exception(
        "Не удалось включить уведомление $notification (некорректный ответ). Ожидается: ${PrinterResponse.ok.value}. Получен: $response",
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

    if (response != PrinterResponse.ok.value) {
      throw Exception(
        "Некорректный ответ от устройства во время обновления полей задания. Ожидается: ${PrinterResponse.ok.value}. Получен: $response",
      );
    }
  }

  static Future<Map<String, String>> getCurrentJobData() async {
    String content = await sendCommand("GJD");
    Map<String, String> fields = _getMapFromStringFields(content);

    return fields;
  }
}

enum PrinterResponse {
  ok("ACK"),
  ;

  final String value;
  const PrinterResponse(this.value);
}

enum PrinterStates {
  /// can't set, only read
  shutDown(0),
  startingUp(1),
  shuttingDown(2),
  running(3),
  offline(4),
  undefined(999),
  ;

  final int state;
  const PrinterStates(this.state);

  static PrinterStates findByValue(int value) {
    return values.firstWhere(
      (el) => el.state == value,
      orElse: () => PrinterStates.undefined,
    );
  }
}

enum PrinterNotifications {
  stateChange("STS"),
  printStart("PRS"),
  printComplete("PRC"),
  ioOutputChange("OUT"),
  errorStateChange("ERS"),
  currentJobChanged("JOB"),
  ioOutputChangeQueueEmpty("QEM"),
  ioOutputChangeQueueFull("QFU"),
  ioOutputChangeQueueHigh("QHI"),
  ioOutputChangeQueueLow("QLO"),
  ;
  
  final String value;
  const PrinterNotifications(this.value);
}
