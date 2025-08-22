import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

/// Scan state
enum ScanStatus {
  initializing,
  ready,
  scanning,
  detected,
  error,
  permissionDenied,
}

class ScanState {
  final ScanStatus status;
  final String? rawPayload;
  final String? errorMessage;
  final List<CameraDescription> cameras;
  final int selectedCameraIndex;
  final bool isScanning;

  const ScanState({
    this.status = ScanStatus.initializing,
    this.rawPayload,
    this.errorMessage,
    this.cameras = const [],
    this.selectedCameraIndex = 0,
    this.isScanning = true,
  });

  ScanState copyWith({
    ScanStatus? status,
    String? rawPayload,
    String? errorMessage,
    List<CameraDescription>? cameras,
    int? selectedCameraIndex,
    bool? isScanning,
  }) {
    return ScanState(
      status: status ?? this.status,
      rawPayload: rawPayload ?? this.rawPayload,
      errorMessage: errorMessage ?? this.errorMessage,
      cameras: cameras ?? this.cameras,
      selectedCameraIndex: selectedCameraIndex ?? this.selectedCameraIndex,
      isScanning: isScanning ?? this.isScanning,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          rawPayload == other.rawPayload &&
          errorMessage == other.errorMessage &&
          listEquals(cameras, other.cameras) &&
          selectedCameraIndex == other.selectedCameraIndex &&
          isScanning == other.isScanning;

  @override
  int get hashCode =>
      status.hashCode ^
      rawPayload.hashCode ^
      errorMessage.hashCode ^
      cameras.hashCode ^
      selectedCameraIndex.hashCode ^
      isScanning.hashCode;
}

/// Scan controller
class ScanController extends StateNotifier<ScanState> {
  CameraController? _cameraController;
  BarcodeScanner? _barcodeScanner;
  bool _isProcessing = false;

  ScanController() : super(const ScanState()) {
    _initializeCamera();
  }

  /// Initialize camera and barcode scanner
  Future<void> _initializeCamera() async {
    try {
      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        state = state.copyWith(
          status: ScanStatus.error,
          errorMessage: 'Nenhuma câmera disponível',
        );
        return;
      }

      state = state.copyWith(cameras: cameras);

      // Initialize barcode scanner
      _barcodeScanner = BarcodeScanner();

      // Initialize camera controller
      await _initializeCameraController();
    } catch (e) {
      state = state.copyWith(
        status: ScanStatus.error,
        errorMessage: 'Erro ao inicializar câmera: $e',
      );
    }
  }

  /// Initialize camera controller for selected camera
  Future<void> _initializeCameraController() async {
    try {
      final camera = state.cameras[state.selectedCameraIndex];

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();

      // Start image stream for barcode detection
      if (state.isScanning) {
        await _startImageStream();
      }

      state = state.copyWith(status: ScanStatus.ready);
    } catch (e) {
      state = state.copyWith(
        status: ScanStatus.error,
        errorMessage: 'Erro ao inicializar câmera: $e',
      );
    }
  }

  /// Start image stream for barcode detection
  Future<void> _startImageStream() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    // Check if image streaming is supported (not available on web)
    if (kIsWeb) {
      // For web, we'll use a different approach - simulate scanning
      state = state.copyWith(status: ScanStatus.scanning);
      _simulateWebScanning();
      return;
    }

    try {
      await _cameraController!.startImageStream(_processCameraImage);
      state = state.copyWith(status: ScanStatus.scanning);
    } catch (e) {
      // Fallback for platforms that don't support image streaming
      state = state.copyWith(
        status: ScanStatus.error,
        errorMessage: 'Streaming de câmera não suportado nesta plataforma. Use um dispositivo móvel para melhor experiência.',
      );
    }
  }

  /// Stop image stream
  Future<void> _stopImageStream() async {
    if (_cameraController != null &&
        _cameraController!.value.isStreamingImages) {
      await _cameraController!.stopImageStream();
    }
  }

  /// Simulate scanning for web platform
  void _simulateWebScanning() {
    // For web demo, we'll provide a way to manually input QR code content
    // In a real implementation, this could use a different camera API or file upload
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && state.isScanning) {
        // Simulate detecting a demo QR code
        state = state.copyWith(
          status: ScanStatus.detected,
          rawPayload: 'https://example.com/demo-qr-code',
        );
      }
    });
  }

  /// Process camera image for barcode detection
  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessing || _barcodeScanner == null) return;

    _isProcessing = true;

    try {
      // Convert camera image to InputImage
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;

      // Scan for barcodes
      final barcodes = await _barcodeScanner!.processImage(inputImage);

      // Process first detected barcode
      if (barcodes.isNotEmpty) {
        final barcode = barcodes.first;
        if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
          await _stopImageStream();
          state = state.copyWith(
            status: ScanStatus.detected,
            rawPayload: barcode.rawValue,
          );
        }
      }
    } catch (e) {
      // Continue scanning on error
    } finally {
      _isProcessing = false;
    }
  }

  /// Convert CameraImage to InputImage
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_cameraController == null) return null;

    final camera = _cameraController!.description;
    final rotation = InputImageRotationValue.fromRawValue(
      camera.sensorOrientation,
    );
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw as int);
    if (format == null) return null;

    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  /// Switch to next camera
  Future<void> switchCamera() async {
    if (state.cameras.length <= 1) return;

    await _stopImageStream();
    await _cameraController?.dispose();

    final nextIndex = (state.selectedCameraIndex + 1) % state.cameras.length;
    state = state.copyWith(
      selectedCameraIndex: nextIndex,
      status: ScanStatus.initializing,
    );

    await _initializeCameraController();
  }

  /// Pause/resume scanning
  Future<void> toggleScanning() async {
    if (state.isScanning) {
      await _stopImageStream();
      state = state.copyWith(isScanning: false, status: ScanStatus.ready);
    } else {
      await _startImageStream();
      state = state.copyWith(isScanning: true);
    }
  }

  /// Reset scan state
  void resetScan() {
    state = state.copyWith(
      status: ScanStatus.ready,
    );

    if (state.isScanning && _cameraController != null) {
      _startImageStream();
    }
  }

  /// Get camera controller
  CameraController? get cameraController => _cameraController;

  @override
  void dispose() {
    _stopImageStream();
    _cameraController?.dispose();
    _barcodeScanner?.close();
    super.dispose();
  }
}

/// Scan controller provider
final scanControllerProvider = StateNotifierProvider<ScanController, ScanState>(
  (ref) => ScanController(),
);
