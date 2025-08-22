import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qrshield/features/scan/presentation/scan_page.dart';
import 'package:qrshield/features/report/presentation/report_page.dart';
import 'package:qrshield/features/settings/presentation/settings_page.dart';
import 'package:qrshield/app/home_page.dart';

/// App routing configuration
class AppRouter {
  static const String home = '/';
  static const String scan = '/scan';
  static const String report = '/report';
  static const String settings = '/settings';
  
  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: scan,
        name: 'scan',
        builder: (context, state) => const ScanPage(),
      ),
      GoRoute(
        path: report,
        name: 'report',
        builder: (context, state) {
          final rawPayload = state.extra as String?;
          if (rawPayload == null) {
            // Redirect to home if no payload provided
            return const HomePage();
          }
          return ReportPage(rawPayload: rawPayload);
        },
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Erro'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Página não encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'A página "${state.uri}" não existe.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(home),
              child: const Text('Voltar ao início'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Extension methods for easier navigation
extension AppRouterExtension on BuildContext {
  /// Navigate to home page
  void goHome() => go(AppRouter.home);
  
  /// Navigate to scan page
  void goScan() => go(AppRouter.scan);
  
  /// Navigate to report page with payload
  void goReport(String rawPayload) => go(AppRouter.report, extra: rawPayload);
  
  /// Navigate to settings page
  void goSettings() => go(AppRouter.settings);
  
  /// Pop current route
  void goBack() => pop();
}
