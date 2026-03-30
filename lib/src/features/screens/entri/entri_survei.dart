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

  static const List<_HeightGuide> _heightGuides = [
    _HeightGuide(patokan: 'Setumit dewasa', perkiraan: '5-10 cm', minCm: 5, maxCm: 10),
    _HeightGuide(patokan: 'Sebetis dewasa', perkiraan: '20-30 cm', minCm: 20, maxCm: 30),
    _HeightGuide(patokan: 'Sepaha dewasa', perkiraan: '40-50 cm', minCm: 40, maxCm: 50),
    _HeightGuide(patokan: 'Seban motor matic', perkiraan: '40-50 cm', minCm: 40, maxCm: 50),
    _HeightGuide(patokan: 'Seban motor bebek', perkiraan: '50-60 cm', minCm: 50, maxCm: 60),
    _HeightGuide(patokan: 'Seban mobil pribadi', perkiraan: '50-70 cm', minCm: 50, maxCm: 70),
    _HeightGuide(patokan: 'Seban motor laki', perkiraan: '60-70 cm', minCm: 60, maxCm: 70),
    _HeightGuide(patokan: 'Seban mobil truk engkel', perkiraan: '75-80 cm', minCm: 75, maxCm: 80),
    _HeightGuide(patokan: 'Seban bis', perkiraan: '100-110 cm', minCm: 100, maxCm: 110),
    _HeightGuide(patokan: 'Sedada dewasa', perkiraan: '120-150 cm', minCm: 120, maxCm: 150),
  ];

  // Pre-initialize to now() — matches the calendar widget's default
  DateTime _selectedDate = DateTime.now();
  LatLng? _selectedLocation;
  String? _fotoPath;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tinggiController.addListener(_onTinggiChanged);
  }

  @override
  void dispose() {
    _tinggiController.removeListener(_onTinggiChanged);
    _tinggiController.dispose();
    super.dispose();
  }

  void _onTinggiChanged() {
    if (!mounted) return;
    setState(() {});
  }

  List<_HeightGuide> _matchedGuides(double? tinggi) {
    if (tinggi == null) return const [];
    return _heightGuides.where((guide) => guide.contains(tinggi)).toList();
  }

  Future<void> _showHeightGuideModal() async {
    final tinggi = double.tryParse(_tinggiController.text.trim());
    final matched = _matchedGuides(tinggi);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  const Text(
                    'Perkiraan Tinggi Genangan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tinggi == null
                        ? 'Isi nilai tinggi genangan untuk melihat patokan yang sesuai.'
                        : matched.isEmpty
                            ? 'Tidak ada patokan yang sama persis untuk ${tinggi.toStringAsFixed(0)} cm.'
                            : 'Patokan sesuai ${tinggi.toStringAsFixed(0)} cm: ${matched.map((e) => e.patokan).join(', ')}.',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _heightGuides.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final guide = _heightGuides[index];
                        final isActive = matched.contains(guide);
                        return Container(
                          decoration: BoxDecoration(
                            color: isActive ? tPrimaryColor.withValues(alpha: 0.08) : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            dense: true,
                            title: Text(
                              guide.patokan,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                            trailing: Text(
                              guide.perkiraan,
                              style: TextStyle(
                                fontSize: 13,
                                color: isActive ? tPrimaryColor : Colors.black87,
                                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSubmit() async {
    final tinggi = double.tryParse(_tinggiController.text.trim());

    if (tinggi == null) {
      setState(() => _errorMessage = 'Tinggi genangan harus diisi dengan angka');
      return;
    }
    if (_selectedLocation == null) {
      setState(() => _errorMessage = 'Lokasi genangan harus dipilih di peta');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

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
          content: Text('Data laporan genangan berhasil dikirim!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Home()),
        (route) => false,
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final tinggi = double.tryParse(_tinggiController.text.trim());
    final matchedGuides = _matchedGuides(tinggi);

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

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final guideWidth = (constraints.maxWidth * 0.38).clamp(140.0, 190.0);

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  CalenderForm(
                                    fitParentWidth: true,
                                    onDateSelected: (date) => _selectedDate = date,
                                  ),
                                  SizedBox(height: screenSize.width * 0.02),
                                  OutlinedForm(
                                    labelText: 'Dalam bentuk cm',
                                    hintText: 'Tinggi Genangan',
                                    isRequired: true,
                                    isValid: true,
                                    fitParentWidth: true,
                                    controller: _tinggiController,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: guideWidth,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.blue.shade100),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Expanded(
                                          child: Text(
                                            'Perkiraan Tinggi',
                                            style: TextStyle(
                                              fontSize: 11,
                                              letterSpacing: 0.3,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                        OutlinedButton(
                                          onPressed: _isLoading ? null : _showHeightGuideModal,
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            minimumSize: Size.zero,
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          child: const Text('Perbesar', style: TextStyle(fontSize: 11)),
                                        ),
                                      ],
                                    ),
                                    // if (tinggi != null)
                                    //   Padding(
                                    //     padding: const EdgeInsets.only(top: 4),
                                    //     child: Text(
                                    //       matchedGuides.isEmpty
                                    //           ? 'Tidak ada patokan untuk ${tinggi.toStringAsFixed(0)} cm.'
                                    //           : 'Patokan: ${matchedGuides.map((e) => e.patokan).join(', ')}.',
                                    //       style: const TextStyle(fontSize: 11, color: Colors.black54),
                                    //     ),
                                    //   ),
                                    const SizedBox(height: 6),
                                    SizedBox(
                                      height: 118,
                                      child: ListView.separated(
                                        itemCount: _heightGuides.length,
                                        separatorBuilder: (_, __) => const Divider(height: 1),
                                        itemBuilder: (context, index) {
                                          final guide = _heightGuides[index];
                                          final isActive = matchedGuides.contains(guide);
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 2),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    guide.patokan,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.blueGrey.shade700,
                                                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  guide.perkiraan,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: isActive ? tPrimaryColor : Colors.blueGrey.shade700,
                                                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
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

class _HeightGuide {
  const _HeightGuide({
    required this.patokan,
    required this.perkiraan,
    required this.minCm,
    required this.maxCm,
  });

  final String patokan;
  final String perkiraan;
  final double minCm;
  final double maxCm;

  bool contains(double valueCm) => valueCm >= minCm && valueCm <= maxCm;
}

