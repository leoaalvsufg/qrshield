import 'dart:convert';

/// PIX EMV analysis result
class PixAnalysis {
  // chave/url PSP, valor, cidade, etc.

  const PixAnalysis({
    required this.crcValid,
    required this.gui,
    required this.fields,
  });
  final bool crcValid;
  final String gui; // deve ser br.gov.bcb.pix
  final Map<String, String> fields;

  @override
  String toString() =>
      'PixAnalysis(crcValid: $crcValid, gui: $gui, fields: $fields)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PixAnalysis &&
          runtimeType == other.runtimeType &&
          crcValid == other.crcValid &&
          gui == other.gui &&
          _mapEquals(fields, other.fields);

  @override
  int get hashCode => crcValid.hashCode ^ gui.hashCode ^ fields.hashCode;

  bool _mapEquals(Map<String, String> a, Map<String, String> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}

/// Analyzes PIX EMV QR code
PixAnalysis analyzePixEmv(String raw) {
  try {
    // Parse EMV TLV structure
    final fields = <String, String>{};
    var gui = '';

    // Simple TLV parser for PIX EMV
    var index = 0;
    while (index < raw.length - 4) {
      if (index + 4 > raw.length) break;

      final tag = raw.substring(index, index + 2);
      final lengthStr = raw.substring(index + 2, index + 4);

      int length;
      try {
        length = int.parse(lengthStr);
      } catch (e) {
        break;
      }

      if (index + 4 + length > raw.length) break;

      final value = raw.substring(index + 4, index + 4 + length);
      fields[tag] = value;

      // Extract GUI (tag 00) - but check if it contains the PIX identifier
      if (tag == '00') {
        gui = value;
      }

      // Also check if the value itself contains the PIX identifier
      if (value.contains('br.gov.bcb.pix')) {
        gui = 'br.gov.bcb.pix';
      }

      index += 4 + length;
    }

    // Validate CRC16 (last 4 characters should be CRC)
    final crcValid = _validateCrc16(raw);

    // Extract common fields
    _extractCommonFields(fields);

    return PixAnalysis(crcValid: crcValid, gui: gui, fields: fields);
  } catch (e) {
    // Return invalid analysis on parse error
    return const PixAnalysis(crcValid: false, gui: '', fields: {});
  }
}

/// Validates CRC16 checksum for PIX EMV
bool _validateCrc16(String raw) {
  if (raw.length < 4) return false;

  try {
    // Extract CRC from last 4 characters
    final crcStr = raw.substring(raw.length - 4);
    final expectedCrc = int.parse(crcStr, radix: 16);

    // Calculate CRC16 for payload without CRC
    final payload = raw.substring(0, raw.length - 4);
    final calculatedCrc = _calculateCrc16(payload);

    return expectedCrc == calculatedCrc;
  } catch (e) {
    return false;
  }
}

/// Calculates CRC16 checksum (simplified implementation)
int _calculateCrc16(String data) {
  // Simplified CRC16-CCITT implementation
  // This is a basic implementation - in production, use a proper CRC library
  var crc = 0xFFFF;
  final bytes = utf8.encode(data);

  for (final byte in bytes) {
    crc ^= byte << 8;
    for (var i = 0; i < 8; i++) {
      if ((crc & 0x8000) != 0) {
        crc = (crc << 1) ^ 0x1021;
      } else {
        crc = crc << 1;
      }
      crc &= 0xFFFF;
    }
  }

  return crc;
}

/// Extracts and formats common PIX fields
void _extractCommonFields(Map<String, String> fields) {
  // Add human-readable field names
  final fieldNames = <String, String>{
    '00': 'Formato',
    '01': 'Tipo de Iniciação',
    '26': 'Chave PIX',
    '52': 'Categoria do Comerciante',
    '53': 'Moeda',
    '54': 'Valor',
    '58': 'País',
    '59': 'Nome do Beneficiário',
    '60': 'Cidade',
    '62': 'Informações Adicionais',
    '63': 'CRC16',
  };

  // Replace numeric tags with readable names where possible
  final readableFields = <String, String>{};
  for (final entry in fields.entries) {
    final readableName = fieldNames[entry.key] ?? 'Campo ${entry.key}';
    readableFields[readableName] = entry.value;
  }

  // Add readable fields back to original map
  fields.addAll(readableFields);
}
