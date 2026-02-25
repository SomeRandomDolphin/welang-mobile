import 'package:flutter/material.dart';
import 'package:welangflood/src/constants/color.dart';
import 'package:welangflood/src/constants/text_string.dart';
import 'package:welangflood/src/features/screens/home/widgets/entri_button.dart';
import 'package:welangflood/src/features/screens/home/widgets/filter.dart';
import 'package:welangflood/src/features/screens/home/widgets/map.dart';
import 'package:welangflood/src/features/screens/home/widgets/text/headline_text.dart';
import 'package:welangflood/src/features/screens/home/widgets/text/subtitle_text.dart';
import 'package:welangflood/src/features/screens/login/login.dart';
import 'package:welangflood/src/services/auth_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? _startDate;
  String? _endDate;
  double? _minHeight;
  double? _maxHeight;

  void _onFilterChanged(String? start, String? end, double? minH, double? maxH) {
    setState(() {
      _startDate = start;
      _endDate = end;
      _minHeight = minH;
      _maxHeight = maxH;
    });
  }

  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
      (route) => false,
    );
  }

  bool get _hasFilter =>
      _startDate != null || _endDate != null || _minHeight != null || _maxHeight != null;

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
                // Top bar
                Row(
                  children: [
                    FilterButton(onFilterChanged: _onFilterChanged),
                    SizedBox(width: screenWidth * 0.08),
                    const Expanded(child: HeadlineText()),
                    IconButton(
                      icon: const Icon(Icons.logout, color: tPrimaryColor),
                      tooltip: 'Logout',
                      onPressed: _handleLogout,
                    ),
                  ],
                ),

                // Active filter chip
                if (_hasFilter)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0, bottom: 2.0),
                    child: Row(
                      children: [
                        const Icon(Icons.filter_alt, size: 13, color: tSecondaryColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            [
                              if (_startDate != null || _endDate != null)
                                '${_startDate ?? '...'} → ${_endDate ?? '...'}',
                              if (_minHeight != null || _maxHeight != null)
                                '${_minHeight?.toStringAsFixed(0) ?? '0'} – ${_maxHeight?.toStringAsFixed(0) ?? '∞'} cm',
                            ].join('  |  '),
                            style: const TextStyle(fontSize: 11, color: tSecondaryColor, fontFamily: 'Inter'),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _onFilterChanged(null, null, null, null),
                          child: const Icon(Icons.close, size: 13, color: tSecondaryColor),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: screenHeight * 0.03),
                const SubtitleText(text: tEntriSurvei),
                SizedBox(height: screenHeight * 0.01),
                const EntriButton(),

                SizedBox(height: screenHeight * 0.03),
                const SubtitleText(text: tViewPeta),
                SizedBox(height: screenHeight * 0.01),

                SizedBox(
                  height: screenHeight * 0.45,
                  child: ViewMap(
                    startDate: _startDate,
                    endDate: _endDate,
                    minHeight: _minHeight,
                    maxHeight: _maxHeight,
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}