import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrshield/core/domain/classifier.dart';
import 'package:qrshield/core/domain/payload.dart';
import 'package:qrshield/core/domain/risk_score.dart';
import 'package:qrshield/core/domain/url_heuristics.dart';
import 'package:qrshield/core/services/reputation_service.dart';
import 'package:qrshield/core/services/url_expander.dart';
import 'package:qrshield/features/settings/controller/settings_controller.dart';

/// Report state
enum ReportStatus {
  analyzing,
  ready,
  error,
}

class ReportState {
  
  const ReportState({
    required this.rawPayload,
    this.status = ReportStatus.analyzing,
    this.payload,
    this.riskScore,
    this.signals,
    this.errorMessage,
    this.isAnalyzing = false,
  });
  final ReportStatus status;
  final String rawPayload;
  final Payload? payload;
  final RiskScore? riskScore;
  final Signals? signals;
  final String? errorMessage;
  final bool isAnalyzing;
  
  ReportState copyWith({
    ReportStatus? status,
    String? rawPayload,
    Payload? payload,
    RiskScore? riskScore,
    Signals? signals,
    String? errorMessage,
    bool? isAnalyzing,
  }) {
    return ReportState(
      rawPayload: rawPayload ?? this.rawPayload,
      status: status ?? this.status,
      payload: payload ?? this.payload,
      riskScore: riskScore ?? this.riskScore,
      signals: signals ?? this.signals,
      errorMessage: errorMessage ?? this.errorMessage,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
    );
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          rawPayload == other.rawPayload &&
          payload == other.payload &&
          riskScore == other.riskScore &&
          signals == other.signals &&
          errorMessage == other.errorMessage &&
          isAnalyzing == other.isAnalyzing;
  
  @override
  int get hashCode =>
      status.hashCode ^
      rawPayload.hashCode ^
      payload.hashCode ^
      riskScore.hashCode ^
      signals.hashCode ^
      errorMessage.hashCode ^
      isAnalyzing.hashCode;
}

/// Report controller
class ReportController extends StateNotifier<ReportState> {
  
  ReportController(
    String rawPayload,
    this._reputationService,
    this._urlExpander,
    this._ref,
  ) : super(ReportState(rawPayload: rawPayload)) {
    _analyzePayload();
  }
  final ReputationService _reputationService;
  final UrlExpander _urlExpander;
  final Ref _ref;
  
  /// Analyze the payload
  Future<void> _analyzePayload() async {
    try {
      // Classify the payload
      final payload = classify(state.rawPayload);
      state = state.copyWith(payload: payload);
      
      // Analyze signals
      final signals = await _analyzeSignals(payload);
      
      // Compute risk score
      final riskScore = computeRisk(payload, signals);
      
      state = state.copyWith(
        status: ReportStatus.ready,
        signals: signals,
        riskScore: riskScore,
      );
    } catch (e) {
      state = state.copyWith(
        status: ReportStatus.error,
        errorMessage: 'Erro ao analisar payload: $e',
      );
    }
  }
  
  /// Analyze signals for the payload
  Future<Signals> _analyzeSignals(Payload payload) async {
    final settings = _ref.read(settingsControllerProvider);
    
    var reputationMatch = false;
    var redirects = 0;
    var hasPunycode = false;
    var blockedScheme = false;
    var wifiOpen = false;
    var pixCrcInvalid = false;
    var pixGuiInvalid = false;
    var pixDomainUnknown = false;
    
    // URL-specific analysis
    if (payload is UrlPayload) {
      final heuristics = analyzeUrl(payload.url);
      hasPunycode = heuristics.hasPunycode;
      blockedScheme = heuristics.isBlockedScheme;
      
      // Reputation check (if enabled)
      if (settings.enableReputationCheck) {
        try {
          reputationMatch = await _reputationService.checkUrl(payload.url);
        } catch (e) {
          // Continue without reputation check on error
        }
      }
      
      // URL expansion (if enabled and is shortener)
      if (settings.enableUrlExpansion && heuristics.looksShortener) {
        try {
          final expandResult = await _urlExpander.expand(payload.url);
          redirects = expandResult.redirects;
        } catch (e) {
          // Continue without expansion on error
        }
      }
    }
    
    // Deep link analysis
    if (payload is DeeplinkPayload) {
      // Deep links are inherently more risky
      // Additional analysis could be added here
    }
    
    // PIX analysis
    if (payload is PixPayload) {
      pixCrcInvalid = !payload.crcValid;
      pixGuiInvalid = payload.gui != 'br.gov.bcb.pix';
      
      // Check for unknown domains in dynamic PIX
      if (payload.fields.containsKey('url')) {
        final url = payload.fields['url']!;
        try {
          final uri = Uri.parse(url);
          final domain = uri.host.toLowerCase();
          
          // Simple allowlist of known PIX providers
          final knownProviders = {
            'pix.bcb.gov.br',
            'dict.pix.bcb.gov.br',
            // Add more known providers as needed
          };
          
          pixDomainUnknown = !knownProviders.any((provider) => 
              domain == provider || domain.endsWith('.$provider'),);
        } catch (e) {
          pixDomainUnknown = true;
        }
      }
    }
    
    // WiFi analysis
    if (payload is WifiPayload) {
      wifiOpen = payload.sec.toLowerCase() == 'nopass' || 
                 payload.sec.toLowerCase() == 'none' ||
                 payload.password == null;
    }
    
    return Signals(
      reputationMatch: reputationMatch,
      redirects: redirects,
      hasPunycode: hasPunycode,
      blockedScheme: blockedScheme,
      wifiOpen: wifiOpen,
      pixCrcInvalid: pixCrcInvalid,
      pixGuiInvalid: pixGuiInvalid,
      pixDomainUnknown: pixDomainUnknown,
    );
  }
  
  /// Perform additional analysis (user-triggered)
  Future<void> analyzeNow() async {
    if (state.isAnalyzing) return;
    
    state = state.copyWith(isAnalyzing: true);
    
    try {
      if (state.payload != null) {
        final signals = await _analyzeSignals(state.payload!);
        final riskScore = computeRisk(state.payload!, signals);
        
        state = state.copyWith(
          signals: signals,
          riskScore: riskScore,
          isAnalyzing: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isAnalyzing: false,
        errorMessage: 'Erro na análise adicional: $e',
      );
    }
  }
  
  /// Copy payload to clipboard
  Future<void> copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: state.rawPayload));
  }
  
  /// Get warnings for interstitial dialog
  List<String> getWarnings() {
    if (state.riskScore == null) return [];
    return state.riskScore!.reasons;
  }
}

/// Report controller provider
final reportControllerProvider = StateNotifierProvider.family<ReportController, ReportState, String>(
  (ref, rawPayload) {
    final reputationService = ref.read(reputationServiceProvider);
    final urlExpander = ref.read(urlExpanderProvider);
    
    return ReportController(
      rawPayload,
      reputationService,
      urlExpander,
      ref,
    );
  },
);

/// Reputation service provider
final reputationServiceProvider = Provider<ReputationService>((ref) {
  // TODO(secure): Replace with production service
  return StubReputationService();
});

/// URL expander provider
final urlExpanderProvider = Provider<UrlExpander>((ref) {
  // TODO(secure): Replace with production service
  return StubUrlExpander();
});
