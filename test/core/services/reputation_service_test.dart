import 'package:flutter_test/flutter_test.dart';
import 'package:qrshield/core/services/reputation_service.dart';

void main() {
  group('StubReputationService', () {
    late StubReputationService service;

    setUp(() {
      service = StubReputationService();
    });

    test('should return false for safe URLs', () async {
      final safeUrl = Uri.parse('https://google.com');

      final result = await service.checkUrl(safeUrl);

      expect(result, isFalse);
    });

    test('should return true for suspicious URLs', () async {
      final suspiciousUrl = Uri.parse('https://malware.example.com');

      final result = await service.checkUrl(suspiciousUrl);

      expect(result, isTrue);
    });

    test('should detect phishing patterns', () async {
      final phishingUrl = Uri.parse('https://phishing.site.com');

      final result = await service.checkUrl(phishingUrl);

      expect(result, isTrue);
    });

    test('should detect scam patterns in path', () async {
      final scamUrl = Uri.parse('https://example.com/scam/page');

      final result = await service.checkUrl(scamUrl);

      expect(result, isTrue);
    });

    test('should handle URLs with suspicious keywords', () async {
      final testCases = [
        'https://virus.example.com',
        'https://trojan.site.org',
        'https://example.com/suspicious/path',
        'https://fake.bank.com',
        'https://fraud.detection.test',
        'https://steal.data.com',
        'https://hack.attempt.org',
      ];

      for (final urlString in testCases) {
        final url = Uri.parse(urlString);
        final result = await service.checkUrl(url);
        expect(
          result,
          isTrue,
          reason: 'Should flag suspicious URL: $urlString',
        );
      }
    });

    test('should not flag legitimate URLs', () async {
      final legitimateUrls = [
        'https://google.com',
        'https://github.com',
        'https://stackoverflow.com',
        'https://flutter.dev',
        'https://dart.dev',
      ];

      for (final urlString in legitimateUrls) {
        final url = Uri.parse(urlString);
        final result = await service.checkUrl(url);
        expect(
          result,
          isFalse,
          reason: 'Should not flag legitimate URL: $urlString',
        );
      }
    });
  });
}
