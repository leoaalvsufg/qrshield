import 'package:http/http.dart' as http;

/// Result of URL expansion
class UrlExpandResult {
  final Uri finalUrl;
  final int redirects;
  final List<Uri> redirectChain;
  
  UrlExpandResult(this.finalUrl, this.redirects, [this.redirectChain = const []]);
  
  @override
  String toString() => 
      'UrlExpandResult(finalUrl: $finalUrl, redirects: $redirects, '
      'redirectChain: $redirectChain)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UrlExpandResult &&
          runtimeType == other.runtimeType &&
          finalUrl == other.finalUrl &&
          redirects == other.redirects &&
          _listEquals(redirectChain, other.redirectChain);
  
  @override
  int get hashCode => 
      finalUrl.hashCode ^ redirects.hashCode ^ redirectChain.hashCode;
  
  bool _listEquals(List<Uri> a, List<Uri> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Abstract service for expanding shortened URLs
abstract class UrlExpander {
  /// Expands a URL following redirects to find the final destination
  Future<UrlExpandResult> expand(Uri url);
}

/// Stub implementation for URL expander
/// TODO(secure): Implement actual HTTP redirect following
class StubUrlExpander implements UrlExpander {
  @override
  Future<UrlExpandResult> expand(Uri url) async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // For stub, just return the original URL with no redirects
    return UrlExpandResult(url, 0, [url]);
  }
}

/// Production implementation that follows HTTP redirects
class HttpUrlExpander implements UrlExpander {
  final http.Client _client;
  final int maxRedirects;
  final Duration timeout;
  
  HttpUrlExpander({
    http.Client? client,
    this.maxRedirects = 10,
    this.timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client();
  
  @override
  Future<UrlExpandResult> expand(Uri url) async {
    final redirectChain = <Uri>[url];
    Uri currentUrl = url;
    int redirectCount = 0;
    
    try {
      while (redirectCount < maxRedirects) {
        final request = http.Request('HEAD', currentUrl);
        request.followRedirects = false;
        
        final streamedResponse = await _client.send(request).timeout(timeout);
        final response = await http.Response.fromStream(streamedResponse);
        
        // Check if this is a redirect
        if (response.statusCode >= 300 && response.statusCode < 400) {
          final location = response.headers['location'];
          if (location == null) break;
          
          // Resolve relative URLs
          final nextUrl = currentUrl.resolve(location);
          redirectChain.add(nextUrl);
          currentUrl = nextUrl;
          redirectCount++;
        } else {
          // Not a redirect, we've reached the final URL
          break;
        }
      }
      
      return UrlExpandResult(currentUrl, redirectCount, redirectChain);
    } catch (e) {
      // On error, return original URL
      return UrlExpandResult(url, 0, [url]);
    }
  }
  
  /// Dispose of the HTTP client
  void dispose() {
    _client.close();
  }
}

/// Specialized expander for known URL shorteners
class ShortenerAwareExpander implements UrlExpander {
  final HttpUrlExpander _httpExpander;
  
  ShortenerAwareExpander({HttpUrlExpander? httpExpander})
      : _httpExpander = httpExpander ?? HttpUrlExpander();
  
  @override
  Future<UrlExpandResult> expand(Uri url) async {
    // Check if this is a known shortener
    if (_isKnownShortener(url.host)) {
      // Use HTTP expansion for shorteners
      return await _httpExpander.expand(url);
    }
    
    // For non-shorteners, return as-is
    return UrlExpandResult(url, 0, [url]);
  }
  
  bool _isKnownShortener(String host) {
    final shorteners = {
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
    };
    
    return shorteners.contains(host.toLowerCase());
  }
  
  void dispose() {
    _httpExpander.dispose();
  }
}
