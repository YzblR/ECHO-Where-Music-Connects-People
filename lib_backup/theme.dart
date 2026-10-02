import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Echo design system — colors and type scale.
// Source: design system doc (Step A and Step B).
// ---------------------------------------------------------------------------

class EchoColors {
  static const primary = Color(0xFFFF679E);
  static const secondary = Color(0xFFF4AFC8);
  static const background = Color(0xFFFBFBFB);
  static const surface = Color(0xFFFBFBFB);
  static const error = Color(0xFFD32F2F);
  static const text = Color(0xFF000000);
}

class EchoTextStyles {
  static const heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: EchoColors.text,
  );
  static const body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: EchoColors.text,
  );
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w300,
    color: Colors.grey,
  );
}

/// App-wide ThemeData built from the tokens above. Pass this into
/// MaterialApp(theme: echoTheme) in main.dart.
final ThemeData echoTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: EchoColors.background,
  colorScheme: ColorScheme.fromSeed(
    seedColor: EchoColors.primary,
    primary: EchoColors.primary,
    secondary: EchoColors.secondary,
    error: EchoColors.error,
    surface: EchoColors.surface,
  ),
  textTheme: const TextTheme(
    headlineSmall: EchoTextStyles.heading,
    bodyMedium: EchoTextStyles.body,
    bodySmall: EchoTextStyles.caption,
  ),
);