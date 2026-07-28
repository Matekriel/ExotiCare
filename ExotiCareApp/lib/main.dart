import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const ExoticCareApp());
}

class ExoticCareApp extends StatelessWidget {
  const ExoticCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ExotiCare',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const LoginScreen(),
    );
  }
}