import 'dart:async';
import 'dart:js' as js;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Web QR Scanner service using ZXing library
/// Similar implementation to Prezenzaa project
class WebQRScanner {
  static const _timeout = Duration(seconds: 30);
  
  /// Check if QR scanner is available in the browser
  static bool get isAvailable {
    if (!kIsWeb) return false;
    
    try {
      return js.context.hasProperty('qrScanner') && 
             js.context['qrScanner'] != null;
    } catch (e) {
      return false;
    }
  }
  
  /// Start QR code scanning
  /// Returns the scanned QR code content or throws an exception
  static Future<String> startScanning() async {
    if (!isAvailable) {
      throw Exception('QR Scanner not available in this browser');
    }

    try {
      // Call JavaScript function and handle the promise
      final jsPromise = js.context['qrScanner'].callMethod('start');
      final completer = Completer<String>();

      // Handle the JavaScript promise
      jsPromise.callMethod('then', [
        js.allowInterop((dynamic result) {
          if (result != null) {
            completer.complete(result.toString());
          } else {
            completer.completeError('No QR code detected');
          }
        })
      ]).callMethod('catch', [
        js.allowInterop((dynamic error) {
          completer.completeError(error.toString());
        })
      ]);

      // Add timeout
      return await completer.future.timeout(_timeout);

    } catch (e) {
      throw Exception('Failed to scan QR code: $e');
    }
  }
  
  /// Stop QR code scanning
  static void stopScanning() {
    if (!isAvailable) return;
    
    try {
      js.context['qrScanner'].callMethod('stop');
    } catch (e) {
      debugPrint('Error stopping QR scanner: $e');
    }
  }
  
  /// Check if currently scanning
  static bool get isScanning {
    if (!isAvailable) return false;
    
    try {
      return js.context['qrScanner'].callMethod('isScanning') == true;
    } catch (e) {
      return false;
    }
  }
  
  /// Initialize QR scanner
  static bool initialize() {
    if (!isAvailable) return false;
    
    try {
      return js.context['qrScanner'].callMethod('init') == true;
    } catch (e) {
      debugPrint('Error initializing QR scanner: $e');
      return false;
    }
  }
}

/// Web QR Scanner widget for Flutter Web
/// Provides a clean interface for QR scanning in web browsers
class WebQRScannerWidget extends StatefulWidget {
  final void Function(String) onQRCodeDetected;
  final void Function(String)? onError;
  final Widget? child;
  
  const WebQRScannerWidget({
    super.key,
    required this.onQRCodeDetected,
    this.onError,
    this.child,
  });
  
  @override
  State<WebQRScannerWidget> createState() => _WebQRScannerWidgetState();
}

class _WebQRScannerWidgetState extends State<WebQRScannerWidget> {
  bool _isScanning = false;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _initializeScanner();
  }
  
  void _initializeScanner() {
    if (WebQRScanner.isAvailable) {
      WebQRScanner.initialize();
    } else {
      setState(() {
        _error = 'QR Scanner not available in this browser';
      });
    }
  }
  
  Future<void> _startScanning() async {
    if (_isScanning) return;
    
    setState(() {
      _isScanning = true;
      _error = null;
    });
    
    try {
      final result = await WebQRScanner.startScanning();
      widget.onQRCodeDetected(result);
    } catch (e) {
      final errorMessage = e.toString();
      setState(() {
        _error = errorMessage;
      });
      widget.onError?.call(errorMessage);
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }
  
  void _stopScanning() {
    WebQRScanner.stopScanning();
    setState(() {
      _isScanning = false;
    });
  }
  
  @override
  void dispose() {
    _stopScanning();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_error != null) ...[
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Erro na Câmera',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
        ],
        
        if (!_isScanning && _error == null) ...[
          Icon(
            Icons.qr_code_scanner,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Pronto para Escanear',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Clique no botão abaixo para iniciar o escaneamento',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _startScanning,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Iniciar Escaneamento'),
          ),
        ],
        
        if (_isScanning) ...[
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Escaneando...',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Aponte a câmera para o QR Code',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _stopScanning,
            child: const Text('Parar'),
          ),
        ],
        
        if (widget.child != null) ...[
          const SizedBox(height: 24),
          widget.child!,
        ],
      ],
    );
  }
}
