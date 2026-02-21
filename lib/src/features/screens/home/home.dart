import 'package:flutter/material.dart';
import 'package:welangflood/src/constants/text_string.dart';
import 'package:welangflood/src/features/screens/entri/widgets/data_survei.dart';
import 'package:welangflood/src/features/screens/home/widgets/entri_button.dart';
import 'package:welangflood/src/features/screens/home/widgets/filter.dart';
import 'package:welangflood/src/features/screens/home/widgets/map.dart';
import 'package:welangflood/src/features/screens/home/widgets/text/headline_text.dart';
import 'package:welangflood/src/features/screens/home/widgets/text/subtitle_text.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Survei? _surveiData;

  void setSurveiData(Survei data) {
    setState(() {
      _surveiData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.03,
              left: screenWidth * 0.065,
              right: screenWidth * 0.065,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Filter(),
                    SizedBox(width: screenWidth * 0.15),
                    const HeadlineText(),
                  ],
                ),
                SizedBox(height: screenHeight * 0.04),
                const SubtitleText(text: tEntriSurvei),
                SizedBox(height: screenHeight * 0.01),
                const EntriButton(),

                SizedBox(height: screenHeight * 0.03),
                const SubtitleText(text: tViewPeta),
                SizedBox(height: screenHeight * 0.01),
                if (_surveiData != null)
                  Text(
                    'Nama: ${_surveiData!.namaLengkap}\n'
                        'Tinggi: ${_surveiData!.tinggiGenangan}\n'
                        'Tanggal: ${_surveiData!.tanggal}\n'
                        'Lokasi: ${_surveiData!.lokasi}',
                  ),
                SizedBox(
                  height: screenHeight * 0.45,
                  child: const ViewMap(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



