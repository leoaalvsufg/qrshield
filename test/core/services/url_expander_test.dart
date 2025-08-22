import 'package:flutter_test/flutter_test.dart';
import 'package:qrshield/core/services/url_expander.dart';

// Stub implementation for testing
class StubHttpUrlExpander implements UrlExpander {
  @override
  Future<UrlExpandResult> expand(Uri url) async {
    return UrlExpandResult(url, 0, [url]);
  }
}

void main() {
  group('StubUrlExpander', () {
    late StubUrlExpander expander;

    setUp(() {
      expander = StubUrlExpander();
    });

    test('should return original URL with no redirects', () async {
      final url = Uri.parse('https://example.com');

      final result = await expander.expand(url);

      expect(result.finalUrl, equals(url));
      expect(result.redirects, equals(0));
      expect(result.redirectChain, equals([url]));
    });

    test('should handle different URL schemes', () async {
      final testUrls = [
        'https://secure.example.com',
        'http://insecure.example.com',
        'ftp://files.example.com',
      ];

      for (final urlString in testUrls) {
        final url = Uri.parse(urlString);
        final result = await expander.expand(url);

        expect(result.finalUrl, equals(url));
        expect(result.redirects, equals(0));
        expect(result.redirectChain, contains(url));
      }
    });

    test('should handle URLs with query parameters', () async {
      final url = Uri.parse('https://example.com/path?param=value&other=test');

      final result = await expander.expand(url);

      expect(result.finalUrl, equals(url));
      expect(result.redirects, equals(0));
    });

    test('should handle URLs with fragments', () async {
      final url = Uri.parse('https://example.com/page#section');

      final result = await expander.expand(url);

      expect(result.finalUrl, equals(url));
      expect(result.redirects, equals(0));
    });
  });

  group('UrlExpandResult', () {
    test('should create result with redirect chain', () {
      final originalUrl = Uri.parse('https://short.ly/abc');
      final finalUrl = Uri.parse('https://example.com/final');
      final redirectChain = [originalUrl, finalUrl];

      final result = UrlExpandResult(finalUrl, 1, redirectChain);

      expect(result.finalUrl, equals(finalUrl));
      expect(result.redirects, equals(1));
      expect(result.redirectChain, equals(redirectChain));
    });

    test('should handle equality comparison', () {
      final url1 = Uri.parse('https://example.com');
      final url2 = Uri.parse('https://example.com');
      final chain = [url1];

      final result1 = UrlExpandResult(url1, 0, chain);
      final result2 = UrlExpandResult(url2, 0, chain);

      expect(result1, equals(result2));
    });

    test('should handle toString', () {
      final url = Uri.parse('https://example.com');
      final result = UrlExpandResult(url, 2, [url]);

      final stringResult = result.toString();

      expect(stringResult, contains('https://example.com'));
      expect(stringResult, contains('2'));
    });
  });

  // Note: ShortenerAwareExpander tests are skipped to avoid HTTP requests in CI
  // In a real implementation, these would use mocked HTTP clients
}
