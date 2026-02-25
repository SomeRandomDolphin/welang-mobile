import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:welangflood/src/constants/color.dart';
import 'package:welangflood/src/features/screens/entri/widgets/map_picker_screen.dart';

class LocationPicker extends StatefulWidget {
  final String hintText;
  final Function(LatLng)? onLocationSelected;

  const LocationPicker({
    super.key,
    required this.hintText,
    this.onLocationSelected,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final TextEditingController _locationController = TextEditingController();
  LatLng _pickedLocation = const LatLng(-7.741785, 112.797416);
  bool _isGettingLocation = false;

  // ── GPS: get current device location ──────────────────
  Future<void> _useCurrentLocation() async {
    setState(() => _isGettingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError('Layanan lokasi tidak aktif. Aktifkan GPS terlebih dahulu.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Izin lokasi ditolak.');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showError('Izin lokasi ditolak permanen. Buka pengaturan aplikasi.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final latLng = LatLng(position.latitude, position.longitude);
      await _selectLocation(latLng);
    } catch (e) {
      _showError('Gagal mendapatkan lokasi: $e');
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  // ── Tap on inline map ──────────────────────────────────
  Future<void> _selectLocation(LatLng latLng) async {
    setState(() => _pickedLocation = latLng);
    widget.onLocationSelected?.call(latLng);

    try {
      final placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (mounted && placemarks.isNotEmpty) {
        _locationController.text = placemarks[0].name ?? '';
      }
    } catch (_) {
      _locationController.text = '${latLng.latitude.toStringAsFixed(5)}, ${latLng.longitude.toStringAsFixed(5)}';
    }
  }

  // ── Full-screen map picker ─────────────────────────────
  Future<void> _openMapPicker() async {
    final selected = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(initialLocation: _pickedLocation),
      ),
    );
    if (selected != null) await _selectLocation(selected);
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width >= 375 ? 375 : screenSize.width - 30,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.hintText,
              style: const TextStyle(color: tPrimaryColor, fontSize: 16, fontFamily: 'Inter')),
          SizedBox(height: screenSize.height * 0.01),

          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: tPrimaryColor)),
              child: Column(
                children: [
                  // Inline mini-map (fixed height — won't overflow)
                  SizedBox(
                    height: 200,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: _pickedLocation,
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
                            point: _pickedLocation,
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
                  ),

                  // Address row + action buttons
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _locationController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              hintText: 'Pilih lokasi di peta',
                              hintStyle: TextStyle(color: tSecondaryColor, fontSize: 13),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                            style: const TextStyle(color: tPrimaryColor, fontSize: 13),
                          ),
                        ),
                        // GPS button
                        _isGettingLocation
                            ? const SizedBox(
                                width: 36, height: 36,
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: CircularProgressIndicator(strokeWidth: 2, color: tPrimaryColor),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.my_location, color: tPrimaryColor),
                                tooltip: 'Lokasi saat ini',
                                onPressed: _useCurrentLocation,
                                iconSize: 22,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              ),
                        // Full-screen picker button
                        IconButton(
                          icon: const Icon(Icons.open_in_full, color: tPrimaryColor),
                          tooltip: 'Perluas peta',
                          onPressed: _openMapPicker,
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }
}