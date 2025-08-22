import 'package:qrshield/core/domain/payload.dart';

/// Risk assessment result
class RiskScore {
  // explicações legíveis

  const RiskScore(this.level, this.value, this.reasons);
  final String level; // 'safe' | 'suspicious' | 'danger'
  final int value; // 0..100
  final List<String> reasons;

  /// Safe risk level (0-19)
  static const String safe = 'safe';

  /// Suspicious risk level (20-49)
  static const String suspicious = 'suspicious';

  /// Dangerous risk level (50+)
  static const String danger = 'danger';

  @override
  String toString() =>
      'RiskScore(level: $level, value: $value, reasons: $reasons)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RiskScore &&
          runtimeType == other.runtimeType &&
          level == other.level &&
          value == other.value &&
          _listEquals(reasons, other.reasons);

  @override
  int get hashCode => level.hashCode ^ value.hashCode ^ reasons.hashCode;

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Signals used for risk computation
class Signals {
  const Signals({
    this.reputationMatch = false,
    this.redirects = 0,
    this.hasPunycode = false,
    this.blockedScheme = false,
    this.wifiOpen = false,
    this.pixCrcInvalid = false,
    this.pixGuiInvalid = false,
    this.pixDomainUnknown = false,
  });
  final bool reputationMatch; // resultado do backend (malware/social/uws)
  final int redirects; // se expandido
  final bool hasPunycode;
  final bool blockedScheme;
  final bool wifiOpen;
  final bool pixCrcInvalid;
  final bool pixGuiInvalid;
  final bool pixDomainUnknown;

  @override
  String toString() =>
      'Signals(reputationMatch: $reputationMatch, redirects: $redirects, '
      'hasPunycode: $hasPunycode, blockedScheme: $blockedScheme, '
      'wifiOpen: $wifiOpen, pixCrcInvalid: $pixCrcInvalid, '
      'pixGuiInvalid: $pixGuiInvalid, pixDomainUnknown: $pixDomainUnknown)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Signals &&
          runtimeType == other.runtimeType &&
          reputationMatch == other.reputationMatch &&
          redirects == other.redirects &&
          hasPunycode == other.hasPunycode &&
          blockedScheme == other.blockedScheme &&
          wifiOpen == other.wifiOpen &&
          pixCrcInvalid == other.pixCrcInvalid &&
          pixGuiInvalid == other.pixGuiInvalid &&
          pixDomainUnknown == other.pixDomainUnknown;

  @override
  int get hashCode =>
      reputationMatch.hashCode ^
      redirects.hashCode ^
      hasPunycode.hashCode ^
      blockedScheme.hashCode ^
      wifiOpen.hashCode ^
      pixCrcInvalid.hashCode ^
      pixGuiInvalid.hashCode ^
      pixDomainUnknown.hashCode;
}

/// Computes risk score based on payload and signals
RiskScore computeRisk(Payload payload, Signals signals) {
  var score = 0;
  final reasons = <String>[];

  // WebRisk/reputation match: +70
  if (signals.reputationMatch) {
    score += 70;
    reasons.add('Detectado em base de dados de ameaças');
  }

  // Blocked scheme: +70 (immediate danger)
  if (signals.blockedScheme) {
    score += 70;
    reasons.add('Esquema de URL perigoso detectado');
  }

  // Deep links: +40
  if (payload is DeeplinkPayload) {
    score += 40;
    reasons.add('Link de aplicativo pode abrir apps maliciosos');
  }

  // PIX issues: +40
  if (payload is PixPayload) {
    if (signals.pixCrcInvalid) {
      score += 40;
      reasons.add('Código PIX com checksum inválido');
    }
    if (signals.pixGuiInvalid) {
      score += 40;
      reasons.add('Código PIX com identificador inválido');
    }
    if (signals.pixDomainUnknown) {
      score += 30;
      reasons.add('Domínio PIX dinâmico não reconhecido');
    }
  }

  // Punycode: +20
  if (signals.hasPunycode) {
    score += 20;
    reasons.add('URL contém caracteres internacionais suspeitos');
  }

  // WiFi open: +20
  if (payload is WifiPayload && signals.wifiOpen) {
    score += 20;
    reasons.add('Rede WiFi aberta pode ser insegura');
  }

  // Shortener with redirects: +15
  if (signals.redirects >= 2) {
    score += 15;
    reasons.add('Múltiplos redirecionamentos detectados');
  }

  // Determine level based on score
  String level;
  if (score >= 50) {
    level = RiskScore.danger;
  } else if (score >= 20) {
    level = RiskScore.suspicious;
  } else {
    level = RiskScore.safe;
    if (reasons.isEmpty) {
      reasons.add('Nenhum indicador de risco detectado');
    }
  }

  // Cap score at 100
  score = score > 100 ? 100 : score;

  return RiskScore(level, score, reasons);
}
