import 'package:flutter/material.dart';
import 'package:welangflood/src/common_widets/filled%20button/button.dart';
import 'package:welangflood/src/common_widets/form/form.dart';
import 'package:welangflood/src/common_widets/text/headline.dart';
import 'package:welangflood/src/common_widets/text/subtitle.dart';
import 'package:welangflood/src/common_widets/transition/transition.dart';
import 'package:welangflood/src/constants/color.dart';
import 'package:welangflood/src/constants/text_string.dart';
import 'package:welangflood/src/features/screens/home/home.dart';
import 'package:welangflood/src/features/screens/register/register.dart';
import 'package:welangflood/src/features/screens/register/widgets/alreadytext.dart';
import 'package:welangflood/src/services/auth_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email    = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Email dan kata sandi harus diisi');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    final result = await AuthService.login(email: email, password: password);
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
                        const Headline(text: tTitleLogin),
                        SizedBox(height: screenSize.height * 0.01),
                        const Subtitle(text: tSubtitleLogin),
                        SizedBox(height: screenSize.height * 0.03),

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
                          onPressed: _isLoading ? () {} : _handleLogin,
                          text: _isLoading ? 'Memuat...' : tButtonLogin,
                          foregroundColor: tTertiaryColor,
                          backgroundColor: tPrimaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
                CustomRichText(
                  onPressed: () => TransitionUtils.navigateWithFadeTransition(context, const Register()),
                  alreadyText: tRichTitleLogin,
                  signText: tButtonRegister,
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