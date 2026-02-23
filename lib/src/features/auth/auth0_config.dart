import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:welangflood/src/features/screens/home/home.dart';

final Auth0 auth0 = Auth0(
  'dev-2jllqhrcpo0w5k8i.us.auth0.com',
  '4gyhxlY1Uchu1IBlxmcZAAvKEyHFKx2l',
);

Future<void> loginWithAuth0(BuildContext context) async {
  try {
    final credentials = await auth0.webAuthentication(scheme: 'com.example.welangflood').login(
      scopes: {'openid', 'profile', 'email'},
    );
    print('Login successful with Auth0 credentials.');
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Home()),
      (route) => false,
    );
  } catch (e) {
    print('Error during login: $e');
  }
}

