import 'package:flutter_test/flutter_test.dart';
import 'package:qrshield/core/domain/pix_emv.dart';

void main() {
  group('PIX EMV Analysis', () {
    test('should analyze valid PIX EMV code', () {
      // Valid PIX EMV with br.gov.bcb.pix
      const validPix =
          '00020126580014br.gov.bcb.pix0136123e4567-e12b-12d3-a456-426614174000520400005303986540510.005802BR5913FULANO DE TAL6008BRASILIA62070503***6304A4F3';

      final analysis = analyzePixEmv(validPix);

      expect(analysis.gui, equals('br.gov.bcb.pix'));
      expect(analysis.fields, isNotEmpty);
      expect(analysis.fields.containsKey('00'), isTrue);
    });

    test('should detect invalid CRC', () {
      // PIX with invalid CRC (last 4 characters changed)
      const invalidCrcPix =
          '00020126580014br.gov.bcb.pix0136123e4567-e12b-12d3-a456-426614174000520400005303986540510.005802BR5913FULANO DE TAL6008BRASILIA62070503***6304XXXX';

      final analysis = analyzePixEmv(invalidCrcPix);

      expect(analysis.crcValid, isFalse);
    });

    test('should handle malformed PIX code', () {
      const malformedPix = 'invalid-pix-code';

      final analysis = analyzePixEmv(malformedPix);

      expect(analysis.crcValid, isFalse);
      expect(analysis.gui, isEmpty);
      expect(analysis.fields, isEmpty);
    });

    test('should extract GUI from valid PIX', () {
      const pixWithGui =
          '00020126580014br.gov.bcb.pix0136test-key520400005303986540510.005802BR5913TEST USER6008BRASILIA62070503***6304ABCD';

      final analysis = analyzePixEmv(pixWithGui);

      expect(analysis.gui, equals('br.gov.bcb.pix'));
    });

    test('should handle empty PIX code', () {
      const emptyPix = '';

      final analysis = analyzePixEmv(emptyPix);

      expect(analysis.crcValid, isFalse);
      expect(analysis.gui, isEmpty);
      expect(analysis.fields, isEmpty);
    });

    test('should handle short PIX code', () {
      const shortPix = '123';

      final analysis = analyzePixEmv(shortPix);

      expect(analysis.crcValid, isFalse);
      expect(analysis.gui, isEmpty);
      expect(analysis.fields, isEmpty);
    });
  });
}
