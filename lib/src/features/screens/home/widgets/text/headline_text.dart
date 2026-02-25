import 'package:flutter/material.dart';
import 'package:welangflood/src/constants/text_string.dart';
import 'package:welangflood/src/services/auth_service.dart';

class HeadlineText extends StatefulWidget {
  const HeadlineText({super.key});

  @override
  State<HeadlineText> createState() => _HeadlineTextState();
}

class _HeadlineTextState extends State<HeadlineText> {
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.me();
    if (!mounted) return;
    setState(() {
      _username = user?['name'] ?? 'Pengguna';
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          tTitleBeranda,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w300,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        Text(
          _username.isEmpty ? '...' : _username,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}