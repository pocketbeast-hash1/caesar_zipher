abstract class CodesValidator {
  static final int useIdLength = 2;
  static final int gtinLength = 14;

  static String getGTIN(String code) {
    return code.substring(useIdLength, gtinLength + useIdLength);
  }
}