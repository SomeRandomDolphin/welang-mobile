import 'package:flutter/material.dart';
import 'package:welangflood/src/constants/color.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:core';
import 'package:welangflood/src/features/screens/entri/widgets/map_picker_screen.dart';

class LocationPicker extends StatefulWidget {
  final String hintText;
  final Function(LatLng)? onLocationSelected;

  const LocationPicker({
    Key? key,
    required this.hintText,
    this.onLocationSelected,
  }) : super(key: key);

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final TextEditingController _locationController = TextEditingController();
  LatLng _pickedLocation = const LatLng(-7.741785, 112.797416);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width >= 375 ? 375 : screenSize.width - 30,
      height: 300,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.hintText,
            style: const TextStyle(
              color: tPrimaryColor,
              fontSize: 16,
              fontFamily: 'Inter',
            ),
          ),
          SizedBox(height: screenSize.height * 0.01),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: tPrimaryColor),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: _pickedLocation,
                        initialZoom: 14.0,
                        onTap: (tapPosition, latLng) => _selectLocation(latLng),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.welangflood',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _pickedLocation,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                        RichAttributionWidget(
                          attributions: const [
                            TextSourceAttribution(
                              '© OpenStreetMap contributors',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            hintText: 'Masukkan lokasi survei',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                          style: const TextStyle(color: tPrimaryColor),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.location_on),
                        onPressed: _pickLocation,
                        color: tPrimaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectLocation(LatLng latLng) async {
    setState(() {
      _pickedLocation = latLng;
    });
    widget.onLocationSelected?.call(_pickedLocation);

    List<Placemark> placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    _locationController.text = placemarks.isNotEmpty ? placemarks[0].name ?? '' : '';
  }

  Future<void> _pickLocation() async {
    LatLng? selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(initialLocation: _pickedLocation),
      ),
    );

    if (selectedLocation != null) {
      setState(() {
        _pickedLocation = selectedLocation;
      });

      widget.onLocationSelected?.call(_pickedLocation);

      List<Placemark> placemarks = await placemarkFromCoordinates(selectedLocation.latitude, selectedLocation.longitude);
      _locationController.text = placemarks.isNotEmpty ? placemarks[0].name ?? '' : '';
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }
}

