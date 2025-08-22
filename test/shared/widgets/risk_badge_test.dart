import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrshield/app/theme.dart';
import 'package:qrshield/core/domain/risk_score.dart';
import 'package:qrshield/shared/widgets/risk_badge.dart';

void main() {
  group('RiskBadge Widget', () {
    Widget createTestWidget(Widget child) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(body: child),
      );
    }

    testWidgets('should display safe risk badge correctly', (tester) async {
      const riskScore = RiskScore('safe', 10, ['No risks detected']);

      await tester.pumpWidget(
        createTestWidget(RiskBadge.fromRiskScore(riskScore)),
      );

      expect(find.text('Seguro'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should display suspicious risk badge correctly', (
      tester,
    ) async {
      const riskScore = RiskScore('suspicious', 35, ['Some concerns']);

      await tester.pumpWidget(
        createTestWidget(RiskBadge.fromRiskScore(riskScore)),
      );

      expect(find.text('Suspeito'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('should display dangerous risk badge correctly', (
      tester,
    ) async {
      const riskScore = RiskScore('danger', 85, ['High risk detected']);

      await tester.pumpWidget(
        createTestWidget(RiskBadge.fromRiskScore(riskScore)),
      );

      expect(find.text('Perigoso'), findsOneWidget);
      expect(find.byIcon(Icons.dangerous), findsOneWidget);
    });

    testWidgets('should show score when enabled', (tester) async {
      const riskScore = RiskScore('suspicious', 42, ['Some concerns']);

      await tester.pumpWidget(
        createTestWidget(RiskBadge.fromRiskScore(riskScore, showScore: true)),
      );

      expect(find.text('Suspeito'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('should not show score when disabled', (tester) async {
      const riskScore = RiskScore('suspicious', 42, ['Some concerns']);

      await tester.pumpWidget(
        createTestWidget(RiskBadge.fromRiskScore(riskScore, showScore: false)),
      );

      expect(find.text('Suspeito'), findsOneWidget);
      expect(find.text('42'), findsNothing);
    });

    testWidgets('should handle unknown risk level', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const RiskBadge(level: 'unknown')),
      );

      expect(find.text('Desconhecido'), findsOneWidget);
      expect(find.byIcon(Icons.help_outline), findsOneWidget);
    });
  });

  group('CompactRiskBadge Widget', () {
    Widget createTestWidget(Widget child) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(body: child),
      );
    }

    testWidgets('should display compact safe badge', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const CompactRiskBadge(level: 'safe')),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('should display compact suspicious badge', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const CompactRiskBadge(level: 'suspicious')),
      );

      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('should display compact dangerous badge', (tester) async {
      await tester.pumpWidget(
        createTestWidget(const CompactRiskBadge(level: 'danger')),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });
}
