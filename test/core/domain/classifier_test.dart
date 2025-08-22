import 'package:flutter_test/flutter_test.dart';
import 'package:qrshield/core/domain/classifier.dart';
import 'package:qrshield/core/domain/payload.dart';

void main() {
  group('Classifier', () {
    test('should classify URL payload correctly', () {
      const rawUrl = 'https://example.com/path?param=value';

      final payload = classify(rawUrl);

      expect(payload, isA<UrlPayload>());
      final urlPayload = payload as UrlPayload;
      expect(urlPayload.url.scheme, equals('https'));
      expect(urlPayload.url.host, equals('example.com'));
      expect(urlPayload.url.path, equals('/path'));
      expect(urlPayload.url.query, equals('param=value'));
    });

    test('should classify deep link payload correctly', () {
      const rawDeepLink = 'intent://example.com#Intent;scheme=https;end';

      final payload = classify(rawDeepLink);

      expect(payload, isA<DeeplinkPayload>());
      final deeplinkPayload = payload as DeeplinkPayload;
      expect(deeplinkPayload.scheme, equals('intent'));
      expect(deeplinkPayload.raw, equals(rawDeepLink));
    });

    test('should classify WiFi payload correctly', () {
      const rawWifi = 'WIFI:S:MyNetwork;T:WPA;P:password123;H:false;';

      final payload = classify(rawWifi);

      expect(payload, isA<WifiPayload>());
      final wifiPayload = payload as WifiPayload;
      expect(wifiPayload.ssid, equals('MyNetwork'));
      expect(wifiPayload.sec, equals('WPA'));
      expect(wifiPayload.password, equals('password123'));
      expect(wifiPayload.hidden, isFalse);
    });

    test('should classify PIX EMV payload correctly', () {
      // PIX EMV format with br.gov.bcb.pix identifier
      const rawPix =
          '00020126580014br.gov.bcb.pix0136123e4567-e12b-12d3-a456-426614174000520400005303986540510.005802BR5913FULANO DE TAL6008BRASILIA62070503***6304A4F3';

      final payload = classify(rawPix);

      expect(payload, isA<PixPayload>());
      final pixPayload = payload as PixPayload;
      expect(pixPayload.raw, equals(rawPix));
      // Note: CRC validation and field parsing would be tested separately
    });

    test('should classify SMS payload correctly', () {
      const rawSms = 'SMSTO:+5511999999999:Hello World';

      final payload = classify(rawSms);

      expect(payload, isA<SimplePayload>());
      final simplePayload = payload as SimplePayload;
      expect(simplePayload.type, equals('sms'));
      expect(simplePayload.raw, equals(rawSms));
    });

    test('should classify tel payload correctly', () {
      const rawTel = 'tel:+5511999999999';

      final payload = classify(rawTel);

      expect(payload, isA<SimplePayload>());
      final simplePayload = payload as SimplePayload;
      expect(simplePayload.type, equals('tel'));
      expect(simplePayload.raw, equals(rawTel));
    });

    test('should classify mailto payload correctly', () {
      const rawEmail = 'mailto:test@example.com?subject=Hello';

      final payload = classify(rawEmail);

      expect(payload, isA<SimplePayload>());
      final simplePayload = payload as SimplePayload;
      expect(simplePayload.type, equals('mailto'));
      expect(simplePayload.raw, equals(rawEmail));
    });

    test('should classify geo payload correctly', () {
      const rawGeo = 'geo:-23.5505,-46.6333';

      final payload = classify(rawGeo);

      expect(payload, isA<SimplePayload>());
      final simplePayload = payload as SimplePayload;
      expect(simplePayload.type, equals('geo'));
      expect(simplePayload.raw, equals(rawGeo));
    });

    test('should classify vCard payload correctly', () {
      const rawVcard = 'BEGIN:VCARD\nVERSION:3.0\nFN:John Doe\nEND:VCARD';

      final payload = classify(rawVcard);

      expect(payload, isA<SimplePayload>());
      final simplePayload = payload as SimplePayload;
      expect(simplePayload.type, equals('vcard'));
      expect(simplePayload.raw, equals(rawVcard));
    });

    test('should classify plain text payload correctly', () {
      const rawText = 'Just some plain text content';

      final payload = classify(rawText);

      expect(payload, isA<SimplePayload>());
      final simplePayload = payload as SimplePayload;
      expect(simplePayload.type, equals('text'));
      expect(simplePayload.raw, equals(rawText));
    });
  });
}
