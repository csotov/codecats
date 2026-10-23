import 'package:flutter/material.dart';

import '../engine/judge.dart';
import '../l10n.dart';
import 'theme.dart';
import 'widgets.dart';

/// Bottom sheet with per-test results plus an optional coach hint.
class ResultsSheet extends StatelessWidget {
  const ResultsSheet({super.key, required this.report, this.coach});
  final JudgeReport report;

  /// Kid-friendly explanation of the likely mistake (bilingual pair).
  final ({String es, String en})? coach;

  static Future<void> show(BuildContext context, JudgeReport report,
      {({String es, String en})? coach}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgAlt,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (_) => ResultsSheet(report: report, coach: coach),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = L.instance;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      maxChildSize: 0.9,
      builder: (c, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Text(
              '${l.t('test_results')}: ${report.passedCount}/${report.total}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: report.allPassed ? AppTheme.good : AppTheme.accent2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (coach != null) _coachCard(l),
          for (var i = 0; i < report.results.length; i++)
            _tcTile(report.results[i], i, l),
        ],
      ),
    );
  }

  Widget _coachCard(L l) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: AppTheme.accent2.withOpacity(0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppTheme.accent2.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('💡', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.t('coach'),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: AppTheme.accent2)),
                  const SizedBox(height: 4),
                  Text(l.pick(coach!.es, coach!.en),
                      style: const TextStyle(fontSize: 13, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tcTile(TestResult r, int i, L l) {
    final (icon, color, label) = switch (r.status) {
      TcStatus.pass => (Icons.check_circle, AppTheme.good, l.t('passed')),
      TcStatus.fail => (Icons.cancel, AppTheme.bad, l.t('wrong_answer')),
      TcStatus.tle => (Icons.timer_off, AppTheme.accent2, l.t('tle')),
      TcStatus.parseError =>
        (Icons.error_outline, AppTheme.bad, l.t('parse_error')),
      TcStatus.runtimeError =>
        (Icons.bug_report, AppTheme.bad, l.t('runtime_error')),
      TcStatus.engineError =>
        (Icons.warning_amber, AppTheme.accent2, l.t('runtime_error')),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Text(
                  r.hidden
                      ? '${l.t('hidden_test')} ${i + 1}'
                      : '${l.t('sample')} ${i + 1}',
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Text(label, style: TextStyle(color: color, fontSize: 12)),
              ],
            ),
            if (!r.hidden && r.input.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(l.t('stdin_label'),
                  style:
                      const TextStyle(color: AppTheme.textLo, fontSize: 11)),
              MonoBox(text: r.input),
            ],
            if (!r.hidden && r.status != TcStatus.pass) ...[
              const SizedBox(height: 6),
              Text(l.t('expected'),
                  style:
                      const TextStyle(color: AppTheme.good, fontSize: 11)),
              MonoBox(text: r.expected, color: AppTheme.good),
              const SizedBox(height: 4),
              Text(l.t('got'),
                  style: const TextStyle(color: AppTheme.bad, fontSize: 11)),
              MonoBox(
                  text: r.actual.isEmpty ? '(vacío)' : r.actual,
                  color: AppTheme.bad),
            ],
            if (r.detail.isNotEmpty) ...[
              const SizedBox(height: 6),
              MonoBox(text: _shortDetail(r.detail), color: AppTheme.accent2),
            ],
          ],
        ),
      ),
    );
  }

  String _shortDetail(String d) {
    final clean = d.replaceAll('\r', '');
    final lines = clean.split('\n');
    if (lines.length > 8) return '${lines.take(8).join('\n')}\n...';
    return clean;
  }
}
