import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qrshield/core/domain/payload.dart';
import 'package:qrshield/shared/i18n/strings_pt.dart';
import 'package:qrshield/shared/widgets/interstitial_dialog.dart';
import 'package:qrshield/shared/widgets/primary_button.dart';
import 'package:qrshield/shared/widgets/report_card.dart';
import 'package:qrshield/shared/widgets/risk_badge.dart';
import 'package:qrshield/features/report/controller/report_controller.dart';
import 'package:qrshield/features/report/presentation/widgets/report_card.dart'
    as widgets;

/// Report page showing QR code analysis results
class ReportPage extends ConsumerWidget {
  const ReportPage({super.key, required this.rawPayload});
  final String rawPayload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportState = ref.watch(reportControllerProvider(rawPayload));
    final reportController = ref.read(
      reportControllerProvider(rawPayload).notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(StringsPt.reportTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: reportController.analyzeNow,
            tooltip: StringsPt.actionAnalyze,
          ),
        ],
      ),
      body: _buildBody(context, reportState, reportController),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ReportState state,
    ReportController controller,
  ) {
    switch (state.status) {
      case ReportStatus.analyzing:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Analisando QR Code...'),
            ],
          ),
        );

      case ReportStatus.error:
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
                'Erro na análise',
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

      case ReportStatus.ready:
        return _buildReport(context, state, controller);
    }
  }

  Widget _buildReport(
    BuildContext context,
    ReportState state,
    ReportController controller,
  ) {
    final payload = state.payload!;
    final riskScore = state.riskScore!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Risk badge
          Center(
            child: RiskBadge.fromRiskScore(
              riskScore,
              showScore: true,
              size: 32,
            ),
          ),

          const SizedBox(height: 24),

          // What we found section
          widgets.ReportCard(
            title: StringsPt.reportWhatWeFound,
            icon: Icons.search,
            items: _getPayloadInfo(payload),
          ),

          const SizedBox(height: 16),

          // Risk analysis section
          widgets.ReportCard(
            title: StringsPt.reportWhyRisky,
            icon: Icons.security,
            iconColor: _getRiskColor(context, riskScore.level),
            items:
                riskScore.reasons
                    .map((reason) => ReportItem(label: '•', value: reason))
                    .toList(),
            isCollapsible: true,
            initiallyExpanded: riskScore.level != 'safe',
          ),

          const SizedBox(height: 16),

          // Actions section
          const widgets.ReportCard(
            title: StringsPt.reportWhatCanIDo,
            icon: Icons.touch_app,
            items: [],
          ),

          const SizedBox(height: 16),

          // Action buttons
          _buildActionButtons(context, state, controller),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<ReportItem> _getPayloadInfo(Payload payload) {
    switch (payload) {
      case final UrlPayload url:
        return [
          const ReportItem(label: 'Tipo', value: StringsPt.payloadUrl),
          ReportItem(label: 'URL', value: url.url.toString()),
          ReportItem(label: 'Domínio', value: url.url.host),
          if (url.url.path.isNotEmpty)
            ReportItem(label: 'Caminho', value: url.url.path),
        ];

      case final DeeplinkPayload deeplink:
        return [
          const ReportItem(label: 'Tipo', value: StringsPt.payloadDeeplink),
          ReportItem(label: 'Esquema', value: deeplink.scheme),
          ReportItem(label: 'Link', value: deeplink.raw),
        ];

      case final PixPayload pix:
        return [
          const ReportItem(label: 'Tipo', value: StringsPt.payloadPix),
          ReportItem(
            label: 'Checksum',
            value: pix.crcValid ? 'Válido' : 'Inválido',
          ),
          ReportItem(
            label: 'Identificador',
            value: pix.gui.isEmpty ? 'Não encontrado' : pix.gui,
          ),
          ...pix.fields.entries.map(
            (entry) => ReportItem(label: entry.key, value: entry.value),
          ),
        ];

      case final WifiPayload wifi:
        return [
          const ReportItem(label: 'Tipo', value: StringsPt.payloadWifi),
          ReportItem(label: 'Nome da Rede', value: wifi.ssid),
          ReportItem(label: 'Segurança', value: wifi.sec.toUpperCase()),
          ReportItem(
            label: 'Senha',
            value: wifi.password != null ? '[PROTEGIDA]' : 'Nenhuma',
          ),
          if (wifi.hidden)
            const ReportItem(label: 'Visibilidade', value: 'Rede oculta'),
        ];

      case final SimplePayload simple:
        return [
          ReportItem(
            label: 'Tipo',
            value: _getSimplePayloadTypeName(simple.type),
          ),
          ReportItem(label: 'Conteúdo', value: simple.raw),
        ];
    }
  }

  String _getSimplePayloadTypeName(String type) {
    switch (type) {
      case 'sms':
        return StringsPt.payloadSms;
      case 'tel':
        return StringsPt.payloadTel;
      case 'mailto':
        return StringsPt.payloadEmail;
      case 'geo':
        return StringsPt.payloadGeo;
      case 'vcard':
        return StringsPt.payloadVcard;
      case 'text':
        return StringsPt.payloadText;
      default:
        return type.toUpperCase();
    }
  }

  Color _getRiskColor(BuildContext context, String level) {
    switch (level) {
      case 'safe':
        return Colors.green;
      case 'suspicious':
        return Colors.orange;
      case 'danger':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildActionButtons(
    BuildContext context,
    ReportState state,
    ReportController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Copy button
        SecondaryButton(
          text: StringsPt.reportCopy,
          icon: Icons.copy,
          onPressed: () async {
            await controller.copyToClipboard();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(StringsPt.reportCopied)),
              );
            }
          },
        ),

        const SizedBox(height: 12),

        // Open button (with interstitial protection)
        if (state.payload is UrlPayload || state.payload is DeeplinkPayload)
          PrimaryButton.destructive(
            text: StringsPt.reportOpen,
            icon: Icons.open_in_new,
            onPressed: () => _handleOpenAction(context, state),
          ),

        const SizedBox(height: 12),

        // Report button (stub)
        TertiaryButton(
          text: StringsPt.reportDenounce,
          icon: Icons.flag,
          onPressed: () => _showDenounceDialog(context),
        ),
      ],
    );
  }

  Future<void> _handleOpenAction(
    BuildContext context,
    ReportState state,
  ) async {
    final payload = state.payload!;
    final warnings = state.riskScore?.reasons ?? [];

    String url;
    String title;

    if (payload is UrlPayload) {
      url = payload.url.toString();
      title = 'Atenção: Link potencialmente perigoso';
    } else if (payload is DeeplinkPayload) {
      url = payload.raw;
      title = 'Atenção: Link de aplicativo';
    } else {
      return;
    }

    await SafeUrlLauncher.launch(
      context: context,
      url: url,
      warnings: warnings,
      title: title,
    );
  }

  void _showDenounceDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Denunciar conteúdo'),
            content: const Text(
              'Esta funcionalidade permite reportar QR Codes maliciosos para melhorar a proteção de todos os usuários.\n\n'
              'Em breve, você poderá enviar relatórios anônimos de ameaças detectadas.',
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
}
