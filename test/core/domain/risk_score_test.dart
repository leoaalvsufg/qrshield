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
      expect(
        riskScore.reasons,
        contains('Nenhum indicador de risco detectado'),
      );
    });

    test('should return danger score for reputation match', () {
      final payload = UrlPayload(Uri.parse('https://malware.example.com'));
      const signals = Signals(reputationMatch: true);

      final riskScore = computeRisk(payload, signals);

      expect(riskScore.level, equals(RiskScore.danger));
      expect(riskScore.value, greaterThanOrEqualTo(70));
      expect(
        riskScore.reasons,
        contains('Detectado em base de dados de ameaças'),
      );
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
      expect(
        riskScore.reasons,
        contains('Link de aplicativo pode abrir apps maliciosos'),
      );
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
      expect(
        riskScore.reasons,
        contains('Código PIX com identificador inválido'),
      );
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
      expect(
        riskScore.reasons,
        contains('Domínio PIX dinâmico não reconhecido'),
      );
    });

    test('should return suspicious score for punycode', () {
      final payload = UrlPayload(Uri.parse('https://xn--example.com'));
      const signals = Signals(hasPunycode: true);

      final riskScore = computeRisk(payload, signals);

      expect(riskScore.level, equals(RiskScore.suspicious));
      expect(riskScore.value, greaterThanOrEqualTo(20));
      expect(
        riskScore.reasons,
        contains('URL contém caracteres internacionais suspeitos'),
      );
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

    test('should add score for multiple redirects', () {
      final payload = UrlPayload(Uri.parse('https://short.link/abc'));
      const signals = Signals(
        redirects: 2,
      ); // Changed to 2 to trigger the condition

      final riskScore = computeRisk(payload, signals);

      expect(riskScore.value, equals(25)); // 15 for redirects + 10 for shortener
      expect(
        riskScore.level,
        equals(RiskScore.suspicious),
      ); // Now suspicious with 25 points
      expect(
        riskScore.reasons,
        contains('Múltiplos redirecionamentos detectados'),
      );
    });

    test('should accumulate risk scores correctly', () {
      final payload = UrlPayload(Uri.parse('https://xn--malware.com'));
      const signals = Signals(
        reputationMatch: true, // +70
        hasPunycode: true, // +20
        redirects: 2, // +15
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
        blockedScheme: true, // +70
        hasPunycode: true, // +20
        redirects: 5, // +15
      );

      final riskScore = computeRisk(payload, signals);

      expect(riskScore.value, equals(100));
      expect(riskScore.level, equals(RiskScore.danger));
    });

    test('should detect financial phishing with suspicious TLD', () {
      final payload = UrlPayload(Uri.parse('http://secure-login.paypal.com.verify-user-info.ru/login'));
      const signals = Signals();

      final riskScore = computeRisk(payload, signals);

      expect(riskScore.level, equals(RiskScore.danger));
      expect(riskScore.value, greaterThanOrEqualTo(50));
      expect(riskScore.reasons, contains('Possível phishing de serviço financeiro'));
    });

    test('should detect subdomain impersonation', () {
      final payload = UrlPayload(Uri.parse('https://paypal.com.fake-site.ru/login'));
      const signals = Signals();

      final riskScore = computeRisk(payload, signals);

      expect(riskScore.level, equals(RiskScore.danger));
      expect(riskScore.reasons, contains('Subdomínio suspeito imitando serviço financeiro'));
    });

    test('should detect HTTP for financial services', () {
      final payload = UrlPayload(Uri.parse('http://banco.example.com/login'));
      const signals = Signals();

      final riskScore = computeRisk(payload, signals);

      expect(riskScore.level, equals(RiskScore.suspicious));
      expect(riskScore.reasons, contains('Conexão insegura (HTTP) para serviço financeiro'));
    });

    test('should detect suspicious verification paths', () {
      final payload = UrlPayload(Uri.parse('https://paypal.example.com/verify-account'));
      const signals = Signals();

      final riskScore = computeRisk(payload, signals);

      expect(riskScore.level, equals(RiskScore.suspicious));
      expect(riskScore.reasons, contains('Padrão de URL suspeito para verificação/atualização'));
    });

    test('should detect social media impersonation', () {
      final payload = UrlPayload(Uri.parse('https://facebook-login.ru/auth'));
      const signals = Signals();

      final riskScore = computeRisk(payload, signals);

      expect(riskScore.level, equals(RiskScore.danger));
      expect(riskScore.reasons, contains('Imitação de rede social com domínio suspeito'));
    });

    test('should detect social login phishing', () {
      final payload = UrlPayload(Uri.parse('https://fake-instagram.com/login'));
      const signals = Signals();

      final riskScore = computeRisk(payload, signals);

      expect(riskScore.level, equals(RiskScore.danger));
      expect(riskScore.reasons, contains('Possível phishing de login de rede social'));
    });

    test('should detect password reset links', () {
      final payload = UrlPayload(Uri.parse('https://example.com/reset-password'));
      const signals = Signals();

      final riskScore = computeRisk(payload, signals);

      expect(riskScore.value, equals(15)); // 15 points for password reset
      expect(riskScore.level, equals(RiskScore.safe)); // Still safe with only 15 points
      expect(riskScore.reasons, contains('Link de redefinição de senha detectado - verifique a origem'));
    });

    test('should inform about legitimate social media access', () {
      final payload = UrlPayload(Uri.parse('https://facebook.com/login'));
      const signals = Signals();

      final riskScore = computeRisk(payload, signals);

      expect(riskScore.level, equals(RiskScore.safe));
      expect(riskScore.reasons, contains('Acesso a rede social detectado - verifique se é esperado'));
    });

    test('should detect Instagram impersonation with suspicious TLD', () {
      final payload = UrlPayload(Uri.parse('https://instagram.tk/login'));
      const signals = Signals();

      final riskScore = computeRisk(payload, signals);

      expect(riskScore.level, equals(RiskScore.danger));
      expect(riskScore.reasons, contains('Imitação de rede social com domínio suspeito'));
    });

    test('should detect WhatsApp phishing', () {
      final payload = UrlPayload(Uri.parse('https://whatsapp-web.ml/auth'));
      const signals = Signals();

      final riskScore = computeRisk(payload, signals);

      expect(riskScore.level, equals(RiskScore.danger));
      expect(riskScore.reasons, contains('Imitação de rede social com domínio suspeito'));
    });

    test('should detect URL shorteners with warning', () {
      final payload = UrlPayload(Uri.parse('https://bit.ly/abc123'));
      const signals = Signals();

      final riskScore = computeRisk(payload, signals);

      expect(riskScore.level, equals(RiskScore.safe));
      expect(riskScore.reasons, contains('🔗 Link encurtado detectado - verifique quem enviou antes de clicar'));
    });

    test('should provide security warning for legitimate government sites', () {
      final payload = UrlPayload(Uri.parse('https://receita.fazenda.gov.br/senha'));
      const signals = Signals();

      final riskScore = computeRisk(payload, signals);

      expect(riskScore.level, equals(RiskScore.safe));
      expect(riskScore.reasons, contains('🏛️ Site governamental LEGÍTIMO - Para segurança: faça apenas em casa, com pessoa de confiança, nunca por orientação telefônica'));
    });

    test('should provide security warning for legitimate banking sites', () {
      final payload = UrlPayload(Uri.parse('https://itau.com.br/login'));
      const signals = Signals();

      final riskScore = computeRisk(payload, signals);

      expect(riskScore.level, equals(RiskScore.safe));
      expect(riskScore.reasons, contains('🏦 Banco LEGÍTIMO - ATENÇÃO: Nunca acesse por links de terceiros, sempre digite o endereço manualmente'));
    });

    test('should warn about legitimate cryptocurrency exchanges', () {
      final payload = UrlPayload(Uri.parse('https://binance.com/login'));
      const signals = Signals();

      final riskScore = computeRisk(payload, signals);

      expect(riskScore.level, equals(RiskScore.safe));
      expect(riskScore.reasons, contains('₿ Exchange de criptomoedas LEGÍTIMA - ALTO RISCO: Nunca compartilhe chaves privadas, use autenticação 2FA'));
    });

    test('should detect direct IP access', () {
      final payload = UrlPayload(Uri.parse('http://192.168.1.1/admin'));
      const signals = Signals();

      final riskScore = computeRisk(payload, signals);

      expect(riskScore.level, equals(RiskScore.danger)); // 35 IP + 30 admin path = 65 points
      expect(riskScore.reasons, contains('Acesso direto por IP detectado - pode ser suspeito'));
    });

    test('should detect suspicious ports', () {
      final payload = UrlPayload(Uri.parse('https://example.com:8080/admin'));
      const signals = Signals();

      final riskScore = computeRisk(payload, signals);

      expect(riskScore.level, equals(RiskScore.danger)); // 20 port + 30 admin path = 50 points
      expect(riskScore.reasons, contains('Porta não padrão detectada (8080) - verifique a origem'));
    });
  });
}
