import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Settings {
  String printerHost;
  int printerPort;
  String gtinField;
  String serialNumberField;
  List<String> cryptoPartsFields;

  Settings(
    this.printerHost,
    this.printerPort,
    this.gtinField,
    this.serialNumberField,
    this.cryptoPartsFields,
  );

  static Future<String> get _localPath async {
    final directory = await getApplicationCacheDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/settings.json');
  }

  void operator []=(String key, dynamic value) {
    switch (key) {
      case "printerHost":
        printerHost = value;
        break;
      case "printerPort":
        dynamic finalVal;
        if (value.runtimeType == int) {
          finalVal = value;
        } else if (value.runtimeType == String) {
          finalVal = int.tryParse(value);
          if (finalVal == null) {
            throw Exception("Invalid value: $value. Need int");
          }
        } else {
          throw Exception("Invalid value: $value. Need int");
        }

        printerPort = finalVal;
        break;
      case "gtinField":
        gtinField = value;
        break;
      case "serialNumberField":
        serialNumberField = value;
        break;
      case "cryptoPartsFields":
        dynamic finalVal;
        if (value.runtimeType == List<String>) {
          finalVal = value;
        } else if (value.runtimeType == String) {
          finalVal = value.split(",").map((elem) => elem.trim()).toList().cast<String>();
        } else {
          throw Exception("Invalid value: $value. Need List<String>");
        }

        cryptoPartsFields = finalVal;
        break;
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "printerHost": printerHost,
      "printerPort": printerPort,
      "gtinField": gtinField,
      "serialNumberField": serialNumberField,
      "cryptoPartsFields": cryptoPartsFields,
    };

    return map;
  }

  static Future<Settings> getSettings() async {
    File file = await _localFile;
    if (!await file.exists()) {
      return Settings("127.0.0.1", 20000, "GTIN", "SerialNumber", [
        "CryptoPart",
      ]);
    }

    String content = await file.readAsString();
    Map<String, dynamic> data = jsonDecode(content);

    return Settings(
      data.containsKey("printerHost") ? data["printerHost"] : "127.0.0.1",
      data.containsKey("printerPort") ? data["printerPort"] : 20000,
      data.containsKey("gtinField") ? data["gtinField"] : "GTIN",
      data.containsKey("serialNumberField")
          ? data["serialNumberField"]
          : "SerialNumber",
      data.containsKey("cryptoPartsFields")
          ? data["cryptoPartsFields"].cast<String>()
          : ["CryptoPart"],
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
