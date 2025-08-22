import 'package:flutter_test/flutter_test.dart';
import 'package:qrshield/core/domain/url_heuristics.dart';

void main() {
  group('URL Heuristics', () {
    test('should detect blocked schemes', () {
      final testCases = [
        'javascript:alert("xss")',
        'data:text/html,<script>alert("xss")</script>',
        'file:///etc/passwd',
        'content://com.example.provider/data',
        'vbscript:msgbox("test")',
        'about:blank',
      ];

      for (final testCase in testCases) {
        final uri = Uri.parse(testCase);
        final result = analyzeUrl(uri);

        expect(
          result.isBlockedScheme,
          isTrue,
          reason: 'Should detect blocked scheme in: $testCase',
        );
      }
    });

    test('should not flag safe schemes', () {
      final testCases = [
        'https://example.com',
        'http://example.com',
        'ftp://files.example.com',
        'mailto:test@example.com',
        'tel:+5511999999999',
      ];

      for (final testCase in testCases) {
        final uri = Uri.parse(testCase);
        final result = analyzeUrl(uri);

        expect(
          result.isBlockedScheme,
          isFalse,
          reason: 'Should not flag safe scheme in: $testCase',
        );
      }
    });

    test('should detect punycode domains', () {
      final testCases = [
        'https://xn--e1afmkfd.xn--p1ai', // пример.рф
        'https://xn--fsq.xn--0zwm56d', // 中国
        'https://subdomain.xn--example-abc.com',
      ];

      for (final testCase in testCases) {
        final uri = Uri.parse(testCase);
        final result = analyzeUrl(uri);

        expect(
          result.hasPunycode,
          isTrue,
          reason: 'Should detect punycode in: $testCase',
        );
      }
    });

    test('should not flag regular domains as punycode', () {
      final testCases = [
        'https://example.com',
        'https://subdomain.example.org',
        'https://test-site.co.uk',
      ];

      for (final testCase in testCases) {
        final uri = Uri.parse(testCase);
        final result = analyzeUrl(uri);

        expect(
          result.hasPunycode,
          isFalse,
          reason: 'Should not flag regular domain as punycode: $testCase',
        );
      }
    });

    test('should detect URL shorteners', () {
      final testCases = [
        'https://bit.ly/abc123',
        'https://tinyurl.com/test',
        'https://t.co/abcdef',
        'https://goo.gl/maps',
        'https://short.link/test',
        'https://linktr.ee/username',
      ];

      for (final testCase in testCases) {
        final uri = Uri.parse(testCase);
        final result = analyzeUrl(uri);

        expect(
          result.looksShortener,
          isTrue,
          reason: 'Should detect shortener: $testCase',
        );
      }
    });

    test('should not flag regular domains as shorteners', () {
      final testCases = [
        'https://example.com',
        'https://google.com',
        'https://github.com',
        'https://stackoverflow.com',
      ];

      for (final testCase in testCases) {
        final uri = Uri.parse(testCase);
        final result = analyzeUrl(uri);

        expect(
          result.looksShortener,
          isFalse,
          reason: 'Should not flag regular domain as shortener: $testCase',
        );
      }
    });

    test('should detect suspicious domains', () {
      final testCases = [
        'goog1e.com', // Typosquatting
        'fac3book.com',
        'amaz0n.com',
        'micr0soft.com',
        'app1e.com',
        'test.tk', // Suspicious TLD
        'example.ml',
      ];

      for (final testCase in testCases) {
        final isSuspicious = isDomainSuspicious(testCase);

        expect(
          isSuspicious,
          isTrue,
          reason: 'Should detect suspicious domain: $testCase',
        );
      }
    });

    test('should not flag legitimate domains as suspicious', () {
      final testCases = [
        'google.com',
        'facebook.com',
        'amazon.com',
        'microsoft.com',
        'apple.com',
        'github.com',
        'stackoverflow.com',
      ];

      for (final testCase in testCases) {
        final isSuspicious = isDomainSuspicious(testCase);

        expect(
          isSuspicious,
          isFalse,
          reason: 'Should not flag legitimate domain as suspicious: $testCase',
        );
      }
    });

    test('should extract effective domain correctly', () {
      final testCases = {
        'https://www.example.com/path': 'example.com',
        'https://subdomain.test.co.uk/page': 'co.uk',
        'https://api.service.example.org': 'example.org',
        'https://example.com': 'example.com',
      };

      testCases.forEach((url, expectedDomain) {
        final uri = Uri.parse(url);
        final effectiveDomain = getEffectiveDomain(uri);

        expect(
          effectiveDomain,
          equals(expectedDomain),
          reason: 'Should extract correct effective domain from: $url',
        );
      });
    });
  });
}
