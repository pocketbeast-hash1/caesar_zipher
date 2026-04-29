import "dart:async";
import "package:caesar_zipher/listeners/printer_listeners.dart";
import "package:ctelnet/ctelnet.dart";
import "package:caesar_zipher/app_logger.dart";

typedef OnDataTriggerCallback = void Function(String data);

class PrinterConfig {
  String printerHost;
  int printerPort;
  String gtinField;
  String serialNumberField;
  List<String> cryptoPartsFields;

  PrinterConfig(
    this.printerHost,
    this.printerPort,
    this.gtinField,
    this.serialNumberField,
    this.cryptoPartsFields,
  );
}

abstract class PrinterClient {
  static String _gtinField = "";
  static String _serialNumberField = "";
  static List<String> _cryptoPartsFields = [];

  static CTelnetClient? _client;
  static Stream<Message>? _stream;
  static StreamSubscription<Message>? _sub;
  static Function? _onDataTrigger;
  static Timer? _keepAlive;

  static int _responseNumber = 0;
  static final Map<int, String> _responseMap = {};
  static final int _maxResponseMapLength = 15;

  static String get gtinField => _gtinField;
  static String get serialNumberField => _serialNumberField;
  static List<String> get cryptoPartsFields => _cryptoPartsFields;

  static void _onData(Message msg) {
    String msgData = msg.text;
    msgData = msgData.replaceAll("\r", "");
    msgData = msgData.replaceAll("\n", "");

    PrinterNotifications? notificationType =
        PrinterListeners.getNotificationType(msgData);

    // не нужны ответы от оповещений
    if (notificationType == null) {
      _responseNumber++;
      
      if (_responseMap.length == _maxResponseMapLength) {
        List<int> keys = _responseMap.keys.toList();
        keys.sort();
        _responseMap.remove(keys.first);
      }
      _responseMap[_responseNumber] = msgData;
    }

    _onDataTrigger?.call(msgData);
  }

  /// Returm map from string like: `"field1=value1|field2=value2|field3=value3|"`
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

    _gtinField = config.gtinField;
    _serialNumberField = config.serialNumberField;
    _cryptoPartsFields = config.cryptoPartsFields;

    _stream = await _client!.connect();
    _sub = _stream!.listen(_onData);

    _onDataTrigger = onDataTrigger;

    _keepAlive = Timer.periodic(Duration(seconds: 10), PrinterListeners.keepAliveTimer);
  }

  static Future<void> disconnect() async {
    _sub?.cancel();
    _sub = null;

    _stream = null;

    PrinterClient.stopKeepAlive();
    
    await _client?.disconnect();
    _client = null;
  }

  static Future<void> reconnect() async {
    if (_client?.status == ConnectionStatus.connected) {
      _sub?.cancel();
      _sub = null;
      _stream = null;

      await _client!.disconnect();
    }

    if (_client == null) {
      throw Exception("Printer not init! _client is null.");
    }

    _stream = await _client!.connect();
    if (_stream == null) {
      throw Exception("Printer not connected! _stream is null.");
    }

    _sub = _stream!.listen(_onData);
  }

  static void stopKeepAlive() {
    _keepAlive?.cancel();
    _keepAlive = null;
  }

  static Future<String> sendCommand(String command, {int timeout = 5}) async {
    int currentResponseNumber = _responseNumber + 1;
    _client?.send("$command\r\n");

    DateTime endTimeout = DateTime.now().add(Duration(seconds: timeout));
    while (DateTime.now().isBefore(endTimeout) &&
        _responseNumber < currentResponseNumber) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    bool gotResponse = _responseMap.containsKey(currentResponseNumber);
    String response = gotResponse ? _responseMap[currentResponseNumber]! : "";
    AppLogger.logger.d(
      "Отправлена команда: $command\nОтвет получен: $gotResponse\nНомер ответа: $currentResponseNumber\nОтвет: $response",
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

  static Future<void> enableNotification(
    PrinterNotifications notification,
  ) async {
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
  ok("ACK");

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
  undefined(999);

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
  ioOutputChangeQueueLow("QLO");

  final String value;
  const PrinterNotifications(this.value);
}
