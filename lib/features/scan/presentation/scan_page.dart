import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrshield/app/router.dart';
import 'package:qrshield/shared/i18n/strings_pt.dart';
import 'package:qrshield/features/scan/controller/scan_controller.dart';
import 'package:qrshield/features/scan/presentation/widgets/scan_view.dart';

/// Scan page for QR code scanning
class ScanPage extends ConsumerWidget {
  const ScanPage({super.key});

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
            icon: Icon(
              scanState.isScanning ? Icons.pause : Icons.play_arrow,
            ),
            onPressed: scanController.toggleScanning,
            tooltip: scanState.isScanning ? StringsPt.scanPause : StringsPt.scanResume,
          ),
        ],
      ),
      body: _buildBody(context, scanState, scanController),
    );
  }
  
  Widget _buildBody(BuildContext context, ScanState state, ScanController controller) {
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
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Voltar'),
              ),
            ],
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
