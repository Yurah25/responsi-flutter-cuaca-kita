import 'package:flutter/material.dart';

import 'features/home/views/home_screen.dart';

class CuacaKitaApp extends StatelessWidget {
  const CuacaKitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF315FCE);

    return MaterialApp(
      title: 'CuacaKita',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF4F7FC),
          foregroundColor: Color(0xFF17243B),
          centerTitle: false,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primaryColor, width: 1.5),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
