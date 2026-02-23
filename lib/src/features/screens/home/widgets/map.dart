import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:welangflood/src/constants/color.dart';

class ViewMap extends StatefulWidget {
  const ViewMap({Key? key}) : super(key: key);

  @override
  _ViewMapState createState() => _ViewMapState();
}

class _ViewMapState extends State<ViewMap> {
  final MapController _mapController = MapController();

  Color _getMarkerColor(double height) {
    if (height < 10) {
      return Colors.green;
    } else if (height >= 10 && height < 20) {
      return Colors.yellow.shade700;
    } else if (height >= 20 && height < 30) {
      return Colors.orange;
    } else if (height >= 30 && height < 50) {
      return Colors.deepOrange;
    } else {
      return Colors.red;
    }
  }

  List<Map<String, dynamic>> _generateDummyData(int count) {
    final Random random = Random();
    List<Map<String, dynamic>> data = [];
    List<String> petugasNames = ['John', 'Alice', 'Bob', 'Emma', 'Daniel', 'Sophia', 'Michael', 'Olivia'];
    for (int i = 0; i < count; i++) {
      double height = random.nextDouble() * 100;
      String petugas = petugasNames[random.nextInt(petugasNames.length)];
      LatLng position = LatLng(
        -7.741785 + (random.nextDouble() - 0.5) / 10,
        112.797416 + (random.nextDouble() - 0.5) / 10,
      );
      data.add({'height': height, 'petugas': petugas, 'position': position});
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    List<Map<String, dynamic>> dummyData = _generateDummyData(5);

    List<Marker> markers = dummyData.map((data) {
      double height = data['height'];
      LatLng position = data['position'];
      String petugas = data['petugas'];
      return Marker(
        point: position,
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Tinggi: ${height.toStringAsFixed(2)} cm'),
                content: Text('Petugas: $petugas'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
          child: Icon(
            Icons.location_on,
            color: _getMarkerColor(height),
            size: 40,
          ),
        ),
      );
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final mapWidth = constraints.maxWidth > 0 ? constraints.maxWidth : screenWidth;
        final mapHeight = constraints.maxHeight.isFinite && constraints.maxHeight > 0
            ? constraints.maxHeight
            : screenHeight * 0.45;

        return Container(
          width: mapWidth,
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
                        TextSourceAttribution(
                          '© OpenStreetMap contributors',
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 16.0,
                  right: 16.0,
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: tPrimaryColor,
                        ),
                        child: IconButton(
                          onPressed: () {
                            final currentZoom = _mapController.camera.zoom;
                            _mapController.move(
                              _mapController.camera.center,
                              currentZoom + 1,
                            );
                          },
                          icon: const Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: tPrimaryColor,
                        ),
                        child: IconButton(
                          onPressed: () {
                            final currentZoom = _mapController.camera.zoom;
                            _mapController.move(
                              _mapController.camera.center,
                              currentZoom - 1,
                            );
                          },
                          icon: const Icon(Icons.remove, color: Colors.white),
                        ),
                      ),
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
}
