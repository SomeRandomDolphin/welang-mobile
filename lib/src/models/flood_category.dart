class FloodCategory {
  final String jenis;
  final double minHeight;
  final double? maxHeight;
  final String? iconUrl;

  const FloodCategory({
    required this.jenis,
    required this.minHeight,
    this.maxHeight,
    this.iconUrl,
  });

  factory FloodCategory.fromJson(Map<String, dynamic> json) {
    return FloodCategory(
      jenis: json['jenis']?.toString() ?? '-',
      minHeight: double.tryParse(json['tinggi_minimal']?.toString() ?? '') ?? 0,
      maxHeight: double.tryParse(json['tinggi_maksimal']?.toString() ?? ''),
      iconUrl: json['ikon']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jenis': jenis,
      'tinggi_minimal': minHeight,
      'tinggi_maksimal': maxHeight,
      'ikon': iconUrl,
    };
  }

  bool containsHeight(double tinggi) {
    if (tinggi < minHeight) return false;
    if (maxHeight == null) return true;
    return tinggi < maxHeight!;
  }

  String get rangeLabel {
    if (maxHeight == null) {
      return '> ${minHeight.toStringAsFixed(0)} cm';
    }
    return '${minHeight.toStringAsFixed(0)} - ${maxHeight!.toStringAsFixed(0)} cm';
  }

  String get displayLabel => 'Kategori $jenis ($rangeLabel)';
}

