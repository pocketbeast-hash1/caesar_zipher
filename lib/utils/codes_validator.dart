abstract class CodesValidator {
  static final int useIdLength = 2;
  static final int gtinLength = 14;

  static String getGTIN(String code) {
    return code.substring(useIdLength, gtinLength + useIdLength);
  }

  static String getCodeWithNonShieldedSeparatorGS1(String code) {
    String newCode = code.replaceAll("\\u001D", '\u001d');
    newCode = newCode.replaceAll("\\u001d", '\u001d');
    newCode = newCode.replaceAll("\\x1d", '\u001d');

    return newCode;
  }
}