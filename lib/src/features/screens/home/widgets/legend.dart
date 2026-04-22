import 'package:flutter/material.dart';
import 'package:welangflood/src/constants/color.dart';

class LegendWidget extends StatelessWidget {
  final bool compact;
  final bool fillHeight;

  const LegendWidget({
    super.key,
    this.compact = false,
    this.fillHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double maxWidth = compact ? 220.0 : 375.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double containerWidth = constraints.maxWidth < maxWidth
            ? constraints.maxWidth
            : maxWidth;

        return Container(
          width: containerWidth,
          height: fillHeight ? double.infinity : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tPrimaryColor),
            color: Colors.white,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 10,
            vertical: compact ? 8 : 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
                fillHeight ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
            children: [
              Text(
                'Legenda Tinggi Air',
                style: TextStyle(
                  color: tPrimaryColor,
                  fontFamily: 'Inter',
                  fontSize: compact ? 10 : 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // SizedBox(height: compact ? 8 : screenSize.height * 0.012),
              const _LegendItem(color: Colors.green, label: '< 10 cm'),
              const _LegendItem(color: Colors.yellow, label: '10 - 29 cm'),
              const _LegendItem(color: Colors.orange, label: '30 - 49 cm'),
              const _LegendItem(color: Colors.deepOrange, label: '50 - 99 cm'),
              const _LegendItem(color: Colors.red, label: '>= 100 cm'),
            ],
          ),
        );
      },
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: tPrimaryColor,
              fontFamily: 'Inter',
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

