import 'package:flutter/material.dart';

abstract final class AmiaColors {
  static const pink = Color(0xFFEC3F6A);
  static const blue = Color(0xFF0074E4);
  static const ink = Color(0xFF1F2021);
  static const muted = Color(0xFFB8B8BE);
  static const line = Color(0xFFE5E9EE);
  static const yellow = Color(0xFFFFAB11);
  static const accents = [
    pink,
    yellow,
    Color(0xFF9443ED),
    Color(0xFF14C8A1),
    blue,
  ];
}

ThemeData amiaTheme(bool dark) {
  final scheme = ColorScheme.fromSeed(
    seedColor: AmiaColors.pink,
    brightness: dark ? Brightness.dark : Brightness.light,
    primary: AmiaColors.pink,
    secondary: AmiaColors.blue,
    surface: dark ? const Color(0xFF1F2021) : Colors.white,
  );
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    splashFactory: InkSparkle.splashFactory,
    textTheme: TextTheme(
      bodyMedium: TextStyle(fontSize: 13, color: scheme.onSurface),
      bodySmall: const TextStyle(fontSize: 11, color: AmiaColors.muted),
    ),
    dividerTheme: const DividerThemeData(
      color: AmiaColors.line,
      thickness: .7,
      space: 1,
    ),
    iconTheme: const IconThemeData(color: AmiaColors.pink, size: 22),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: AmiaColors.pink, size: 22),
      titleTextStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AmiaColors.blue,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      isDense: true,
      contentPadding: EdgeInsets.symmetric(vertical: 14),
      hintStyle: TextStyle(color: Color(0xFFCBDCEC), fontSize: 13),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AmiaColors.line),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AmiaColors.pink),
      ),
      errorStyle: TextStyle(fontSize: 10),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AmiaColors.blue,
        textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
