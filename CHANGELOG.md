# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-12-19

### Added
- Initial release of QRShield
- Secure QR code scanning with camera integration
- Offline-first security heuristics analysis
- Support for multiple QR code types:
  - URLs with security analysis
  - PIX payments with EMV validation
  - WiFi networks with security warnings
  - Deep links with protection
  - Contact information (vCard)
  - SMS, telephone, email, and location data
- Risk scoring algorithm with three levels (Safe/Suspicious/Dangerous)
- Interstitial protection - nothing opens automatically
- Material Design 3 UI with light/dark theme support
- Portuguese localization
- Comprehensive test suite with 60+ tests
- CI/CD pipeline with GitHub Actions

### Security Features
- Blocked scheme detection (javascript:, data:, file:, etc.)
- Punycode domain detection
- URL shortener identification
- PIX EMV checksum validation
- WiFi security analysis
- Optional reputation checking (stub implementation)
- URL expansion for shortened links (stub implementation)

### Technical Details
- Built with Flutter 3.x and Dart 3.x
- State management with Riverpod
- Routing with go_router
- Camera integration with google_mlkit_barcode_scanning
- Secure storage with flutter_secure_storage
- Comprehensive linting with very_good_analysis
- Cross-platform support (iOS/Android)

### Privacy & Security
- Offline-first approach - most analysis happens locally
- No automatic data collection or tracking
- Secure storage for user preferences
- Optional online reputation checks with user consent
- No QR code content is stored permanently
