import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../services/api_service.dart';

class ResultPanel extends StatefulWidget {
  final PredictionResult result;
  const ResultPanel({super.key, required this.result});

  @override
  State<ResultPanel> createState() => _ResultPanelState();
}

class _ResultPanelState extends State<ResultPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
            begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _passColor {
    final p = widget.result.examScoreProb;
    if (p >= 0.7) return const Color(0xFF66BB6A);
    if (p >= 0.5) return const Color(0xFFFFB74D);
    return const Color(0xFFEF5350);
  }

  String get _verdict {
    final p = widget.result.examScoreProb;
    if (p >= 0.7) return 'Looking Good!';
    if (p >= 0.5) return 'Room to Improve';
    return 'At Risk';
  }

  String get _verdictEmoji {
    final p = widget.result.examScoreProb;
    if (p >= 0.7) return '🎯';
    if (p >= 0.5) return '📈';
    return '⚠️';
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Column(
          children: [
            // ── Verdict banner ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _passColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _passColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    _verdictEmoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _verdict,
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _passColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Gauges row ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF141829),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.07)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildGauge(
                    label: 'Pass Chance',
                    value: widget.result.examScoreProb,
                    color: const Color(0xFF00E5CC),
                  ),
                  Container(
                      width: 1, height: 90, color: Colors.white12),
                  _buildGauge(
                    label: 'Fail Risk',
                    value: widget.result.failProb,
                    color: const Color(0xFFFF6B6B),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Linear bars ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF141829),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.07)),
              ),
              child: Column(
                children: [
                  _buildBar(
                    label: 'Exam Pass Probability',
                    value: widget.result.examScoreProb,
                    color: const Color(0xFF00E5CC),
                  ),
                  const SizedBox(height: 16),
                  _buildBar(
                    label: 'Fail Probability',
                    value: widget.result.failProb,
                    color: const Color(0xFFFF6B6B),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGauge({
    required String label,
    required double value,
    required Color color,
  }) {
    final pct = value.clamp(0.0, 1.0);
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 50,
          lineWidth: 7,
          percent: pct,
          animation: true,
          animationDuration: 900,
          center: Text(
            '${(pct * 100).toStringAsFixed(1)}%',
            style: GoogleFonts.dmMono(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          progressColor: color,
          backgroundColor: color.withOpacity(0.1),
          circularStrokeCap: CircularStrokeCap.round,
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: GoogleFonts.dmSans(
              fontSize: 11, color: Colors.white38),
        ),
      ],
    );
  }

  Widget _buildBar({
    required String label,
    required double value,
    required Color color,
  }) {
    final pct = value.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 12, color: Colors.white54)),
            Text(
              '${(pct * 100).toStringAsFixed(1)}%',
              style: GoogleFonts.dmMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearPercentIndicator(
          lineHeight: 5,
          percent: pct,
          backgroundColor: color.withOpacity(0.1),
          progressColor: color,
          barRadius: const Radius.circular(4),
          padding: EdgeInsets.zero,
          animation: true,
          animationDuration: 900,
        ),
      ],
    );
  }
}
