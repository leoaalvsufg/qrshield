import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrshield/app/router.dart';
import 'package:qrshield/shared/i18n/strings_pt.dart';
import 'package:qrshield/features/scan/controller/scan_controller.dart';
import 'package:qrshield/features/scan/presentation/widgets/scan_view.dart';

/// Scan page for QR code scanning
class ScanPage extends ConsumerWidget {
  const ScanPage({super.key});

  /// Show dialog for manual QR code input
  void _showManualInputDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Inserir QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Cole ou digite o conteúdo do QR Code:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ex: https://example.com ou conteúdo PIX...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final content = controller.text.trim();
              if (content.isNotEmpty) {
                Navigator.pop(context);
                context.goReport(content);
              }
            },
            child: const Text('Analisar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scanControllerProvider);
    final scanController = ref.read(scanControllerProvider.notifier);

    // Listen for detected QR codes
    ref.listen<ScanState>(scanControllerProvider, (previous, current) {
      if (current.status == ScanStatus.detected && current.rawPayload != null) {
        // Navigate to report page with the detected payload
        context.goReport(current.rawPayload!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(StringsPt.scanTitle),
        actions: [
          // Switch camera button
          if (scanState.cameras.length > 1)
            IconButton(
              icon: const Icon(Icons.flip_camera_ios),
              onPressed: scanController.switchCamera,
              tooltip: StringsPt.scanSwitchCamera,
            ),

          // Pause/resume button
          IconButton(
            icon: Icon(scanState.isScanning ? Icons.pause : Icons.play_arrow),
            onPressed: scanController.toggleScanning,
            tooltip:
                scanState.isScanning
                    ? StringsPt.scanPause
                    : StringsPt.scanResume,
          ),
        ],
      ),
      body: _buildBody(context, scanState, scanController),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ScanState state,
    ScanController controller,
  ) {
    switch (state.status) {
      case ScanStatus.initializing:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Inicializando câmera...'),
            ],
          ),
        );

      case ScanStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  StringsPt.scanError,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  state.errorMessage ?? 'Erro desconhecido',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Add demo buttons for web testing
                if (kIsWeb) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '📱 Para escanear QR Codes reais',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Use o QRShield em um dispositivo móvel (Android/iOS)',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Manual input for testing real QR codes
                  ElevatedButton.icon(
                    onPressed: () => _showManualInputDialog(context),
                    icon: const Icon(Icons.edit),
                    label: const Text('Inserir QR Code Manualmente'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    '🧪 Ou teste com exemplos pré-definidos:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: () => context.goReport('https://example.com'),
                    icon: const Icon(Icons.link),
                    label: const Text('Testar URL Segura'),
                  ),
                  const SizedBox(height: 8),

                  ElevatedButton.icon(
                    onPressed: () => context.goReport('javascript:alert("xss")'),
                    icon: const Icon(Icons.warning),
                    label: const Text('Testar URL Perigosa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),

                  ElevatedButton.icon(
                    onPressed: () => context.goReport('00020126580014br.gov.bcb.pix0136123e4567-e12b-12d3-a456-426614174000520400005303986540510.005802BR5913FULANO DE TAL6008BRASILIA62070503***6304A4F3'),
                    icon: const Icon(Icons.pix),
                    label: const Text('Testar PIX'),
                  ),
                  const SizedBox(height: 8),

                  ElevatedButton.icon(
                    onPressed: () => context.goReport('WIFI:S:MinhaRede;T:WPA;P:senha123;H:false;'),
                    icon: const Icon(Icons.wifi),
                    label: const Text('Testar WiFi'),
                  ),
                  const SizedBox(height: 24),
                ],

                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Voltar'),
                ),
              ],
            ),
          ),
        );

      case ScanStatus.permissionDenied:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                StringsPt.scanPermissionDenied,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Permita o acesso à câmera para escanear QR Codes.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Voltar'),
              ),
            ],
          ),
        );

      case ScanStatus.ready:
      case ScanStatus.scanning:
      case ScanStatus.detected:
        return ScanView(
          cameraController: controller.cameraController,
          scanState: state,
          onResetScan: controller.resetScan,
        );
    }
  }
}
