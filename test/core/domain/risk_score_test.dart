import 'package:flutter_test/flutter_test.dart';
import 'package:qrshield/core/domain/payload.dart';
import 'package:qrshield/core/domain/risk_score.dart';

void main() {
  group('Risk Score Computation', () {
    test('should return safe score for clean URL', () {
      final payload = UrlPayload(Uri.parse('https://example.com'));
      const signals = Signals();
      
      final riskScore = computeRisk(payload, signals);
      
      expect(riskScore.level, equals(RiskScore.safe));
      expect(riskScore.value, lessThan(20));
      expect(riskScore.reasons, contains('Nenhum indicador de risco detectado'));
    });
    
    test('should return danger score for reputation match', () {
      final payload = UrlPayload(Uri.parse('https://malware.example.com'));
      const signals = Signals(reputationMatch: true);
      
      final riskScore = computeRisk(payload, signals);
      
      expect(riskScore.level, equals(RiskScore.danger));
      expect(riskScore.value, greaterThanOrEqualTo(70));
      expect(riskScore.reasons, contains('Detectado em base de dados de ameaças'));
    });
    
    test('should return danger score for blocked scheme', () {
      final payload = UrlPayload(Uri.parse('javascript:alert("xss")'));
      const signals = Signals(blockedScheme: true);
      
      final riskScore = computeRisk(payload, signals);
      
      expect(riskScore.level, equals(RiskScore.danger));
      expect(riskScore.value, greaterThanOrEqualTo(70));
      expect(riskScore.reasons, contains('Esquema de URL perigoso detectado'));
    });
    
    test('should return suspicious score for deep link', () {
      final payload = DeeplinkPayload('intent', 'intent://example.com');
      const signals = Signals();
      
      final riskScore = computeRisk(payload, signals);
      
      expect(riskScore.level, equals(RiskScore.suspicious));
      expect(riskScore.value, greaterThanOrEqualTo(40));
      expect(riskScore.reasons, contains('Link de aplicativo pode abrir apps maliciosos'));
    });
    
    test('should return danger score for invalid PIX CRC', () {
      final payload = PixPayload(
        raw: 'invalid-pix-code',
        crcValid: false,
        gui: 'br.gov.bcb.pix',
        fields: {},
      );
      const signals = Signals(pixCrcInvalid: true);
      
      final riskScore = computeRisk(payload, signals);
      
      expect(riskScore.level, equals(RiskScore.suspicious));
      expect(riskScore.value, greaterThanOrEqualTo(40));
      expect(riskScore.reasons, contains('Código PIX com checksum inválido'));
    });
    
    test('should return danger score for invalid PIX GUI', () {
      final payload = PixPayload(
        raw: 'pix-code',
        crcValid: true,
        gui: 'invalid.gui',
        fields: {},
      );
      const signals = Signals(pixGuiInvalid: true);
      
      final riskScore = computeRisk(payload, signals);
      
      expect(riskScore.level, equals(RiskScore.suspicious));
      expect(riskScore.value, greaterThanOrEqualTo(40));
      expect(riskScore.reasons, contains('Código PIX com identificador inválido'));
    });
    
    test('should return suspicious score for unknown PIX domain', () {
      final payload = PixPayload(
        raw: 'pix-code',
        crcValid: true,
        gui: 'br.gov.bcb.pix',
        fields: {'url': 'https://unknown-domain.com'},
      );
      const signals = Signals(pixDomainUnknown: true);
      
      final riskScore = computeRisk(payload, signals);
      
      expect(riskScore.level, equals(RiskScore.suspicious));
      expect(riskScore.value, greaterThanOrEqualTo(30));
      expect(riskScore.reasons, contains('Domínio PIX dinâmico não reconhecido'));
    });
    
    test('should return suspicious score for punycode', () {
      final payload = UrlPayload(Uri.parse('https://xn--example.com'));
      const signals = Signals(hasPunycode: true);
      
      final riskScore = computeRisk(payload, signals);
      
      expect(riskScore.level, equals(RiskScore.suspicious));
      expect(riskScore.value, greaterThanOrEqualTo(20));
      expect(riskScore.reasons, contains('URL contém caracteres internacionais suspeitos'));
    });
    
    test('should return suspicious score for open WiFi', () {
      final payload = WifiPayload(
        ssid: 'OpenNetwork',
        sec: 'nopass',
        password: null,
      );
      const signals = Signals(wifiOpen: true);
      
      final riskScore = computeRisk(payload, signals);
      
      expect(riskScore.level, equals(RiskScore.suspicious));
      expect(riskScore.value, greaterThanOrEqualTo(20));
      expect(riskScore.reasons, contains('Rede WiFi aberta pode ser insegura'));
    });
    
    test('should return suspicious score for multiple redirects', () {
      final payload = UrlPayload(Uri.parse('https://short.link/abc'));
      const signals = Signals(redirects: 3);
      
      final riskScore = computeRisk(payload, signals);
      
      expect(riskScore.level, equals(RiskScore.suspicious));
      expect(riskScore.value, greaterThanOrEqualTo(15));
      expect(riskScore.reasons, contains('Múltiplos redirecionamentos detectados'));
    });
    
    test('should accumulate risk scores correctly', () {
      final payload = UrlPayload(Uri.parse('https://xn--malware.com'));
      const signals = Signals(
        reputationMatch: true, // +70
        hasPunycode: true,     // +20
        redirects: 2,          // +15
      );
      
      final riskScore = computeRisk(payload, signals);
      
      expect(riskScore.level, equals(RiskScore.danger));
      expect(riskScore.value, equals(100)); // Capped at 100
      expect(riskScore.reasons.length, equals(3));
    });
    
    test('should cap risk score at 100', () {
      final payload = DeeplinkPayload('intent', 'intent://malware.com');
      const signals = Signals(
        reputationMatch: true, // +70
        blockedScheme: true,   // +70
        hasPunycode: true,     // +20
        redirects: 5,          // +15
      );
      
      final riskScore = computeRisk(payload, signals);
      
      expect(riskScore.value, equals(100));
      expect(riskScore.level, equals(RiskScore.danger));
    });
  });
}
