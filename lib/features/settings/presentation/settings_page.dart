import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrshield/shared/i18n/strings_pt.dart';
import 'package:qrshield/features/settings/controller/settings_controller.dart';

/// Settings page
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(StringsPt.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme section
          _SettingsSection(
            title: 'Aparência',
            children: [
              _ThemeSelector(
                currentTheme: settings.themeMode,
                onThemeChanged: controller.setThemeMode,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Security section
          _SettingsSection(
            title: 'Segurança',
            children: [
              SwitchListTile(
                title: const Text('Verificação de reputação'),
                subtitle: const Text('Consultar base de dados de ameaças online'),
                value: settings.enableReputationCheck,
                onChanged: controller.setReputationCheck,
              ),
              SwitchListTile(
                title: const Text('Expansão de URLs'),
                subtitle: const Text('Seguir redirecionamentos para revelar destino final'),
                value: settings.enableUrlExpansion,
                onChanged: controller.setUrlExpansion,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Information section
          _SettingsSection(
            title: 'Informações',
            children: [
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Como funciona'),
                subtitle: const Text('Entenda como o QRShield protege você'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showHowItWorksDialog(context),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacidade'),
                subtitle: const Text('Política de privacidade e proteção de dados'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showPrivacyDialog(context),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Sobre'),
                subtitle: Text('Versão ${settings.appVersion}+${settings.buildNumber}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showAboutDialog(context, settings),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Reset section
          _SettingsSection(
            title: 'Avançado',
            children: [
              ListTile(
                leading: Icon(
                  Icons.restore,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  'Restaurar configurações',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                subtitle: const Text('Voltar às configurações padrão'),
                onTap: () => _showResetDialog(context, controller),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _showHowItWorksDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Como funciona'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'O QRShield analisa QR Codes em várias etapas:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('1. Classificação do conteúdo'),
              Text('Identifica se é URL, PIX, WiFi, etc.'),
              SizedBox(height: 12),
              Text('2. Análise de heurísticas'),
              Text('Verifica padrões suspeitos offline.'),
              SizedBox(height: 12),
              Text('3. Verificação de reputação'),
              Text('Consulta bases de dados de ameaças.'),
              SizedBox(height: 12),
              Text('4. Cálculo de risco'),
              Text('Combina todos os fatores em uma pontuação.'),
              SizedBox(height: 12),
              Text('5. Proteção interstitial'),
              Text('Exige confirmação antes de abrir links perigosos.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }
  
  void _showPrivacyDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacidade'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Compromisso com sua privacidade:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('• Análise offline-first'),
              Text('A maioria das verificações acontece no seu dispositivo.'),
              SizedBox(height: 12),
              Text('• Dados não são armazenados'),
              Text('Não guardamos o conteúdo dos QR Codes escaneados.'),
              SizedBox(height: 12),
              Text('• Consultas anônimas'),
              Text('Quando necessário, enviamos apenas hashes para verificação.'),
              SizedBox(height: 12),
              Text('• Sem rastreamento'),
              Text('Não coletamos dados pessoais ou de uso.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }
  
  void _showAboutDialog(BuildContext context, SettingsState settings) {
    showAboutDialog(
      context: context,
      applicationName: StringsPt.appName,
      applicationVersion: '${settings.appVersion}+${settings.buildNumber}',
      applicationIcon: const Icon(
        Icons.qr_code_scanner,
        size: 48,
      ),
      children: [
        const Text(StringsPt.appDescription),
        const SizedBox(height: 16),
        const Text(
          'Desenvolvido com foco em segurança e privacidade para proteger usuários contra golpes via QR Code.',
        ),
      ],
    );
  }
  
  void _showResetDialog(BuildContext context, SettingsController controller) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar configurações'),
        content: const Text(
          'Tem certeza que deseja restaurar todas as configurações para os valores padrão? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await controller.resetSettings();
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Configurações restauradas'),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  
  const _SettingsSection({
    required this.title,
    required this.children,
  });
  final String title;
  final List<Widget> children;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  
  const _ThemeSelector({
    required this.currentTheme,
    required this.onThemeChanged,
  });
  final ThemeMode currentTheme;
  final ValueChanged<ThemeMode> onThemeChanged;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioListTile<ThemeMode>(
          title: const Text('Claro'),
          subtitle: const Text('Sempre usar tema claro'),
          value: ThemeMode.light,
          groupValue: currentTheme,
          onChanged: (value) => onThemeChanged(value!),
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Escuro'),
          subtitle: const Text('Sempre usar tema escuro'),
          value: ThemeMode.dark,
          groupValue: currentTheme,
          onChanged: (value) => onThemeChanged(value!),
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Sistema'),
          subtitle: const Text('Seguir configuração do sistema'),
          value: ThemeMode.system,
          groupValue: currentTheme,
          onChanged: (value) => onThemeChanged(value!),
        ),
      ],
    );
  }
}
