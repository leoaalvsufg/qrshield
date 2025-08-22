import 'package:qrshield/core/domain/payload.dart';
import 'package:qrshield/core/domain/pix_emv.dart';

/// Classifies raw QR code content into appropriate payload types
Payload classify(String raw) {
  final trimmed = raw.trim();
  
  // Check for specific schemes first before general URL parsing
  if (trimmed.startsWith('tel:')) {
    return SimplePayload('tel', trimmed);
  }

  if (trimmed.startsWith('mailto:')) {
    return SimplePayload('mailto', trimmed);
  }

  if (trimmed.startsWith('SMSTO:')) {
    return SimplePayload('sms', trimmed);
  }

  if (trimmed.startsWith('geo:')) {
    return SimplePayload('geo', trimmed);
  }

  if (trimmed.startsWith('BEGIN:VCARD')) {
    return SimplePayload('vcard', trimmed);
  }

  // Try to parse as URL
  try {
    final uri = Uri.parse(trimmed);
    if (uri.hasScheme && uri.hasAuthority) {
      // Check for deep links
      if (_isDeepLink(uri.scheme)) {
        return DeeplinkPayload(uri.scheme, trimmed);
      }

      // Regular URL
      return UrlPayload(uri);
    }
  } catch (e) {
    // Not a valid URI, continue with other checks
  }
  
  // Check for PIX EMV/BR Code
  if (_isPixEmv(trimmed)) {
    final analysis = analyzePixEmv(trimmed);
    return PixPayload(
      raw: trimmed,
      crcValid: analysis.crcValid,
      gui: analysis.gui,
      fields: analysis.fields,
    );
  }
  
  // Check for WiFi QR code
  if (trimmed.startsWith('WIFI:')) {
    return _parseWifi(trimmed);
  }
  

  
  // Default to text
  return SimplePayload('text', trimmed);
}

/// Checks if a scheme represents a deep link
bool _isDeepLink(String scheme) {
  final deepLinkSchemes = {
    'intent',
    'market',
    'android-app',
    'ios-app',
    'fb',
    'twitter',
    'instagram',
    'whatsapp',
    'telegram',
    'viber',
    'skype',
    'zoom',
    'spotify',
    'youtube',
    'tiktok',
    'linkedin',
    'pinterest',
    'reddit',
    'discord',
    'slack',
    'teams',
    'uber',
    'lyft',
    'waze',
    'maps',
    'googlemaps',
    'applemaps',
  };
  
  return deepLinkSchemes.contains(scheme.toLowerCase());
}

/// Checks if content looks like PIX EMV format
bool _isPixEmv(String content) {
  // PIX EMV codes typically start with "00" and contain only digits and uppercase letters
  if (content.length < 20) return false;

  // Check if it starts with EMV format (00XX where XX is length)
  if (!RegExp(r'^00\d{2}').hasMatch(content)) return false;

  // Check if it contains the PIX identifier
  if (content.contains('br.gov.bcb.pix')) return true;

  // Check if it contains mostly alphanumeric characters (EMV TLV format)
  final alphanumericCount = content.split('').where((c) => RegExp('[A-Z0-9]').hasMatch(c)).length;
  final alphanumericRatio = alphanumericCount / content.length;

  // EMV codes should be mostly alphanumeric and uppercase
  return alphanumericRatio > 0.8;
}

/// Parses WiFi QR code format
WifiPayload _parseWifi(String content) {
  // WIFI:S:<SSID>;T:<WPA|WEP|nopass>;P:<password>;H:<true|false>;
  final regex = RegExp('WIFI:S:([^;]*);T:([^;]*);P:([^;]*);H:([^;]*);?');
  final match = regex.firstMatch(content);
  
  if (match != null) {
    final ssid = match.group(1) ?? '';
    final security = match.group(2) ?? '';
    final password = match.group(3);
    final hiddenStr = match.group(4) ?? 'false';
    
    return WifiPayload(
      ssid: ssid,
      sec: security,
      password: (password?.isEmpty ?? true) ? null : password,
      hidden: hiddenStr.toLowerCase() == 'true',
    );
  }
  
  // Fallback for malformed WiFi QR codes
  return WifiPayload(
    ssid: 'Unknown',
    sec: 'unknown',
  );
}
