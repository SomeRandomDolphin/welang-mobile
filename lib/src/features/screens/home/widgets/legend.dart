import 'package:flutter/material.dart';
import 'package:welangflood/src/constants/color.dart';
import 'package:welangflood/src/models/flood_category.dart';
import 'package:welangflood/src/services/category_service.dart';

class LegendWidget extends StatefulWidget {
  final bool compact;
  final bool fillHeight;

  const LegendWidget({
    super.key,
    this.compact = false,
    this.fillHeight = false,
  });

  @override
  State<LegendWidget> createState() => _LegendWidgetState();
}

class _LegendWidgetState extends State<LegendWidget> {
  bool _isLoading = true;
  List<FloodCategory> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    // Force refresh so legend follows latest API category response.
    final categories = await CategoryService.getCategories(forceRefresh: true);
    if (!mounted) return;
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  String _legendLabel(FloodCategory category) {
    final jenis = category.jenis.trim();
    final isNumericJenis = double.tryParse(jenis) != null;
    if (jenis.isEmpty || isNumericJenis) {
      return category.rangeLabel;
    }
    return '$jenis (${category.rangeLabel})';
  }

  @override
  Widget build(BuildContext context) {
    final double maxWidth = widget.compact ? 220.0 : 375.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double containerWidth = constraints.maxWidth < maxWidth
            ? constraints.maxWidth
            : maxWidth;

        return Container(
          width: containerWidth,
          height: widget.fillHeight ? double.infinity : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tPrimaryColor),
            color: Colors.white,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 8 : 10,
            vertical: widget.compact ? 8 : 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
                widget.fillHeight ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
            children: [
              Text(
                'Legenda Tinggi Air',
                style: TextStyle(
                  color: tPrimaryColor,
                  fontFamily: 'Inter',
                  fontSize: widget.compact ? 10 : 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: tPrimaryColor,
                      ),
                    ),
                  ),
                )
              else
                if (_categories.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'Kategori tidak tersedia',
                      style: TextStyle(
                        color: tSecondaryColor,
                        fontFamily: 'Inter',
                        fontSize: 11,
                      ),
                    ),
                  )
                else
                  ..._categories.map(
                    (category) => _LegendItem(
                      iconUrl: category.iconUrl,
                      label: _legendLabel(category),
                      compact: widget.compact,
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String? iconUrl;
  final String label;
  final bool compact;

  const _LegendItem({
    this.iconUrl,
    required this.label,
    this.compact = false,
  });

  Widget _fallbackIcon() {
    return const Icon(
      Icons.location_on,
      size: 14,
      color: tPrimaryColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: (iconUrl != null && iconUrl!.isNotEmpty)
                ? Image.network(
                    iconUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _fallbackIcon(),
                  )
                : _fallbackIcon(),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: tPrimaryColor,
              fontFamily: 'Inter',
              fontSize: compact ? 10 : 11,
            ),
          ),
        ],
      ),
    );
  }
}

