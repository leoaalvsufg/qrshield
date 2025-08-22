/// Base class for all QR code payload types
sealed class Payload {}

/// URL payload (http, https, ftp, etc.)
class UrlPayload extends Payload {
  UrlPayload(this.url);
  final Uri url;

  @override
  String toString() => 'UrlPayload(url: $url)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UrlPayload &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;
}

/// Deep link payload (intent://, market://, etc.)
class DeeplinkPayload extends Payload {
  DeeplinkPayload(this.scheme, this.raw);
  final String scheme;
  final String raw;

  @override
  String toString() => 'DeeplinkPayload(scheme: $scheme, raw: $raw)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeeplinkPayload &&
          runtimeType == other.runtimeType &&
          scheme == other.scheme &&
          raw == other.raw;

  @override
  int get hashCode => scheme.hashCode ^ raw.hashCode;
}

/// PIX payment payload (EMV/BR Code)
class PixPayload extends Payload {
  PixPayload({
    required this.raw,
    required this.crcValid,
    required this.gui,
    required this.fields,
  });
  final String raw;
  final bool crcValid;
  final String gui;
  final Map<String, String> fields;

  @override
  String toString() =>
      'PixPayload(raw: $raw, crcValid: $crcValid, gui: $gui, fields: $fields)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PixPayload &&
          runtimeType == other.runtimeType &&
          raw == other.raw &&
          crcValid == other.crcValid &&
          gui == other.gui &&
          _mapEquals(fields, other.fields);

  @override
  int get hashCode =>
      raw.hashCode ^ crcValid.hashCode ^ gui.hashCode ^ fields.hashCode;

  bool _mapEquals(Map<String, String> a, Map<String, String> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}

/// WiFi network payload
class WifiPayload extends Payload {
  WifiPayload({
    required this.ssid,
    required this.sec,
    this.password,
    this.hidden = false,
  });
  final String ssid;
  final String sec;
  final String? password;
  final bool hidden;

  @override
  String toString() =>
      'WifiPayload(ssid: $ssid, sec: $sec, password: ${password != null ? '[HIDDEN]' : 'null'}, hidden: $hidden)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WifiPayload &&
          runtimeType == other.runtimeType &&
          ssid == other.ssid &&
          sec == other.sec &&
          password == other.password &&
          hidden == other.hidden;

  @override
  int get hashCode =>
      ssid.hashCode ^ sec.hashCode ^ password.hashCode ^ hidden.hashCode;
}

/// Simple payload for other types (SMS, tel, mailto, geo, vcard, text)
class SimplePayload extends Payload {
  SimplePayload(this.type, this.raw);
  final String type;
  final String raw;

  @override
  String toString() => 'SimplePayload(type: $type, raw: $raw)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimplePayload &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          raw == other.raw;

  @override
  int get hashCode => type.hashCode ^ raw.hashCode;
}
