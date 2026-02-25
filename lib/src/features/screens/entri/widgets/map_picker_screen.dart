import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:welangflood/src/constants/color.dart';

class MapPickerScreen extends StatefulWidget {
  final LatLng initialLocation;
  const MapPickerScreen({super.key, required this.initialLocation});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final MapController _mapController = MapController();
  late LatLng _selectedLocation;
  String _selectedAddress = '';

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _getAddress();
  }

  void _selectLocation(LatLng latLng) {
    setState(() => _selectedLocation = latLng);
    _getAddress();
  }

  Future<void> _getAddress() async {
    try {
      final placemarks = await placemarkFromCoordinates(
        _selectedLocation.latitude,
        _selectedLocation.longitude,
      );
      if (placemarks.isNotEmpty && mounted) {
        final p = placemarks.first;
        setState(() {
          _selectedAddress = [
            p.name, p.street, p.subLocality, p.locality, p.administrativeArea
          ].where((s) => s != null && s.isNotEmpty).join(', ');
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _selectedAddress =
              '${_selectedLocation.latitude.toStringAsFixed(5)}, ${_selectedLocation.longitude.toStringAsFixed(5)}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Ensures status bar icons are light on the dark appbar
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Tentukan Lokasi Survei',
            style: TextStyle(color: Colors.white, fontFamily: 'Inter'),
          ),
          backgroundColor: tPrimaryColor,
          // Explicitly set icon theme so back arrow and icons are white
          iconTheme: const IconThemeData(color: Colors.white),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedLocation,
                initialZoom: 14.0,
                onTap: (_, latLng) => _selectLocation(latLng),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.welangflood',
                ),
                MarkerLayer(markers: [
                  Marker(
                    point: _selectedLocation,
                    width: 40, height: 40,
                    child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
                ]),
                RichAttributionWidget(
                  attributions: const [
                    TextSourceAttribution('© OpenStreetMap contributors'),
                  ],
                ),
              ],
            ),

            // Address badge
            if (_selectedAddress.isNotEmpty)
              Positioned(
                top: 16, left: 16, right: 70,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.4),
                        blurRadius: 6, offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(_selectedAddress,
                      style: const TextStyle(color: Colors.black87, fontSize: 12, fontFamily: 'Inter')),
                ),
              ),

            // Zoom controls
            Positioned(
              top: 16, right: 16,
              child: Column(
                children: [
                  _fab(Icons.add, () => _mapController.move(
                      _mapController.camera.center, _mapController.camera.zoom + 1)),
                  const SizedBox(height: 8),
                  _fab(Icons.remove, () => _mapController.move(
                      _mapController.camera.center, _mapController.camera.zoom - 1)),
                ],
              ),
            ),

            // Confirm button
            Positioned(
              bottom: 24, left: 0, right: 0,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, _selectedLocation),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tPrimaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text('Konfirmasi Lokasi',
                      style: TextStyle(color: Colors.white, fontFamily: 'Inter', fontSize: 15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fab(IconData icon, VoidCallback onTap) {
    return FloatingActionButton.small(
      heroTag: icon.codePoint.toString(),
      backgroundColor: tPrimaryColor,
      onPressed: onTap,
      child: Icon(icon, color: Colors.white),
    );
  }
}