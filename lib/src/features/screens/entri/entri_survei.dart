import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:welangflood/src/common_widets/filled%20button/button.dart';
import 'package:welangflood/src/common_widets/form/form.dart';
import 'package:welangflood/src/common_widets/text/headline.dart';
import 'package:welangflood/src/common_widets/text/subtitle.dart';
import 'package:welangflood/src/constants/color.dart';
import 'package:welangflood/src/constants/text_string.dart';
import 'package:welangflood/src/features/screens/entri/widgets/calender.dart';
import 'package:welangflood/src/features/screens/entri/widgets/data_survei.dart';
import 'package:welangflood/src/features/screens/entri/widgets/location_picker.dart';
import 'package:welangflood/src/features/screens/entri/widgets/photo_picker.dart';
import 'package:welangflood/src/features/screens/home/home.dart';
import 'package:welangflood/src/services/survey_service.dart';

class EntriSurvei extends StatefulWidget {
  const EntriSurvei({super.key});

  @override
  State<EntriSurvei> createState() => _EntriSurveiState();
}

class _EntriSurveiState extends State<EntriSurvei> {
  final _tinggiController = TextEditingController();

  // Pre-initialize to now() — matches the calendar widget's default
  DateTime _selectedDate = DateTime.now();
  LatLng? _selectedLocation;
  String? _fotoPath;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _tinggiController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final tinggi = double.tryParse(_tinggiController.text.trim());

    if (tinggi == null) {
      setState(() => _errorMessage = 'Tinggi genangan harus diisi dengan angka');
      return;
    }
    if (_selectedLocation == null) {
      setState(() => _errorMessage = 'Lokasi survei harus dipilih di peta');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    final survei = Survei(
      tinggi: tinggi,
      tanggalKejadian: _selectedDate,
      latitude: _selectedLocation!.latitude,
      longitude: _selectedLocation!.longitude,
    );

    final result = await SurveyService.submitSurvey(survei, fotoPath: _fotoPath);
    if (!mounted) return;

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data survei berhasil dikirim!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Home()),
        (route) => false,
      );
    } else {
      setState(() { _isLoading = false; _errorMessage = result.message; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: tPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: screenSize.height * 0.03),
                  const Headline(text: tInputTitle),
                  const SizedBox(height: 8),
                  const Subtitle(text: tInputSubtitle),
                  SizedBox(height: screenSize.width * 0.08),

                  CalenderForm(
                    onDateSelected: (date) => _selectedDate = date,
                  ),
                  SizedBox(height: screenSize.width * 0.02),

                  OutlinedForm(
                    labelText: 'Dalam bentuk cm',
                    hintText: 'Tinggi Genangan',
                    isRequired: true,
                    isValid: true,
                    controller: _tinggiController,
                  ),
                  SizedBox(height: screenSize.width * 0.02),

                  PhotoPicker(
                    hintText: 'Foto (opsional)',
                    isValid: true,
                    isRequired: false,
                    onPhotoSelected: (path) => _fotoPath = path.isEmpty ? null : path,
                  ),
                  SizedBox(height: screenSize.width * 0.02),

                  LocationPicker(
                    hintText: 'Lokasi',
                    onLocationSelected: (latLng) => setState(() => _selectedLocation = latLng),
                  ),
                  SizedBox(height: screenSize.width * 0.04),

                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 13, fontFamily: 'Inter'),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  SizedBox(height: screenSize.width * 0.02),
                  CustomElevatedButton(
                    height: screenSize.height * 0.055,
                    onPressed: _isLoading ? () {} : _handleSubmit,
                    text: _isLoading ? 'Mengirim...' : tInputButton,
                    foregroundColor: tTertiaryColor,
                    backgroundColor: tPrimaryColor,
                  ),
                  SizedBox(height: screenSize.width * 0.06),
                ],
              ),
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}