import 'package:flutter/material.dart';
import 'package:qrshield/app/theme.dart';
import 'package:qrshield/core/domain/risk_score.dart';

/// Widget that displays a risk level badge with appropriate colors and icons
class RiskBadge extends StatelessWidget {
  const RiskBadge({
    super.key,
    required this.level,
    this.score,
    this.showScore = false,
    this.size,
  });

  /// Creates a badge from a RiskScore
  factory RiskBadge.fromRiskScore(
    RiskScore riskScore, {
    bool showScore = false,
    double? size,
  }) {
    return RiskBadge(
      level: riskScore.level,
      score: riskScore.value,
      showScore: showScore,
      size: size,
    );
  }
  final String level;
  final int? score;
  final bool showScore;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final config = _getRiskConfig(context);
    final badgeSize = size ?? 24.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: badgeSize * 0.5,
        vertical: badgeSize * 0.25,
      ),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(badgeSize * 0.5),
        border: Border.all(color: config.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, color: config.color, size: badgeSize),
          SizedBox(width: badgeSize * 0.25),
          Text(
            config.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: config.color,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showScore && score != null) ...[
            SizedBox(width: badgeSize * 0.25),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: badgeSize * 0.25,
                vertical: badgeSize * 0.125,
              ),
              decoration: BoxDecoration(
                color: config.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(badgeSize * 0.25),
              ),
              child: Text(
                '$score',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: config.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  _RiskConfig _getRiskConfig(BuildContext context) {
    final appColors = context.appColors;

    switch (level) {
      case RiskScore.safe:
        return _RiskConfig(
          color: appColors.safe,
          icon: Icons.check_circle,
          label: 'Seguro',
        );
      case RiskScore.suspicious:
        return _RiskConfig(
          color: appColors.suspicious,
          icon: Icons.warning,
          label: 'Suspeito',
        );
      case RiskScore.danger:
        return _RiskConfig(
          color: appColors.danger,
          icon: Icons.dangerous,
          label: 'Perigoso',
        );
      default:
        return const _RiskConfig(
          color: Colors.grey,
          icon: Icons.help_outline,
          label: 'Desconhecido',
        );
    }
  }
}

class _RiskConfig {
  const _RiskConfig({
    required this.color,
    required this.icon,
    required this.label,
  });
  final Color color;
  final IconData icon;
  final String label;
}

/// Compact version of RiskBadge for use in lists
class CompactRiskBadge extends StatelessWidget {
  const CompactRiskBadge({super.key, required this.level, this.size = 16.0});
  final String level;
  final double size;

  @override
  Widget build(BuildContext context) {
    final config = _getRiskConfig(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: config.color, shape: BoxShape.circle),
      child: Icon(config.icon, color: Colors.white, size: size * 0.6),
    );
  }

  _RiskConfig _getRiskConfig(BuildContext context) {
    final appColors = context.appColors;

    switch (level) {
      case RiskScore.safe:
        return _RiskConfig(
          color: appColors.safe,
          icon: Icons.check,
          label: 'Seguro',
        );
      case RiskScore.suspicious:
        return _RiskConfig(
          color: appColors.suspicious,
          icon: Icons.warning,
          label: 'Suspeito',
        );
      case RiskScore.danger:
        return _RiskConfig(
          color: appColors.danger,
          icon: Icons.close,
          label: 'Perigoso',
        );
      default:
        return const _RiskConfig(
          color: Colors.grey,
          icon: Icons.help,
          label: 'Desconhecido',
        );
    }
  }
}
