import 'dart:io';
import 'package:flutter/material.dart';
import 'package:openemr/screens/home.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'OpenEMR',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(),
      );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Implement your custom certificate validation logic here.
        // You will need to parse the certificate data and validate it.
        return isValidCertificate(cert);
      };
  }

  bool isValidCertificate(X509Certificate cert) {
    try {
      // Get the certificate's validity period.
      final notBefore = cert.startValidity;
      final notAfter = cert.endValidity;

      // Get the current date and time.
      final now = DateTime.now();

      // Check if the certificate is within its validity period.
      if (notBefore.isBefore(now) && notAfter.isAfter(now)) {
        // Certificate is valid.
        return true;
      }

      // Certificate is expired or not yet valid.
      return false;
    } catch (e) {
      // Handle any errors that may occur during certificate validation.
      return false;
    }
  }
}
