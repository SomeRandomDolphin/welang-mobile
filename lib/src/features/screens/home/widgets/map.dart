import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:welangflood/src/constants/color.dart';
import 'package:welangflood/src/features/screens/entri/widgets/data_survei.dart';
import 'package:welangflood/src/models/flood_category.dart';
import 'package:welangflood/src/services/category_service.dart';
import 'package:welangflood/src/services/survey_service.dart';

class ViewMap extends StatefulWidget {
  final String? startDate;
  final String? endDate;
  final double? minHeight;
  final double? maxHeight;

  const ViewMap({
    super.key,
    this.startDate,
    this.endDate,
    this.minHeight,
    this.maxHeight,
  });

  @override
  State<ViewMap> createState() => _ViewMapState();
}

class _ViewMapState extends State<ViewMap> {
  final MapController _mapController = MapController();
  List<Survei> _allSurveys = [];
  List<FloodCategory> _categories = [];
  bool _isLoading = true;
  bool _isLoadingCategory = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadSurveys();
  }

  @override
  void didUpdateWidget(ViewMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload from API only when date filter changes
    if (oldWidget.startDate != widget.startDate || oldWidget.endDate != widget.endDate) {
      _loadSurveys();
    }
    // Height filter is applied client-side — just rebuild
    if (oldWidget.minHeight != widget.minHeight || oldWidget.maxHeight != widget.maxHeight) {
      setState(() {});
    }
  }

  Future<void> _loadSurveys() async {
    setState(() => _isLoading = true);
    final surveys = await SurveyService.getSurveys(
      start: widget.startDate,
      end: widget.endDate,
    );
    if (!mounted) return;
    setState(() {
      _allSurveys = surveys;
      _isLoading = false;
    });

    // Auto-center to the latest survey point
    if (surveys.isNotEmpty) {
      final latest = surveys.first; // assume newest first from API
      _mapController.move(
        LatLng(latest.latitude, latest.longitude),
        _mapController.camera.zoom,
      );
    }
  }

  Future<void> _loadCategories({bool forceRefresh = false}) async {
    setState(() => _isLoadingCategory = true);
    final categories = await CategoryService.getCategories(forceRefresh: forceRefresh);
    if (!mounted) return;
    setState(() {
      _categories = categories;
      _isLoadingCategory = false;
    });
  }

  Future<void> _reloadAll() async {
    await Future.wait([
      _loadCategories(forceRefresh: true),
      _loadSurveys(),
    ]);
  }

  List<Survei> get _filteredSurveys {
    return _allSurveys.where((s) {
      if (widget.minHeight != null && s.tinggi < widget.minHeight!) return false;
      if (widget.maxHeight != null && s.tinggi >= widget.maxHeight!) return false;
      return true;
    }).toList();
  }

  FloodCategory? _findCategory(double tinggi) {
    for (final category in _categories) {
      if (category.containsHeight(tinggi)) {
        return category;
      }
    }
    return null;
  }

  Color _fallbackMarkerColor(double tinggi) {
    if (tinggi < 10) return Colors.green;
    if (tinggi < 30) return Colors.yellow.shade700;
    if (tinggi < 50) return Colors.orange;
    if (tinggi < 100) return Colors.deepOrange;
    return Colors.red;
  }

  String _categoryLabel(double tinggi) {
    final category = _findCategory(tinggi);
    if (category != null) {
      return category.displayLabel;
    }
    return 'Kategori tidak ditemukan';
  }

  Widget _buildMarkerIcon(Survei survei) {
    final category = _findCategory(survei.tinggi);
    if (category?.iconUrl != null && category!.iconUrl!.isNotEmpty) {
      return Image.network(
        category.iconUrl!,
        width: 30,
        height: 30,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return Icon(
            Icons.location_on,
            color: _fallbackMarkerColor(survei.tinggi),
            size: 38,
          );
        },
      );
    }

    return Icon(
      Icons.location_on,
      color: _fallbackMarkerColor(survei.tinggi),
      size: 38,
    );
  }

  void _showDetail(BuildContext context, Survei survei) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Tinggi: ${survei.tinggi.toStringAsFixed(1)} cm',
            style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_categoryLabel(survei.tinggi),
                style: TextStyle(color: _fallbackMarkerColor(survei.tinggi), fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (survei.userName != null)
              Text('Petugas: ${survei.userName}',
                  style: const TextStyle(fontFamily: 'Inter')),
            Text(
              'Tanggal: ${survei.tanggalKejadian.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(fontFamily: 'Inter'),
            ),
            Text(
              'Koordinat: ${survei.latitude.toStringAsFixed(5)}, ${survei.longitude.toStringAsFixed(5)}',
              style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: tSecondaryColor),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: tPrimaryColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final surveys = _filteredSurveys;

    final markers = surveys
        .map((survei) => Marker(
              point: LatLng(survei.latitude, survei.longitude),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => _showDetail(context, survei),
                child: _buildMarkerIcon(survei),
              ),
            ))
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final mapHeight = constraints.maxHeight.isFinite && constraints.maxHeight > 0
            ? constraints.maxHeight
            : screenHeight * 0.45;

        return Container(
          height: mapHeight,
          decoration: BoxDecoration(
            border: Border.all(color: tPrimaryColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: const MapOptions(
                    initialCenter: LatLng(-7.741785, 112.797416),
                    initialZoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.welangflood',
                    ),
                    MarkerLayer(markers: markers),
                    RichAttributionWidget(
                      attributions: const [
                        TextSourceAttribution('© OpenStreetMap contributors'),
                      ],
                    ),
                  ],
                ),

                if (_isLoading)
                  Container(
                    color: Colors.white.withValues(alpha: 0.7),
                    child: const Center(
                        child: CircularProgressIndicator(color: tPrimaryColor)),
                  ),

                if (!_isLoading && surveys.isEmpty)
                  const Center(
                    child: Text('Tidak ada data laporan genangan untuk periode ini',
                        style: TextStyle(
                            color: tSecondaryColor, fontFamily: 'Inter', fontSize: 13)),
                  ),

                if (!_isLoading && surveys.isNotEmpty)
                  Positioned(
                    top: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: tPrimaryColor,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text('${surveys.length} titik banjir',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500)),
                    ),
                  ),

                Positioned(
                  bottom: 16, left: 16,
                  child: FloatingActionButton.small(
                    backgroundColor: tPrimaryColor,
                    tooltip: 'Muat ulang',
                    onPressed: _reloadAll,
                    child: const Icon(Icons.refresh, color: Colors.white),
                  ),
                ),

                if (_isLoadingCategory)
                  const Positioned(
                    bottom: 16,
                    right: 16,
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: tPrimaryColor),
                    ),
                  ),

                if (_categories.isNotEmpty)
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      width: 168,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Legenda Tinggi Genanga',
                            style: TextStyle(
                              fontSize: 10,
                              color: tSecondaryColor,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ..._categories.map((category) => Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: (category.iconUrl != null && category.iconUrl!.isNotEmpty)
                                          ? Image.network(
                                              category.iconUrl!,
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, __, ___) => const Icon(
                                                Icons.location_on,
                                                size: 15,
                                                color: tPrimaryColor,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.location_on,
                                              size: 15,
                                              color: tPrimaryColor,
                                            ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Kategori ${category.jenis}: ${category.rangeLabel}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: tSecondaryColor,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),

                Positioned(
                  top: 16, right: 16,
                  child: Column(
                    children: [
                      _zoomBtn(Icons.add, () => _mapController.move(
                          _mapController.camera.center, _mapController.camera.zoom + 1)),
                      const SizedBox(height: 8),
                      _zoomBtn(Icons.remove, () => _mapController.move(
                          _mapController.camera.center, _mapController.camera.zoom - 1)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _zoomBtn(IconData icon, VoidCallback onTap) {
    return Container(
      width: 44, height: 44,
      decoration: BoxDecoration(color: tPrimaryColor, borderRadius: BorderRadius.circular(6)),
      child: IconButton(onPressed: onTap, icon: Icon(icon, color: Colors.white)),
    );
  }
}