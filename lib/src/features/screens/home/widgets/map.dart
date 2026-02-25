import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:welangflood/src/constants/color.dart';
import 'package:welangflood/src/features/screens/entri/widgets/data_survei.dart';
import 'package:welangflood/src/services/survey_service.dart';

class ViewMap extends StatefulWidget {
  final String? startDate;
  final String? endDate;

  const ViewMap({super.key, this.startDate, this.endDate});

  @override
  State<ViewMap> createState() => _ViewMapState();
}

class _ViewMapState extends State<ViewMap> {
  final MapController _mapController = MapController();
  List<Survei> _surveys = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSurveys();
  }

  @override
  void didUpdateWidget(ViewMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startDate != widget.startDate || oldWidget.endDate != widget.endDate) {
      _loadSurveys();
    }
  }

  Future<void> _loadSurveys() async {
    setState(() => _isLoading = true);
    final surveys = await SurveyService.getSurveys(
      start: widget.startDate,
      end: widget.endDate,
    );
    if (!mounted) return;
    setState(() { _surveys = surveys; _isLoading = false; });
  }

  Color _markerColor(double tinggi) {
    if (tinggi < 10)  return Colors.green;
    if (tinggi < 30)  return Colors.yellow.shade700;
    if (tinggi < 50)  return Colors.orange;
    if (tinggi < 100) return Colors.deepOrange;
    return Colors.red;
  }

  String _categoryLabel(double tinggi) {
    if (tinggi < 10)  return 'Kategori 1 (0–10 cm)';
    if (tinggi < 30)  return 'Kategori 2 (10–30 cm)';
    if (tinggi < 50)  return 'Kategori 3 (30–50 cm)';
    if (tinggi < 100) return 'Kategori 4 (50–100 cm)';
    return 'Kategori 5 (>100 cm)';
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
              style: TextStyle(color: _markerColor(survei.tinggi), fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (survei.userName != null)
              Text('Petugas: ${survei.userName}', style: const TextStyle(fontFamily: 'Inter')),
            Text('Tanggal: ${survei.tanggalKejadian.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(fontFamily: 'Inter')),
            Text(
              'Koordinat: ${survei.latitude.toStringAsFixed(5)}, ${survei.longitude.toStringAsFixed(5)}',
              style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: tSecondaryColor)),
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

    final markers = _surveys.map((survei) => Marker(
      point: LatLng(survei.latitude, survei.longitude),
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () => _showDetail(context, survei),
        child: Icon(Icons.location_on, color: _markerColor(survei.tinggi), size: 40),
      ),
    )).toList();

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
                    child: const Center(child: CircularProgressIndicator(color: tPrimaryColor)),
                  ),

                if (!_isLoading && _surveys.isEmpty)
                  const Center(
                    child: Text('Tidak ada data survei untuk periode ini',
                      style: TextStyle(color: tSecondaryColor, fontFamily: 'Inter', fontSize: 13)),
                  ),

                if (!_isLoading && _surveys.isNotEmpty)
                  Positioned(
                    top: 12, left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: tPrimaryColor, borderRadius: BorderRadius.circular(20)),
                      child: Text('${_surveys.length} titik banjir',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                    ),
                  ),

                Positioned(
                  bottom: 16, left: 16,
                  child: FloatingActionButton.small(
                    backgroundColor: tPrimaryColor,
                    tooltip: 'Muat ulang',
                    onPressed: _loadSurveys,
                    child: const Icon(Icons.refresh, color: Colors.white),
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