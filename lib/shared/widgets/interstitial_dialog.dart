import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Interstitial dialog that warns users before opening potentially dangerous content
class InterstitialDialog extends StatefulWidget {
  
  const InterstitialDialog({
    super.key,
    required this.title,
    required this.url,
    required this.warnings,
    this.redirects = 0,
    this.onProceed,
    this.onCancel,
  });
  final String title;
  final String url;
  final List<String> warnings;
  final int redirects;
  final VoidCallback? onProceed;
  final VoidCallback? onCancel;
  
  /// Shows the interstitial dialog
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String url,
    required List<String> warnings,
    int redirects = 0,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => InterstitialDialog(
        title: title,
        url: url,
        warnings: warnings,
        redirects: redirects,
        onProceed: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }
  
  @override
  State<InterstitialDialog> createState() => _InterstitialDialogState();
}

class _InterstitialDialogState extends State<InterstitialDialog> {
  bool _acknowledgeRisks = false;
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(
        Icons.warning_amber,
        color: Theme.of(context).colorScheme.error,
        size: 48,
      ),
      title: Text(
        widget.title,
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // URL display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Destino:',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.url,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                  if (widget.redirects > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Redirecionamentos: ${widget.redirects}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Warnings
            if (widget.warnings.isNotEmpty) ...[
              Text(
                'Motivos para cautela:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...widget.warnings.map((warning) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 6,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        warning,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),),
              const SizedBox(height: 16),
            ],
            
            // Risk acknowledgment
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _acknowledgeRisks,
                        onChanged: (value) {
                          setState(() {
                            _acknowledgeRisks = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          'Entendo os riscos e quero prosseguir mesmo assim',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ao marcar esta opção, você assume total responsabilidade pelos riscos de segurança.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _acknowledgeRisks ? widget.onProceed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: const Text('Abrir assim mesmo'),
        ),
      ],
    );
  }
}

/// Utility class for safely launching URLs with interstitial protection
class SafeUrlLauncher {
  /// Launches a URL with interstitial protection
  static Future<bool> launch({
    required BuildContext context,
    required String url,
    required List<String> warnings,
    int redirects = 0,
    String? title,
  }) async {
    // Show interstitial if there are warnings
    if (warnings.isNotEmpty) {
      final shouldProceed = await InterstitialDialog.show(
        context: context,
        title: title ?? 'Atenção: Link potencialmente perigoso',
        url: url,
        warnings: warnings,
        redirects: redirects,
      );
      
      if (shouldProceed != true) {
        return false;
      }
    }
    
    // Launch the URL
    try {
      final uri = Uri.parse(url);
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir link: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return false;
    }
  }
  
  /// Launches a deep link with interstitial protection
  static Future<bool> launchDeepLink({
    required BuildContext context,
    required String deepLink,
    required List<String> warnings,
    String? title,
  }) async {
    return launch(
      context: context,
      url: deepLink,
      warnings: warnings,
      title: title ?? 'Atenção: Link de aplicativo',
    );
  }
}
