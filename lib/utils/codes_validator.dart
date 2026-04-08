import 'package:caesar_zipher/app_logger.dart';

abstract class CodesValidator {
  static final int useIdLength = 2;
  static final int gtinLength = 14;

  static String getCodeWithNonShieldedSeparatorGS1(String code) {
    String newCode = code.replaceAll("\\u001D", '\u001d');
    newCode = newCode.replaceAll("\\u001d", '\u001d');
    newCode = newCode.replaceAll("\\x1d", '\u001d');

    return newCode;
  }

  static CodeStructure getCodeStructure(String code) {
    try {
      String nonShielded = getCodeWithNonShieldedSeparatorGS1(code);
      List<String> parts = nonShielded.split('\u001d');
      String beforeCrypto = parts.removeAt(0);

      String firstUseID = beforeCrypto.substring(0, 2);
      String gtin = beforeCrypto.substring(2, 16);
      String secondUseID = beforeCrypto.substring(16, 18);

      String serialNumber = beforeCrypto.replaceAll(
        firstUseID + gtin + secondUseID,
        "",
      );

      // убираем у каждого элемента крипточастей первые два символа, тк это код идентификации
      List<String> cryptoParts = parts
          .map((elem) => elem.substring(2))
          .toList();

      return CodeStructure(
        firstUseID,
        gtin,
        secondUseID,
        serialNumber,
        cryptoParts,
      );
    } catch (e, s) {
      AppLogger.logger.e("Ошибка при попытке получить структуру кода $code: $e, $s");
      return CodeStructure("", "", "", "", []);
    }
  }
}

class CodeStructure {
  final String firstUseID;
  final String gtin;
  final String secondUseID;
  final String serialNumber;
  final List<String> cryptoParts;

  CodeStructure(
    this.firstUseID,
    this.gtin,
    this.secondUseID,
    this.serialNumber,
    this.cryptoParts,
  );
}
