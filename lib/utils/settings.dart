import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Settings {
  String printerHost;
  int printerPort;
  String barcodeFieldName;
  String gtinFieldName;

  static Future<String> get _localPath async {
    final directory = await getApplicationCacheDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/settings.json');
  }

  Settings(this.printerHost, this.printerPort, this.barcodeFieldName, this.gtinFieldName);

  void operator []=(String key, dynamic value) {
    switch (key) {
      case "printerHost":
        printerHost = value;
        break;
      case "printerPort":
        var finalVal = value;
        if (value.runtimeType == String) {
          finalVal = int.tryParse(value);
          if (finalVal == null) {
            throw Exception("Invalid value: $value. Need int");
          }
        }

        printerPort = finalVal;
        break;
      case "barcodeFieldName":
        barcodeFieldName = value;
        break;
      case "gtinFieldName":
        gtinFieldName = value;
        break;
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "printerHost": printerHost,
      "printerPort": printerPort,
      "barcodeFieldName": barcodeFieldName,
      "gtinFieldName": gtinFieldName,
    };

    return map;
  }

  static Future<Settings> getSettings() async {
    File file = await _localFile;
    if (!await file.exists()) {
      return Settings("127.0.0.1", 20000, "DataDM", "GTIN");
    }

    String content = await file.readAsString();
    Map<String, dynamic> data = jsonDecode(content);

    return Settings(
      data.containsKey("printerHost") ? data["printerHost"] : "127.0.0.1", 
      data.containsKey("printerPort") ? data["printerPort"] : 20000, 
      data.containsKey("barcodeFieldName") ? data["barcodeFieldName"] : "DataDM",
      data.containsKey("gtinFieldName") ? data["gtinFieldName"] : "GTIN",
    );
  }

  Future<void> save() async {
    String json = jsonEncode(toMap());
    
    File file = await _localFile;
    if (!await file.exists()) {
      await file.create();
    }

    await file.writeAsString(json);
  }
}