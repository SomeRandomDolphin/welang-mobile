import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:welangflood/src/constants/color.dart';
import 'package:welangflood/src/models/flood_category.dart';
import 'package:welangflood/src/services/category_service.dart';

class FilterButton extends StatefulWidget {
  final void Function(String? start, String? end, double? minHeight, double? maxHeight) onFilterChanged;

  const FilterButton({super.key, required this.onFilterChanged});

  @override
  State<FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<FilterButton> {
  String? _startDate;
  String? _endDate;
  double? _minHeight;
  double? _maxHeight;
  int _selectedCategoryIndex = 0;
  bool _isLoadingCategories = true;
  List<FloodCategory> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    final categories = await CategoryService.getCategories();
    if (!mounted) return;
    setState(() {
      _categories = categories;
      _isLoadingCategories = false;
      if (_selectedCategoryIndex > _categories.length) {
        _selectedCategoryIndex = 0;
      }
    });
  }

  Color _dotColor(double tinggi) {
    if (tinggi < 10) return Colors.green;
    if (tinggi < 30) return Colors.yellow.shade700;
    if (tinggi < 50) return Colors.orange;
    if (tinggi < 100) return Colors.deepOrange;
    return Colors.red;
  }

  bool get _hasActiveFilter =>
      _startDate != null || _endDate != null || _selectedCategoryIndex > 0;

  void _clearAll() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _minHeight = null;
      _maxHeight = null;
      _selectedCategoryIndex = 0;
    });
    widget.onFilterChanged(null, null, null, null);
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    // Shadow local state so we only commit on "Terapkan"
    String? tempStart = _startDate;
    String? tempEnd = _endDate;
    int tempCatIdx = _selectedCategoryIndex;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Filter Data',
              style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Date range ──────────────────────────────
                const Text('Rentang Tanggal',
                    style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: tPrimaryColor)),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                            builder: (c, child) => Theme(
                              data: ThemeData.light().copyWith(
                                  colorScheme: const ColorScheme.light(primary: tPrimaryColor)),
                              child: child!,
                            ),
                          );
                          if (picked != null) setS(() => tempStart = DateFormat('yyyy-MM-dd').format(picked));
                        },
                        child: Text(tempStart ?? 'Mulai',
                            style: const TextStyle(fontSize: 12, color: tPrimaryColor, fontFamily: 'Inter')),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text('→', style: TextStyle(color: tSecondaryColor)),
                    ),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: tPrimaryColor)),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                            builder: (c, child) => Theme(
                              data: ThemeData.light().copyWith(
                                  colorScheme: const ColorScheme.light(primary: tPrimaryColor)),
                              child: child!,
                            ),
                          );
                          if (picked != null) setS(() => tempEnd = DateFormat('yyyy-MM-dd').format(picked));
                        },
                        child: Text(tempEnd ?? 'Selesai',
                            style: const TextStyle(fontSize: 12, color: tPrimaryColor, fontFamily: 'Inter')),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Flood level ─────────────────────────────
                const Text('Level Banjir',
                    style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                if (_isLoadingCategories)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(child: CircularProgressIndicator(color: tPrimaryColor)),
                  )
                else
                  ..._filterRows.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final cat = entry.value;
                    final selected = tempCatIdx == idx;
                    return GestureDetector(
                      onTap: () => setS(() => tempCatIdx = idx),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? tPrimaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: selected ? tPrimaryColor : Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            if (idx == 0)
                              const Icon(Icons.filter_list, size: 14, color: tSecondaryColor)
                            else if (cat.iconUrl != null && cat.iconUrl!.isNotEmpty)
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: Image.network(
                                  cat.iconUrl!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _dotColor(cat.minHeight),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                    color: _dotColor(cat.minHeight), shape: BoxShape.circle),
                              ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                idx == 0 ? 'Semua Level' : cat.displayLabel,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Inter',
                                    color: selected ? Colors.white : tPrimaryColor),
                              ),
                            ),
                            if (selected)
                              const Icon(Icons.check, size: 16, color: Colors.white),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () { Navigator.pop(ctx); _clearAll(); },
              child: const Text('Reset', style: TextStyle(color: Colors.red, fontFamily: 'Inter')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: tPrimaryColor),
              onPressed: () {
                final cat = _filterRows[tempCatIdx];
                setState(() {
                  _startDate = tempStart;
                  _endDate = tempEnd;
                  _selectedCategoryIndex = tempCatIdx;
                  _minHeight = tempCatIdx == 0 ? null : cat.minHeight;
                  _maxHeight = tempCatIdx == 0 ? null : cat.maxHeight;
                });
                Navigator.pop(ctx);
                widget.onFilterChanged(_startDate, _endDate, _minHeight, _maxHeight);
              },
              child: const Text('Terapkan',
                  style: TextStyle(color: Colors.white, fontFamily: 'Inter')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFilterDialog(context),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          border: Border.all(
              color: _hasActiveFilter ? Colors.blue : tPrimaryColor,
              width: _hasActiveFilter ? 2 : 1),
          borderRadius: BorderRadius.circular(6),
          color: _hasActiveFilter ? Colors.blue.shade50 : Colors.transparent,
        ),
        child: Icon(Icons.filter_alt_rounded, size: 24,
            color: _hasActiveFilter ? Colors.blue : tPrimaryColor),
      ),
    );
  }

  List<FloodCategory> get _filterRows {
    return [
      const FloodCategory(jenis: 'Semua Level', minHeight: 0, maxHeight: null),
      ..._categories,
    ];
  }
}