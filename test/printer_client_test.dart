import 'package:caesar_zipher/printer_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PrinterClient response helpers', () {
    test('splits multi-line responses and trims CRLF', () {
      final lines = PrinterClient.splitResponseLines('ACK\r\nJOB|1|\r\n');

      expect(lines, ['ACK', 'JOB|1|']);
    });

    test('recognizes printer notifications', () {
      expect(PrinterClient.isNotificationLine('PRS'), isTrue);
      expect(PrinterClient.isNotificationLine('JOB|1|'), isTrue);
      expect(PrinterClient.isNotificationLine('STS|3|'), isTrue);
      expect(PrinterClient.isNotificationLine('ACK'), isFalse);
      expect(PrinterClient.isNotificationLine('GJD|foo=bar|'), isFalse);
    });
  });
}
