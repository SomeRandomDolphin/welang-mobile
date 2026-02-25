import 'package:flutter/material.dart';
import 'package:welangflood/src/common_widets/filled%20button/button.dart';
import 'package:welangflood/src/common_widets/form/form.dart';
import 'package:welangflood/src/common_widets/text/headline.dart';
import 'package:welangflood/src/common_widets/text/subtitle.dart';
import 'package:welangflood/src/common_widets/transition/transition.dart';
import 'package:welangflood/src/constants/color.dart';
import 'package:welangflood/src/constants/text_string.dart';
import 'package:welangflood/src/features/screens/home/home.dart';
import 'package:welangflood/src/features/screens/login/login.dart';
import 'package:welangflood/src/features/screens/register/widgets/alreadytext.dart';
import 'package:welangflood/src/services/auth_service.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name     = _nameController.text.trim();
    final email    = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Semua kolom harus diisi');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'Kata sandi minimal 6 karakter');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    final result = await AuthService.register(name: name, email: email, password: password);
    if (!mounted) return;

    if (result.success) {
      Navigator.of(context).pushAndRemoveUntil(
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: screenSize.height * 0.20),
                        const Headline(text: tTitleRegister),
                        SizedBox(height: screenSize.height * 0.01),
                        const Subtitle(text: tSubtitleRegister),
                        SizedBox(height: screenSize.height * 0.03),

                        OutlinedForm(
                          labelText: 'Nama Lengkap',
                          hintText: 'Nama',
                          controller: _nameController,
                          isRequired: true,
                          isValid: true,
                        ),
                        SizedBox(height: screenSize.height * 0.006),
                        OutlinedForm(
                          labelText: 'welang@gmail.com',
                          hintText: 'Email',
                          controller: _emailController,
                          isRequired: true,
                          isValid: true,
                        ),
                        SizedBox(height: screenSize.height * 0.006),
                        OutlinedForm(
                          labelText: 'Masukkan kata sandi',
                          hintText: 'Kata Sandi',
                          controller: _passwordController,
                          isRequired: true,
                          isValid: true,
                          icon: Icons.visibility,
                        ),
                        SizedBox(height: screenSize.height * 0.02),

                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(_errorMessage!,
                              style: const TextStyle(color: Colors.red, fontSize: 13, fontFamily: 'Inter')),
                          ),

                        SizedBox(height: screenSize.height * 0.028),
                        CustomElevatedButton(
                          height: screenSize.height * 0.055,
                          onPressed: _isLoading ? () {} : _handleRegister,
                          text: _isLoading ? 'Memuat...' : tButtonRegister,
                          foregroundColor: tTertiaryColor,
                          backgroundColor: tPrimaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
                CustomRichText(
                  onPressed: () => TransitionUtils.navigateWithFadeTransition(context, const Login()),
                  alreadyText: tRichTitle,
                  signText: tRichSubtitle,
                ),
                SizedBox(height: screenSize.height * 0.018),
              ],
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