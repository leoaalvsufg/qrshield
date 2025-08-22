/// URL heuristics analysis result
class UrlHeuristicsResult {
  // domínios conhecidos

  const UrlHeuristicsResult({
    required this.isBlockedScheme,
    required this.hasPunycode,
    required this.looksShortener,
  });
  final bool isBlockedScheme; // javascript:, data:, file:, content:
  final bool hasPunycode; // host com xn--
  final bool looksShortener;

  @override
  String toString() =>
      'UrlHeuristicsResult(isBlockedScheme: $isBlockedScheme, '
      'hasPunycode: $hasPunycode, looksShortener: $looksShortener)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UrlHeuristicsResult &&
          runtimeType == other.runtimeType &&
          isBlockedScheme == other.isBlockedScheme &&
          hasPunycode == other.hasPunycode &&
          looksShortener == other.looksShortener;

  @override
  int get hashCode =>
      isBlockedScheme.hashCode ^ hasPunycode.hashCode ^ looksShortener.hashCode;
}

/// Analyzes URL for security heuristics
UrlHeuristicsResult analyzeUrl(Uri url) {
  final scheme = url.scheme.toLowerCase();
  final host = url.host.toLowerCase();

  // Check for blocked schemes
  final blockedSchemes = {
    'javascript',
    'data',
    'file',
    'content',
    'vbscript',
    'about',
  };
  final isBlockedScheme = blockedSchemes.contains(scheme);

  // Check for punycode (internationalized domain names)
  final hasPunycode = host.contains('xn--');

  // Check for known URL shorteners
  final shortenerDomains = {
    'bit.ly',
    'tinyurl.com',
    'short.link',
    'ow.ly',
    't.co',
    'goo.gl',
    'is.gd',
    'buff.ly',
    'adf.ly',
    'bl.ink',
    'lnkd.in',
    'tiny.cc',
    'rb.gy',
    'cutt.ly',
    'short.io',
    'rebrand.ly',
    'clickmeter.com',
    'hyperurl.co',
    'tiny.one',
    'link.ly',
    'smarturl.it',
    'linktr.ee',
    'bio.link',
    'linkin.bio',
    'allmylinks.com',
    'beacons.ai',
    'campsite.bio',
    'flowcode.com',
    'heylink.me',
    'later.com',
    'linkpop.com',
    'linktree.com',
    'milkshake.app',
    'shorby.com',
    'solo.to',
    'taplink.cc',
    'urly.it',
    'zaap.bio',
  };

  final looksShortener =
      shortenerDomains.contains(host) ||
      shortenerDomains.any((domain) => host.endsWith('.$domain'));

  return UrlHeuristicsResult(
    isBlockedScheme: isBlockedScheme,
    hasPunycode: hasPunycode,
    looksShortener: looksShortener,
  );
}

/// Checks if a domain looks suspicious based on various heuristics
bool isDomainSuspicious(String domain) {
  final lowerDomain = domain.toLowerCase();

  // Check for suspicious patterns
  final suspiciousPatterns = [
    // Homograph attacks
    RegExp('[а-я]'), // Cyrillic characters
    RegExp('[αβγδεζηθικλμνξοπρστυφχψω]'), // Greek characters
    // Suspicious character combinations
    RegExp('[0-9]{4,}'), // Long sequences of numbers
    RegExp('[a-z]{20,}'), // Very long sequences of letters
    // Common typosquatting patterns
    RegExp('(goog1e|fac3book|amaz0n|micr0soft|app1e)'),

    // Suspicious TLDs (basic check)
    RegExp(r'\.(tk|ml|ga|cf)$'),
  ];

  return suspiciousPatterns.any((pattern) => pattern.hasMatch(lowerDomain));
}

/// Extracts the effective domain from a URL
String getEffectiveDomain(Uri url) {
  final host = url.host.toLowerCase();

  // Simple effective domain extraction
  // In production, use a proper public suffix list
  final parts = host.split('.');
  if (parts.length >= 2) {
    return '${parts[parts.length - 2]}.${parts[parts.length - 1]}';
  }

  return host;
}
