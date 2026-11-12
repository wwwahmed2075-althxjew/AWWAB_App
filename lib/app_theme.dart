import 'package:flutter/material.dart';

class AppPalette {
  AppPalette._();

  static bool isDark = true;

  static Color get background => isDark ? const Color(0xFF07080B) : const Color(0xFFF5F6F8);
  static Color get surface => isDark ? const Color(0xFF15171C) : const Color(0xFFFFFFFF);
  static Color get foreground => isDark ? const Color(0xFFF5F5F7) : const Color(0xFF17191E);
  static Color get muted => isDark ? const Color(0xFF9A9CA5) : const Color(0xFF626875);
  static Color get cardOverlay => isDark ? Colors.white.withOpacity(.055) : Colors.black.withOpacity(.035);
  static Color get cardBorder => isDark ? Colors.white.withOpacity(.11) : Colors.black.withOpacity(.09);
  static Color get navSurface => isDark ? const Color(0xD91B1D22) : const Color(0xEFFFFFFF);
}
