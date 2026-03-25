import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AlertChip extends StatelessWidget {
  final String message;

  const AlertChip({super.key, required this.message});

  _Style get _style {
    final m = message.toLowerCase();
    if (m.contains('mental health') || m.contains('wellness')) {
      return _Style(const Color(0xFF66BB6A), Icons.favorite_border_rounded);
    }
    if (m.contains('gaming')) {
      return _Style(const Color(0xFFAB47BC), Icons.sports_esports_outlined);
    }
    if (m.contains('sleep')) {
      return _Style(const Color(0xFF42A5F5), Icons.bedtime_outlined);
    }
    if (m.contains('probability') || m.contains('failing') || m.contains('risk')) {
      return _Style(const Color(0xFFEF5350), Icons.warning_amber_rounded);
    }
    if (m.contains('self study')) {
      return _Style(const Color(0xFF00E5CC), Icons.menu_book_outlined);
    }
    if (m.contains('online')) {
      return _Style(const Color(0xFFFFB74D), Icons.videocam_outlined);
    }
    return _Style(const Color(0xFFFFB74D), Icons.info_outline_rounded);
  }

  @override
  Widget build(BuildContext context) {
    final s = _style;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: s.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: s.color.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(s.icon, size: 16, color: s.color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.dmSans(
                fontSize: 12.5,
                color: s.color.withOpacity(0.9),
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Style {
  final Color color;
  final IconData icon;
  const _Style(this.color, this.icon);
}
