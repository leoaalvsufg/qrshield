// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrshield/app/app.dart';

void main() {
  testWidgets('QRShield app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: QRShieldApp()));

    // Verify that the app loads and shows the home page.
    expect(find.text('QRShield'), findsOneWidget);
    expect(find.text('Analise QR Codes com segurança antes de abrir'), findsOneWidget);
    expect(find.text('Escanear agora'), findsOneWidget);
  });
}
