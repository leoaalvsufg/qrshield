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

  // Financial phishing detection: +50 (high risk)
  if (payload is UrlPayload) {
    final url = payload.url.toString().toLowerCase();
    final host = payload.url.host.toLowerCase();

    // Check for financial service impersonation (expanded list)
    final financialKeywords = [
      // Bancos brasileiros
      'paypal', 'banco', 'bank', 'itau', 'bradesco', 'santander',
      'caixa', 'nubank', 'inter', 'c6bank', 'original', 'safra',
      'sicoob', 'sicredi', 'bb', 'banrisul', 'banestes',

      // Fintechs e carteiras digitais
      'picpay', 'mercadopago', 'pagseguro', 'stone', 'cielo',
      'getnet', 'rede', 'adyen', 'stripe', 'square', 'wise',

      // Criptomoedas
      'binance', 'coinbase', 'kraken', 'bitfinex', 'huobi',
      'mercadobitcoin', 'foxbit', 'bitcointrade', 'novadax',
      'crypto', 'bitcoin', 'ethereum', 'blockchain', 'wallet',

      // Termos gerais
      'credit', 'debit', 'card', 'login', 'secure', 'verify',
      'account', 'payment', 'pix', 'transfer', 'money',
      'cartao', 'credito', 'debito', 'conta', 'pagamento',
    ];

    final suspiciousTlds = [
      '.ru', '.tk', '.ml', '.ga', '.cf', '.pw', '.top', '.click',
      '.download', '.stream', '.science', '.racing', '.review',
      '.bid', '.win', '.party', '.date', '.faith', '.cricket',
    ];

    // Check if contains financial keywords but suspicious TLD
    final hasFinancialKeyword = financialKeywords.any((keyword) =>
      host.contains(keyword) || url.contains(keyword),);
    final hasSuspiciousTld = suspiciousTlds.any(host.endsWith);

    if (hasFinancialKeyword && hasSuspiciousTld) {
      score += 50;
      reasons.add('Possível phishing de serviço financeiro');
    }

    // Check for subdomain impersonation (e.g., paypal.com.fake.ru)
    if (hasFinancialKeyword && host.split('.').length > 3) {
      final parts = host.split('.');
      for (var i = 0; i < parts.length - 1; i++) {
        if (financialKeywords.contains(parts[i]) &&
            i < parts.length - 2) { // Not the main domain
          score += 40;
          reasons.add('Subdomínio suspeito imitando serviço financeiro');
          break;
        }
      }
    }

    // HTTP for financial services (should be HTTPS)
    if (hasFinancialKeyword && payload.url.scheme == 'http') {
      score += 30;
      reasons.add('Conexão insegura (HTTP) para serviço financeiro');
    }

    // Suspicious path patterns for financial sites
    final path = payload.url.path.toLowerCase();
    if (hasFinancialKeyword && (
        path.contains('verify') ||
        path.contains('confirm') ||
        path.contains('update') ||
        path.contains('suspend') ||
        path.contains('security'))) {
      score += 25;
      reasons.add('Padrão de URL suspeito para verificação/atualização');
    }
  }

  // Social media and password reset detection (offline patterns)
  if (payload is UrlPayload) {
    final url = payload.url.toString().toLowerCase();
    final host = payload.url.host.toLowerCase();
    final path = payload.url.path.toLowerCase();

    // Social media platforms (legitimate domains)
    final socialMediaDomains = [
      'facebook.com', 'instagram.com', 'twitter.com', 'x.com',
      'linkedin.com', 'tiktok.com', 'youtube.com', 'whatsapp.com',
      'telegram.org', 'discord.com', 'snapchat.com', 'pinterest.com',
      'reddit.com', 'tumblr.com', 'twitch.tv', 'vk.com',
    ];

    // Social media keywords for impersonation detection
    final socialKeywords = [
      'facebook', 'instagram', 'twitter', 'linkedin', 'tiktok',
      'youtube', 'whatsapp', 'telegram', 'discord', 'snapchat',
      'pinterest', 'reddit', 'tumblr', 'twitch', 'social',
    ];

    // Password reset patterns
    final passwordResetPatterns = [
      'reset', 'password', 'forgot', 'recover', 'change-password',
      'new-password', 'reset-password', 'password-reset', 'senha',
      'redefinir', 'recuperar', 'alterar-senha', 'nova-senha',
    ];

    // Check for social media impersonation
    final hasSocialKeyword = socialKeywords.any((keyword) =>
      host.contains(keyword) || url.contains(keyword),);
    final isLegitSocial = socialMediaDomains.any((domain) =>
      host == domain || host.endsWith('.$domain'),);

    if (hasSocialKeyword && !isLegitSocial) {
      score += 35;
      reasons.add('Possível imitação de rede social');
    }

    // Check for password reset links (informational, not necessarily dangerous)
    final hasPasswordReset = passwordResetPatterns.any((pattern) =>
      path.contains(pattern) || url.contains(pattern),);

    if (hasPasswordReset) {
      score += 15;
      reasons.add('Link de redefinição de senha detectado - verifique a origem');
    }

    // Social media + suspicious TLD combination
    final suspiciousTlds = [
      '.ru', '.tk', '.ml', '.ga', '.cf', '.pw', '.top', '.click',
      '.download', '.stream', '.science', '.racing', '.review',
      '.bid', '.win', '.party', '.date', '.faith', '.cricket',
    ];

    final hasSuspiciousTld = suspiciousTlds.any(host.endsWith);

    if (hasSocialKeyword && hasSuspiciousTld) {
      score += 45;
      reasons.add('Imitação de rede social com domínio suspeito');
    }

    // Check for social login phishing patterns
    final socialLoginPatterns = [
      'login', 'signin', 'auth', 'oauth', 'connect', 'authorize',
      'entrar', 'conectar', 'autorizar',
    ];

    final hasSocialLogin = socialLoginPatterns.any(path.contains);

    if (hasSocialKeyword && hasSocialLogin && !isLegitSocial) {
      score += 40;
      reasons.add('Possível phishing de login de rede social');
    }

    // Legitimate social media access (informational)
    if (isLegitSocial) {
      // Don't add score, but inform user
      reasons.add('Acesso a rede social detectado - verifique se é esperado');
    }
  }

  // Advanced URL analysis (IP addresses, ports, suspicious patterns)
  if (payload is UrlPayload) {
    final host = payload.url.host.toLowerCase();
    final port = payload.url.port;
    final path = payload.url.path.toLowerCase();

    // Check for direct IP addresses (suspicious)
    final ipPattern = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$');
    if (ipPattern.hasMatch(host)) {
      score += 35;
      reasons.add('Acesso direto por IP detectado - pode ser suspeito');
    }

    // Check for non-standard ports
    final suspiciousPorts = [8080, 3000, 8888, 8000, 9000, 8443, 8090];
    if (port != 80 && port != 443 && suspiciousPorts.contains(port)) {
      score += 20;
      reasons.add('Porta não padrão detectada ($port) - verifique a origem');
    }

    // Check for suspicious path patterns
    final dangerousPaths = [
      'download', 'install', 'setup', 'update.exe', 'malware',
      'virus', 'trojan', 'backdoor', 'exploit', 'hack',
      'admin', 'administrator', 'root', 'system',
    ];

    final hasDangerousPath = dangerousPaths.any(path.contains);
    if (hasDangerousPath) {
      score += 30;
      reasons.add('Caminho suspeito detectado na URL');
    }

    // Check for urgency/pressure patterns
    final urgencyPatterns = [
      'urgent', 'emergency', 'immediate', 'expire', 'suspend',
      'block', 'freeze', 'urgent', 'action-required', 'verify-now',
      'urgente', 'emergencia', 'imediato', 'expira', 'suspender',
      'bloquear', 'congelar', 'acao-necessaria', 'verificar-agora',
    ];

    final hasUrgencyPattern = urgencyPatterns.any((pattern) =>
      path.contains(pattern) || payload.url.query.toLowerCase().contains(pattern),);

    if (hasUrgencyPattern) {
      score += 25;
      reasons.add('Padrão de urgência detectado - possível engenharia social');
    }

    // Check for long subdomains (suspicious)
    final parts = host.split('.');
    if (parts.length > 4) {
      score += 20;
      reasons.add('Subdomínio muito longo detectado');
    }

    // Check for suspicious query parameters
    final query = payload.url.query.toLowerCase();
    final suspiciousParams = [
      'redirect', 'return', 'callback', 'next', 'continue',
      'goto', 'url', 'link', 'ref', 'referer',
    ];

    final hasSuspiciousParam = suspiciousParams.any(query.contains);
    if (hasSuspiciousParam && query.contains('http')) {
      score += 25;
      reasons.add('Parâmetro de redirecionamento suspeito detectado');
    }
  }

  // URL Shorteners and Link Analysis
  if (payload is UrlPayload) {
    final host = payload.url.host.toLowerCase();
    final path = payload.url.path.toLowerCase();

    // Known URL shorteners (legitimate but require caution)
    final knownShorteners = [
      'bit.ly', 'tinyurl.com', 't.co', 'goo.gl', 'ow.ly',
      'is.gd', 'buff.ly', 'short.link', 'rebrand.ly', 'cutt.ly',
      'tiny.cc', 'lnkd.in', 'youtu.be', 'amzn.to', 'fb.me',
    ];

    final isKnownShortener = knownShorteners.any((shortener) =>
      host == shortener || host.endsWith('.$shortener'),);

    if (isKnownShortener) {
      score += 10; // Low risk but informational
      reasons.add('🔗 Link encurtado detectado - verifique quem enviou antes de clicar');
    }

    // Legitimate government sites with security warnings
    final govDomains = [
      'gov.br', 'receita.fazenda.gov.br', 'detran.gov.br',
      'inss.gov.br', 'caixa.gov.br', 'bcb.gov.br',
      'serpro.gov.br', 'dataprev.gov.br',
    ];

    final isGovSite = govDomains.any((domain) =>
      host == domain || host.endsWith('.$domain'),);

    if (isGovSite) {
      // Check for sensitive operations
      final sensitiveGovPaths = [
        'senha', 'password', 'login', 'acesso', 'cadastro',
        'dados', 'cpf', 'rg', 'documento', 'certidao',
      ];

      final hasSensitivePath = sensitiveGovPaths.any(path.contains);

      if (hasSensitivePath) {
        reasons.add('🏛️ Site governamental LEGÍTIMO - Para segurança: faça apenas em casa, com pessoa de confiança, nunca por orientação telefônica');
      } else {
        reasons.add('🏛️ Site governamental oficial detectado');
      }
    }

    // Legitimate banking sites with security warnings
    final legitimateBanks = [
      'itau.com.br', 'bradesco.com.br', 'santander.com.br',
      'bb.com.br', 'caixa.gov.br', 'banrisul.com.br',
      'nubank.com.br', 'inter.co', 'c6bank.com.br',
      'original.com.br', 'safra.com.br',
    ];

    final isLegitBank = legitimateBanks.any((bank) =>
      host == bank || host.endsWith('.$bank'),);

    if (isLegitBank) {
      final bankingPaths = [
        'login', 'acesso', 'senha', 'cartao', 'conta',
        'transferencia', 'pix', 'pagamento',
      ];

      final hasBankingPath = bankingPaths.any(path.contains);

      if (hasBankingPath) {
        reasons.add('🏦 Banco LEGÍTIMO - ATENÇÃO: Nunca acesse por links de terceiros, sempre digite o endereço manualmente');
      } else {
        reasons.add('🏦 Site bancário oficial detectado');
      }
    }

    // Legitimate e-commerce with warnings
    final legitimateEcommerce = [
      'amazon.com.br', 'mercadolivre.com.br', 'americanas.com.br',
      'magazineluiza.com.br', 'casasbahia.com.br', 'extra.com.br',
      'submarino.com.br', 'shopee.com.br', 'olx.com.br',
    ];

    final isLegitEcommerce = legitimateEcommerce.any((site) =>
      host == site || host.endsWith('.$site'),);

    if (isLegitEcommerce) {
      final paymentPaths = [
        'pagamento', 'checkout', 'finalizar', 'cartao',
        'payment', 'buy', 'purchase',
      ];

      final hasPaymentPath = paymentPaths.any(path.contains);

      if (hasPaymentPath) {
        reasons.add('🛒 Loja LEGÍTIMA - Verifique sempre a URL completa e use cartões com limite baixo');
      } else {
        reasons.add('🛒 Site de e-commerce oficial detectado');
      }
    }

    // Social media legitimate sites with warnings
    final legitimateSocial = [
      'facebook.com', 'instagram.com', 'twitter.com', 'x.com',
      'linkedin.com', 'tiktok.com', 'youtube.com', 'whatsapp.com',
      'web.whatsapp.com', 'telegram.org', 'discord.com',
    ];

    final isLegitSocial = legitimateSocial.any((social) =>
      host == social || host.endsWith('.$social'),);

    if (isLegitSocial) {
      final socialPaths = [
        'login', 'signin', 'auth', 'password', 'settings',
        'security', 'privacy',
      ];

      final hasSocialPath = socialPaths.any(path.contains);

      if (hasSocialPath) {
        reasons.add('📱 Rede social LEGÍTIMA - Cuidado com links suspeitos e sempre verifique a URL');
      } else {
        reasons.add('📱 Rede social oficial detectada');
      }
    }

    // Cryptocurrency exchanges (legitimate but high risk)
    final legitimateCrypto = [
      'binance.com', 'coinbase.com', 'kraken.com',
      'mercadobitcoin.com.br', 'foxbit.com.br', 'bitcointrade.com.br',
      'novadax.com.br', 'bitso.com',
    ];

    final isLegitCrypto = legitimateCrypto.any((crypto) =>
      host == crypto || host.endsWith('.$crypto'),);

    if (isLegitCrypto) {
      score += 5; // Informational - crypto is inherently risky
      reasons.add('₿ Exchange de criptomoedas LEGÍTIMA - ALTO RISCO: Nunca compartilhe chaves privadas, use autenticação 2FA');
    }
  }

  // E-commerce and popular services analysis
  if (payload is UrlPayload) {
    final url = payload.url.toString().toLowerCase();
    final host = payload.url.host.toLowerCase();

    // E-commerce platforms
    final ecommerceKeywords = [
      'amazon', 'mercadolivre', 'americanas', 'magazineluiza',
      'casasbahia', 'extra', 'submarino', 'shopee', 'aliexpress',
      'ebay', 'olx', 'enjoei', 'vinted', 'shopify', 'woocommerce',
    ];

    // Government services
    final govKeywords = [
      'gov.br', 'receita', 'detran', 'inss', 'caixa.gov',
      'bcb.gov', 'bb.gov', 'serpro', 'dataprev', 'gov',
      'prefeitura', 'municipal', 'estadual', 'federal',
    ];

    // Popular services
    final serviceKeywords = [
      'google', 'microsoft', 'apple', 'netflix', 'spotify',
      'uber', '99', 'ifood', 'rappi', 'correios', 'sedex',
    ];

    final suspiciousTlds = [
      '.ru', '.tk', '.ml', '.ga', '.cf', '.pw', '.top', '.click',
      '.download', '.stream', '.science', '.racing', '.review',
      '.bid', '.win', '.party', '.date', '.faith', '.cricket',
    ];

    // Check for e-commerce impersonation
    final hasEcommerceKeyword = ecommerceKeywords.any((keyword) =>
      host.contains(keyword) || url.contains(keyword),);
    final hasSuspiciousTld = suspiciousTlds.any(host.endsWith);

    if (hasEcommerceKeyword && hasSuspiciousTld) {
      score += 40;
      reasons.add('Possível imitação de loja online');
    }

    // Check for government service impersonation
    final hasGovKeyword = govKeywords.any((keyword) =>
      host.contains(keyword) || url.contains(keyword),);

    if (hasGovKeyword && !host.endsWith('.gov.br') && !host.endsWith('.gov')) {
      score += 45;
      reasons.add('Possível imitação de serviço governamental');
    }

    // Check for popular service impersonation
    final hasServiceKeyword = serviceKeywords.any((keyword) =>
      host.contains(keyword) || url.contains(keyword),);

    if (hasServiceKeyword && hasSuspiciousTld) {
      score += 35;
      reasons.add('Possível imitação de serviço popular');
    }

    // Check for typosquatting (common misspellings)
    final typosquattingPatterns = [
      'gooogle', 'microsooft', 'paypaI', 'amazom', 'facebok',
      'instagramm', 'whatsaap', 'googIe', 'appIe', 'netfIix',
    ];

    final hasTyposquatting = typosquattingPatterns.any(host.contains);
    if (hasTyposquatting) {
      score += 40;
      reasons.add('Possível typosquatting detectado');
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
