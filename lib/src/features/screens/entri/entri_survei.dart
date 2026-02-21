import 'package:flutter/material.dart';
import 'package:welangflood/src/common_widets/filled%20button/button.dart';
import 'package:welangflood/src/common_widets/form/form.dart';
import 'package:welangflood/src/common_widets/text/headline.dart';
import 'package:welangflood/src/common_widets/text/subtitle.dart';
// import 'package:welangflood/src/common_widets/transition/transition.dart';
import 'package:welangflood/src/constants/color.dart';
import 'package:welangflood/src/constants/text_string.dart';
import 'package:welangflood/src/features/screens/entri/widgets/calender.dart';
import 'package:welangflood/src/features/screens/entri/widgets/data_survei.dart';
import 'package:welangflood/src/features/screens/entri/widgets/location_picker.dart';
import 'package:welangflood/src/features/screens/entri/widgets/photo_picker.dart';
import 'package:welangflood/src/features/screens/entri/widgets/survei_repository.dart';
import 'package:welangflood/src/features/screens/home/home.dart';

class EntriSurvei extends StatelessWidget {
  const EntriSurvei({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    TextEditingController namaController = TextEditingController();
    DateTime? selectedDate;
    double? tinggi;
    String? fotoPath;
    String? lokasi;

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: screenSize.height * 0.10),
              const Headline(
                text: tInputTitle,
              ),
              const SizedBox(height: 8),
              const Subtitle(
                text: tInputSubtitle,
              ),

              SizedBox(height: screenSize.width * 0.08),
              OutlinedForm(
                labelText: 'Nama Lengkap',
                hintText: 'Nama Petugas',
                isRequired: true,
                isValid: true,
                controller: namaController,
              ),

              SizedBox(height: screenSize.width * 0.02),
              CalenderForm(
                onDateSelected: (date) {
                  selectedDate = date;
                },
              ),

              SizedBox(height: screenSize.width * 0.02),
              OutlinedForm(
                labelText: 'Dalam bentuk cm',
                hintText: 'Tinggi Genangan',
                isRequired: true,
                isValid: true,
                onChanged: (value) {
                  tinggi = double.tryParse(value);
                },
              ),

              SizedBox(height: screenSize.width * 0.02),
              PhotoPicker(
                hintText: 'Foto',
                isValid: true,
                isRequired: true,
                onPhotoSelected: (path) {
                  fotoPath = path;
                },
              ),

              SizedBox(height: screenSize.width * 0.01),
              LocationPicker(
                hintText: 'Lokasi',
                onLocationSelected: (location) {
                  lokasi = '${location.latitude}, ${location.longitude}';
                },
              ),

              CustomElevatedButton(
                height: screenSize.height * 0.055,
                onPressed: () {
                  if (namaController.text.isNotEmpty &&
                      selectedDate != null &&
                      tinggi != null &&
                      fotoPath != null &&
                      lokasi != null) {
                    Survei survei = Survei(
                      namaLengkap: namaController.text,
                      tanggal: selectedDate!,
                      tinggiGenangan: tinggi!,
                      fotoPath: fotoPath!,
                      lokasi: lokasi!,
                    );
                    SurveiRepository.simpanSurvei(survei);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const Home()),
                    );
                  }
                },
                text: tInputButton,
                foregroundColor: tTertiaryColor,
                backgroundColor: tPrimaryColor,
              ),
              SizedBox(height: screenSize.width * 0.06),
            ],
          ),
        ),
      ),
    );
  }
}
