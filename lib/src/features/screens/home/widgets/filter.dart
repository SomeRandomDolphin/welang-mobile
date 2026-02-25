import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:welangflood/src/constants/color.dart';

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

  static const List<Map<String, dynamic>> _categories = [
    {'label': 'Semua Level',              'min': null,  'max': null,  'color': null},
    {'label': 'Kat. 1 — 0 s/d 10 cm',    'min': 0.0,   'max': 10.0,  'color': Colors.green},
    {'label': 'Kat. 2 — 10 s/d 30 cm',   'min': 10.0,  'max': 30.0,  'color': null},
    {'label': 'Kat. 3 — 30 s/d 50 cm',   'min': 30.0,  'max': 50.0,  'color': Colors.orange},
    {'label': 'Kat. 4 — 50 s/d 100 cm',  'min': 50.0,  'max': 100.0, 'color': Colors.deepOrange},
    {'label': 'Kat. 5 — lebih 100 cm',   'min': 100.0, 'max': null,  'color': Colors.red},
  ];

  Color _dotColor(int idx) {
    switch (idx) {
      case 1: return Colors.green;
      case 2: return Colors.yellow.shade700;
      case 3: return Colors.orange;
      case 4: return Colors.deepOrange;
      case 5: return Colors.red;
      default: return Colors.grey;
    }
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

  Future<void> _pickDate(BuildContext ctx, bool isStart, void Function(void Function()) setS) async {
    final picked = await showDatePicker(
      context: ctx,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (c, child) => Theme(
        data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: tPrimaryColor)),
        child: child!,
      ),
    );
    if (picked != null) {
      setS(() {
        if (isStart) _startDate = DateFormat('yyyy-MM-dd').format(picked);
        else _endDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
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
                ..._categories.asMap().entries.map((entry) {
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
                          else
                            Container(
                              width: 12, height: 12,
                              decoration: BoxDecoration(
                                  color: _dotColor(idx), shape: BoxShape.circle),
                            ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(cat['label'],
                                style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Inter',
                                    color: selected ? Colors.white : tPrimaryColor)),
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
                final cat = _categories[tempCatIdx];
                setState(() {
                  _startDate = tempStart;
                  _endDate = tempEnd;
                  _selectedCategoryIndex = tempCatIdx;
                  _minHeight = cat['min'] as double?;
                  _maxHeight = cat['max'] as double?;
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
}