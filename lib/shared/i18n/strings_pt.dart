/// Portuguese strings for the app
class StringsPt {
  // App
  static const String appName = 'QRShield';
  static const String appDescription = 'Analise QR Codes com segurança antes de abrir';
  
  // Home
  static const String homeTitle = 'QRShield';
  static const String homeSubtitle = 'Proteja-se contra golpes e links maliciosos';
  static const String scanNow = 'Escanear agora';
  static const String howItWorks = 'Como funciona';
  static const String securityTips = 'Dicas de segurança';
  
  // Security tips
  static const String tipNeverAutoOpen = 'Nunca abra links automaticamente';
  static const String tipNeverAutoOpenDesc = 'Sempre analise o destino antes de abrir qualquer QR Code.';
  static const String tipVerifySource = 'Verifique a origem';
  static const String tipVerifySourceDesc = 'Confirme se o QR Code vem de uma fonte confiável.';
  static const String tipExamineSuspicious = 'Examine URLs suspeitas';
  static const String tipExamineSuspiciousDesc = 'Desconfie de links encurtados ou domínios estranhos.';
  
  // Scan
  static const String scanTitle = 'Escanear QR Code';
  static const String scanReading = 'Lendo...';
  static const String scanDetected = 'QR Code detectado';
  static const String scanError = 'Erro de câmera';
  static const String scanPermissionDenied = 'Permissão de câmera negada';
  static const String scanSwitchCamera = 'Trocar câmera';
  static const String scanPause = 'Pausar';
  static const String scanResume = 'Retomar';
  
  // Report
  static const String reportTitle = 'Análise de Segurança';
  static const String reportWhatWeFound = 'O que encontramos';
  static const String reportWhyRisky = 'Por que isso é arriscado?';
  static const String reportWhatCanIDo = 'O que posso fazer agora?';
  static const String reportCopy = 'Copiar';
  static const String reportOpen = 'Abrir assim mesmo';
  static const String reportDenounce = 'Denunciar';
  static const String reportCopied = 'Copiado para a área de transferência';
  
  // Risk levels
  static const String riskSafe = 'Seguro';
  static const String riskSuspicious = 'Suspeito';
  static const String riskDangerous = 'Perigoso';
  
  // Risk reasons
  static const String riskReputationMatch = 'Detectado em base de dados de ameaças';
  static const String riskBlockedScheme = 'Esquema de URL perigoso detectado';
  static const String riskDeepLink = 'Link de aplicativo pode abrir apps maliciosos';
  static const String riskPixCrcInvalid = 'Código PIX com checksum inválido';
  static const String riskPixGuiInvalid = 'Código PIX com identificador inválido';
  static const String riskPixDomainUnknown = 'Domínio PIX dinâmico não reconhecido';
  static const String riskPunycode = 'URL contém caracteres internacionais suspeitos';
  static const String riskWifiOpen = 'Rede WiFi aberta pode ser insegura';
  static const String riskMultipleRedirects = 'Múltiplos redirecionamentos detectados';
  static const String riskNoIndicators = 'Nenhum indicador de risco detectado';
  
  // Payload types
  static const String payloadUrl = 'Link da Web';
  static const String payloadDeeplink = 'Link de Aplicativo';
  static const String payloadPix = 'Pagamento PIX';
  static const String payloadWifi = 'Rede WiFi';
  static const String payloadSms = 'Mensagem SMS';
  static const String payloadTel = 'Número de Telefone';
  static const String payloadEmail = 'Email';
  static const String payloadGeo = 'Localização';
  static const String payloadVcard = 'Cartão de Visita';
  static const String payloadText = 'Texto';
  
  // URL info
  static const String urlScheme = 'Esquema';
  static const String urlDomain = 'Domínio';
  static const String urlPath = 'Caminho';
  static const String urlParams = 'Parâmetros';
  static const String urlRedirects = 'Redirecionamentos';
  static const String urlPunycode = 'Punycode';
  static const String urlShortener = 'Encurtador';
  static const String urlDetected = 'Detectado';
  static const String urlYes = 'Sim';
  
  // PIX info
  static const String pixChecksum = 'Checksum';
  static const String pixIdentifier = 'Identificador';
  static const String pixValid = 'Válido';
  static const String pixInvalid = 'Inválido';
  static const String pixNotFound = 'Não encontrado';
  
  // WiFi info
  static const String wifiNetworkName = 'Nome da Rede';
  static const String wifiSecurity = 'Segurança';
  static const String wifiVisibility = 'Visibilidade';
  static const String wifiHiddenNetwork = 'Rede oculta';
  
  // Settings
  static const String settingsTitle = 'Configurações';
  static const String settingsTheme = 'Tema';
  static const String settingsThemeLight = 'Claro';
  static const String settingsThemeDark = 'Escuro';
  static const String settingsThemeSystem = 'Sistema';
  static const String settingsAbout = 'Sobre';
  static const String settingsPrivacy = 'Privacidade';
  static const String settingsVersion = 'Versão';
  
  // Interstitial
  static const String interstitialTitle = 'Atenção: Link potencialmente perigoso';
  static const String interstitialDeepLinkTitle = 'Atenção: Link de aplicativo';
  static const String interstitialDestination = 'Destino:';
  static const String interstitialRedirects = 'Redirecionamentos:';
  static const String interstitialReasonsTitle = 'Motivos para cautela:';
  static const String interstitialAcknowledge = 'Entendo os riscos e quero prosseguir mesmo assim';
  static const String interstitialDisclaimer = 'Ao marcar esta opção, você assume total responsabilidade pelos riscos de segurança.';
  static const String interstitialCancel = 'Cancelar';
  static const String interstitialProceed = 'Abrir assim mesmo';
  
  // Errors
  static const String errorPageNotFound = 'Página não encontrada';
  static const String errorPageNotFoundDesc = 'A página não existe.';
  static const String errorBackToHome = 'Voltar ao início';
  static const String errorOpeningLink = 'Erro ao abrir link:';
  static const String errorCameraPermission = 'Permissão de câmera necessária';
  static const String errorCameraNotAvailable = 'Câmera não disponível';
  
  // Actions
  static const String actionCopy = 'Copiar';
  static const String actionOpen = 'Abrir';
  static const String actionCancel = 'Cancelar';
  static const String actionOk = 'OK';
  static const String actionSettings = 'Configurações';
  static const String actionBack = 'Voltar';
  static const String actionAnalyze = 'Analisar agora';
}
