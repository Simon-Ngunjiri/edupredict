import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InputSlider extends StatelessWidget {
  final String label;
  final String? sublabel;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String unit;
  final Color color;
  final bool isInt;
  final ValueChanged<double> onChanged;

  const InputSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.color,
    required this.onChanged,
    this.sublabel,
    this.divisions,
    this.isInt = false,
  });

  String get _displayValue {
    if (isInt) return '${value.toInt()} $unit';
    return '${value.toStringAsFixed(1)} $unit';
  }

  @override
  Widget build(BuildContext context) {
    final int div = divisions ?? (max - min).clamp(1, 100).toInt();

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (sublabel != null)
                      Text(
                        sublabel!,
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          color: Colors.white30,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.35), width: 1),
                ),
                child: Text(
                  _displayValue,
                  style: GoogleFonts.dmMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withOpacity(0.12),
              thumbColor: color,
              overlayColor: color.withOpacity(0.15),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              trackHeight: 2.5,
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: div,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isInt ? min.toInt().toString() : min.toStringAsFixed(0),
                style: GoogleFonts.dmMono(fontSize: 9, color: Colors.white.withOpacity(0.4)),
              ),
              Text(
                isInt ? max.toInt().toString() : max.toStringAsFixed(0),
                style: GoogleFonts.dmMono(fontSize: 9, color: Colors.white.withOpacity(0.4)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
