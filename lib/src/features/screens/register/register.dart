import 'package:flutter/material.dart';
import 'package:welangflood/src/common_widets/filled%20button/button.dart';
import 'package:welangflood/src/common_widets/form/form.dart';
import 'package:welangflood/src/common_widets/text/headline.dart';
import 'package:welangflood/src/common_widets/text/subtitle.dart';
import 'package:welangflood/src/common_widets/transition/transition.dart';
import 'package:welangflood/src/constants/color.dart';
import 'package:welangflood/src/constants/text_string.dart';
import 'package:welangflood/src/features/auth/auth0_config.dart';
import 'package:welangflood/src/features/screens/login/login.dart';
import 'package:welangflood/src/features/screens/register/widgets/alreadytext.dart';


class Register extends StatelessWidget {
  const Register({Key? key}) : super(key: key);

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
                        const Headline(
                          text: tTitleRegister,
                        ),

                        SizedBox(height: screenSize.height * 0.01),
                        const Subtitle(
                          text: tSubtitleRegister,
                        ),

                        SizedBox(height: screenSize.height * 0.03),
                        OutlinedForm(
                          labelText: 'welang@gmail.com',
                          hintText: 'Email',
                          controller: TextEditingController(),
                          isRequired: true,
                          isValid: true,
                        ),

                        SizedBox(height: screenSize.height * 0.006),
                        OutlinedForm(
                          labelText: 'Masukkan kata sandi',
                          hintText: 'Kata Sandi ',
                          controller: TextEditingController(),
                          isRequired: true,
                          isValid: true,
                          icon: Icons.visibility,
                        ),

                        SizedBox(height: screenSize.height * 0.028),
                        CustomElevatedButton(
                          height: screenSize.height * 0.055,
                          onPressed: () {
                            loginWithAuth0(context);
                          },
                          text: tButtonRegister,
                          foregroundColor: tTertiaryColor,
                          backgroundColor: tPrimaryColor,
                        ),
                      ],
                    ),
                  ),
                ),

                CustomRichText(
                  onPressed: () {
                    TransitionUtils.navigateWithFadeTransition(context, const Login());
                  },
                  alreadyText: tRichTitle,
                  signText: tRichSubtitle,
                ),
                SizedBox(height: screenSize.height * 0.018),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
