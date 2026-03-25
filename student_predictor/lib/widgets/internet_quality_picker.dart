import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InternetQualityPicker extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const InternetQualityPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const _options = [
    _Option('Poor', Color(0xFFEF5350), '📶'),
    _Option('Average', Color(0xFFFFB74D), '📶'),
    _Option('Good', Color(0xFF66BB6A), '📶'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Internet Quality',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: _options.map((opt) {
              final selected = value == opt.label;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(opt.label),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? opt.color.withOpacity(0.18)
                          : const Color(0xFF0B0D17),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? opt.color
                            : Colors.white.withOpacity(0.1),
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          opt.label,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: selected ? opt.color : Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _Option {
  final String label;
  final Color color;
  final String icon;
  const _Option(this.label, this.color, this.icon);
}
