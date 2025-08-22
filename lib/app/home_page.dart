import 'package:flutter/material.dart';
import 'package:qrshield/app/router.dart';

/// Home page with security tips and navigation
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QRShield'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.goSettings(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Analise QR Codes com segurança antes de abrir',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Proteja-se contra golpes e links maliciosos',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.goScan(),
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Escanear agora'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Security tips
              Text(
                'Dicas de segurança',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: ListView(
                  children: const [
                    _SecurityTipCard(
                      icon: Icons.warning_amber,
                      title: 'Nunca abra links automaticamente',
                      description: 'Sempre analise o destino antes de abrir qualquer QR Code.',
                      color: Colors.orange,
                    ),
                    SizedBox(height: 12),
                    _SecurityTipCard(
                      icon: Icons.shield,
                      title: 'Verifique a origem',
                      description: 'Confirme se o QR Code vem de uma fonte confiável.',
                      color: Colors.blue,
                    ),
                    SizedBox(height: 12),
                    _SecurityTipCard(
                      icon: Icons.visibility,
                      title: 'Examine URLs suspeitas',
                      description: 'Desconfie de links encurtados ou domínios estranhos.',
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
              
              // How it works button
              OutlinedButton.icon(
                onPressed: () => context.goSettings(),
                icon: const Icon(Icons.help_outline),
                label: const Text('Como funciona'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecurityTipCard extends StatelessWidget {

  const _SecurityTipCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
