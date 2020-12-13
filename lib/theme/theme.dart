import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  primarySwatch: Colors.blue,
  primaryColor: Colors.black,
  brightness: Brightness.dark,
  backgroundColor: const Color(0xFF0d0d0d),
  accentColor: Colors.white,
  accentIconTheme: IconThemeData(color: Colors.black),
  dividerColor: const Color(0xFF242424),
  scaffoldBackgroundColor: const Color(0xFF0d0d0d),
  canvasColor: const Color(0xFF242424),
  fontFamily: 'OpenSans',
);

final lightTheme = ThemeData(
  primarySwatch: Colors.blue,
  primaryColor: Colors.blue,
  brightness: Brightness.light,
  backgroundColor: const Color(0xFFE5E5E5),
  accentColor: Colors.black,
  accentIconTheme: IconThemeData(color: Colors.white),
  dividerColor: Colors.black12,
  scaffoldBackgroundColor: const Color(0xFFFFFFFF),
  fontFamily: 'OpenSans',
);
