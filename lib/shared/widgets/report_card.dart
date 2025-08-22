import 'package:flutter/material.dart';

/// Reusable card widget for displaying report information
class ReportCard extends StatelessWidget {
  
  const ReportCard({
    super.key,
    required this.title,
    required this.items,
    this.trailing,
    this.isCollapsible = false,
    this.initiallyExpanded = true,
    this.icon,
    this.iconColor,
  });
  final String title;
  final List<ReportItem> items;
  final Widget? trailing;
  final bool isCollapsible;
  final bool initiallyExpanded;
  final IconData? icon;
  final Color? iconColor;
  
  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isCollapsible) _buildHeader(context),
        if (!isCollapsible) const SizedBox(height: 16),
        _buildItems(context),
      ],
    );
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isCollapsible
            ? ExpansionTile(
                title: _buildHeaderContent(context),
                trailing: trailing,
                initiallyExpanded: initiallyExpanded,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _buildItems(context),
                  ),
                ],
              )
            : content,
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: iconColor ?? Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
  
  Widget _buildHeaderContent(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: iconColor ?? Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildItems(BuildContext context) {
    return Column(
      children: items.map((item) => _buildItem(context, item)).toList(),
    );
  }
  
  Widget _buildItem(BuildContext context, ReportItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              item.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: item.widget ?? Text(
              item.value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Data class for report items
class ReportItem {
  
  const ReportItem({
    required this.label,
    required this.value,
    this.widget,
  });
  
  /// Creates a report item with a custom widget
  const ReportItem.widget({
    required this.label,
    required this.widget,
  }) : value = '';
  final String label;
  final String value;
  final Widget? widget;
}

/// Specialized report card for URL information
class UrlReportCard extends StatelessWidget {
  
  const UrlReportCard({
    super.key,
    required this.url,
    this.redirects = 0,
    this.hasPunycode = false,
    this.isShortener = false,
  });
  final Uri url;
  final int redirects;
  final bool hasPunycode;
  final bool isShortener;
  
  @override
  Widget build(BuildContext context) {
    final items = <ReportItem>[
      ReportItem(
        label: 'Esquema',
        value: url.scheme.toUpperCase(),
      ),
      ReportItem(
        label: 'Domínio',
        value: url.host,
      ),
      if (url.path.isNotEmpty)
        ReportItem(
          label: 'Caminho',
          value: url.path,
        ),
      if (url.query.isNotEmpty)
        ReportItem(
          label: 'Parâmetros',
          value: url.query,
        ),
      if (redirects > 0)
        ReportItem(
          label: 'Redirecionamentos',
          value: '$redirects',
        ),
      if (hasPunycode)
        ReportItem.widget(
          label: 'Punycode',
          widget: Row(
            children: [
              Icon(
                Icons.warning,
                size: 16,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 4),
              const Text('Detectado'),
            ],
          ),
        ),
      if (isShortener)
        ReportItem.widget(
          label: 'Encurtador',
          widget: Row(
            children: [
              Icon(
                Icons.link,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              const Text('Sim'),
            ],
          ),
        ),
    ];
    
    return ReportCard(
      title: 'Informações da URL',
      icon: Icons.link,
      items: items,
    );
  }
}

/// Specialized report card for PIX information
class PixReportCard extends StatelessWidget {
  
  const PixReportCard({
    super.key,
    required this.fields,
    required this.crcValid,
    required this.gui,
  });
  final Map<String, String> fields;
  final bool crcValid;
  final String gui;
  
  @override
  Widget build(BuildContext context) {
    final items = <ReportItem>[
      ReportItem.widget(
        label: 'Checksum',
        widget: Row(
          children: [
            Icon(
              crcValid ? Icons.check_circle : Icons.error,
              size: 16,
              color: crcValid 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 4),
            Text(crcValid ? 'Válido' : 'Inválido'),
          ],
        ),
      ),
      ReportItem(
        label: 'Identificador',
        value: gui.isEmpty ? 'Não encontrado' : gui,
      ),
      ...fields.entries.map((entry) => ReportItem(
        label: entry.key,
        value: entry.value,
      ),),
    ];
    
    return ReportCard(
      title: 'Informações do PIX',
      icon: Icons.pix,
      iconColor: const Color(0xFF32BCAD), // PIX brand color
      items: items,
    );
  }
}

/// Specialized report card for WiFi information
class WifiReportCard extends StatelessWidget {
  
  const WifiReportCard({
    super.key,
    required this.ssid,
    required this.security,
    required this.hasPassword,
    required this.isHidden,
  });
  final String ssid;
  final String security;
  final bool hasPassword;
  final bool isHidden;
  
  @override
  Widget build(BuildContext context) {
    final items = <ReportItem>[
      ReportItem(
        label: 'Nome da Rede',
        value: ssid,
      ),
      ReportItem.widget(
        label: 'Segurança',
        widget: Row(
          children: [
            Icon(
              hasPassword ? Icons.lock : Icons.lock_open,
              size: 16,
              color: hasPassword 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 4),
            Text(security.toUpperCase()),
          ],
        ),
      ),
      if (isHidden)
        ReportItem.widget(
          label: 'Visibilidade',
          widget: Row(
            children: [
              Icon(
                Icons.visibility_off,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              const Text('Rede oculta'),
            ],
          ),
        ),
    ];
    
    return ReportCard(
      title: 'Informações da Rede WiFi',
      icon: Icons.wifi,
      items: items,
    );
  }
}
