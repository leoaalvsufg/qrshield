import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:qrshield/shared/i18n/strings_pt.dart';
import 'package:qrshield/features/scan/controller/scan_controller.dart';

/// Camera preview widget for QR code scanning
class ScanView extends StatelessWidget {
  const ScanView({
    super.key,
    required this.cameraController,
    required this.scanState,
    this.onResetScan,
  });
  final CameraController? cameraController;
  final ScanState scanState;
  final VoidCallback? onResetScan;

  @override
  Widget build(BuildContext context) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        // Camera preview
        Positioned.fill(child: CameraPreview(cameraController!)),

        // Scan overlay
        Positioned.fill(
          child: _ScanOverlay(scanState: scanState, onResetScan: onResetScan),
        ),

        // Status indicator
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: _StatusIndicator(scanState: scanState),
        ),

        // Instructions
        Positioned(
          bottom: 100,
          left: 16,
          right: 16,
          child: _ScanInstructions(scanState: scanState),
        ),
      ],
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  const _ScanOverlay({required this.scanState, this.onResetScan});
  final ScanState scanState;
  final VoidCallback? onResetScan;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScanOverlayPainter(scanState: scanState, context: context),
      child:
          scanState.status == ScanStatus.detected
              ? Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        StringsPt.scanDetected,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: onResetScan,
                        child: const Text('Escanear novamente'),
                      ),
                    ],
                  ),
                ),
              )
              : null,
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  _ScanOverlayPainter({required this.scanState, required this.context});
  final ScanState scanState;
  final BuildContext context;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black.withOpacity(0.5)
          ..style = PaintingStyle.fill;

    final scanAreaSize = size.width * 0.7;
    final scanAreaRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanAreaSize,
      height: scanAreaSize,
    );

    // Draw overlay with cutout
    final path =
        Path()
          ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
          ..addRRect(
            RRect.fromRectAndRadius(scanAreaRect, const Radius.circular(16)),
          )
          ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw scan area border
    final borderPaint =
        Paint()
          ..color =
              scanState.isScanning
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

    canvas.drawRRect(
      RRect.fromRectAndRadius(scanAreaRect, const Radius.circular(16)),
      borderPaint,
    );

    // Draw corner indicators
    _drawCornerIndicators(canvas, scanAreaRect, borderPaint);

    // Draw scanning line animation (if scanning)
    if (scanState.isScanning) {
      _drawScanningLine(canvas, scanAreaRect);
    }
  }

  void _drawCornerIndicators(Canvas canvas, Rect rect, Paint paint) {
    const cornerLength = 20.0;
    const cornerThickness = 4.0;

    final cornerPaint =
        Paint()
          ..color = paint.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = cornerThickness
          ..strokeCap = StrokeCap.round;

    // Top-left corner
    canvas.drawLine(
      Offset(rect.left, rect.top + cornerLength),
      Offset(rect.left, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLength, rect.top),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.top),
      Offset(rect.right, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(rect.left, rect.bottom - cornerLength),
      Offset(rect.left, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerLength, rect.bottom),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.bottom),
      Offset(rect.right, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom - cornerLength),
      Offset(rect.right, rect.bottom),
      cornerPaint,
    );
  }

  void _drawScanningLine(Canvas canvas, Rect rect) {
    // Simple scanning line - in a real implementation, this would be animated
    final linePaint =
        Paint()
          ..color = Theme.of(context).colorScheme.primary.withOpacity(0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    final lineY = rect.center.dy;
    canvas.drawLine(
      Offset(rect.left + 10, lineY),
      Offset(rect.right - 10, lineY),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({required this.scanState});
  final ScanState scanState;

  @override
  Widget build(BuildContext context) {
    String statusText;
    IconData statusIcon;
    Color statusColor;

    switch (scanState.status) {
      case ScanStatus.scanning:
        statusText = StringsPt.scanReading;
        statusIcon = Icons.qr_code_scanner;
        statusColor = Theme.of(context).colorScheme.primary;
      case ScanStatus.detected:
        statusText = StringsPt.scanDetected;
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
      case ScanStatus.ready:
        statusText = scanState.isScanning ? 'Pronto para escanear' : 'Pausado';
        statusIcon = scanState.isScanning ? Icons.qr_code_scanner : Icons.pause;
        statusColor =
            scanState.isScanning
                ? Theme.of(context).colorScheme.primary
                : Colors.orange;
      default:
        statusText = 'Inicializando...';
        statusIcon = Icons.hourglass_empty;
        statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ScanInstructions extends StatelessWidget {
  const _ScanInstructions({required this.scanState});
  final ScanState scanState;

  @override
  Widget build(BuildContext context) {
    if (scanState.status == ScanStatus.detected) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Posicione o QR Code dentro da área de escaneamento',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'O QR Code será analisado automaticamente antes de abrir',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
