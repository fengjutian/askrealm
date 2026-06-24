import 'package:flutter/material.dart';

/// ─── Noir Cinema 语义色 ────────────────────────────────────────────
/// 深黑底 + 琥珀/金色聚光 + 帷幕红点缀
const Color noirBackground = Color(0xFF0A0A0A);
const Color noirCard = Color(0xFF1C1812);
const Color noirSurface = Color(0xFF1A1510);

/// 剧场金 (主色) — 用于强调、按钮、标题、选中态
const Color spotlightGold = Color(0xFFD4A853);
const Color spotlightGoldDim = Color(0xFFB8922E);
const Color spotlightGoldGlow = Color(0x33D4A853);

/// 帷幕红 (辅色) — 用于警告、删除、戏剧性点缀
const Color curtainRed = Color(0xFF8B1A1A);
const Color curtainRedDim = Color(0xFF6B1010);
const Color curtainRedGlow = Color(0x338B1A1A);

/// 暖白系 (文字)
const Color warmWhite = Color(0xFFF5F0E8);
const Color warmWhite70 = Color(0xB3F5F0E8);
const Color warmWhite54 = Color(0x8AF5F0E8);
const Color warmGrey = Color(0xFF9B8E7A);
const Color warmGreyDim = Color(0xFF6B6050);

/// 暖暗分割线
const Color noirDivider = Color(0xFF2A2520);

/// ─── 工具函数 ──────────────────────────────────────────────────────

/// 径向金色光晕（用于卡片/Logo 背后）
BoxDecoration spotlightGlowDecoration({double radius = 120, double opacity = 0.06}) {
  return BoxDecoration(
    shape: BoxShape.circle,
    gradient: RadialGradient(
      center: Alignment.center,
      colors: [
        spotlightGold.withOpacity(opacity),
        spotlightGold.withOpacity(0.02),
        Colors.transparent,
      ],
      stops: const [0.0, 0.6, 1.0],
    ),
  );
}

/// 四角暗角叠加（聊天页背景用）
Widget vignetteOverlay({double intensity = 0.55}) {
  return IgnorePointer(
    child: Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(intensity),
          ],
          stops: const [0.55, 1.0],
        ),
      ),
    ),
  );
}

/// 金色细边框（用于卡片/头像环）
BoxDecoration goldBorderDecoration({double width = 1.5, Color? fillColor}) {
  return BoxDecoration(
    color: fillColor ?? noirCard,
    shape: BoxShape.circle,
    border: Border.all(color: spotlightGold.withOpacity(0.4), width: width),
  );
}

/// ─── 明亮主题 ──────────────────────────────────────────────────────
ThemeData buildLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F0E8),
    cardColor: Colors.white,
    dividerColor: const Color(0xFFDDD5C8),
    splashColor: spotlightGold.withOpacity(0.12),
    highlightColor: spotlightGold.withOpacity(0.06),
    colorScheme: const ColorScheme.light(
      primary: spotlightGold,
      secondary: curtainRed,
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: warmGrey),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A1A),
        letterSpacing: 0.5,
      ),
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A1A),
        letterSpacing: 0.3,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A1A),
        letterSpacing: 0.5,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1A1A1A),
        letterSpacing: 0.5,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1A1A1A),
        letterSpacing: 0.3,
      ),
      bodyLarge: TextStyle(color: Color(0xFF1A1A1A), letterSpacing: 0.3),
      bodyMedium: TextStyle(color: Color(0xFF333333), letterSpacing: 0.3),
      bodySmall: TextStyle(color: Color(0xFF666666), letterSpacing: 0.2),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A1A),
        letterSpacing: 0.3,
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F0E8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDDD5C8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: spotlightGold, width: 1.5),
      ),
    ),
  );
}

/// ─── 暗色主题（Noir Cinema — 默认） ────────────────────────────────
ThemeData buildDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: noirBackground,
    cardColor: noirCard,
    dividerColor: noirDivider,
    splashColor: spotlightGold.withOpacity(0.14),
    highlightColor: spotlightGold.withOpacity(0.06),
    colorScheme: const ColorScheme.dark(
      primary: spotlightGold,
      secondary: curtainRed,
      surface: noirCard,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: warmGrey),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: warmWhite,
        letterSpacing: 1.5,
      ),
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: warmWhite,
        letterSpacing: 0.3,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: warmWhite,
        letterSpacing: 0.5,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: warmWhite,
        letterSpacing: 0.5,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: warmWhite,
        letterSpacing: 0.3,
      ),
      bodyLarge: TextStyle(color: warmWhite, letterSpacing: 0.3),
      bodyMedium: TextStyle(color: warmWhite70, letterSpacing: 0.3),
      bodySmall: TextStyle(color: warmWhite54, letterSpacing: 0.2),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: spotlightGold,
        letterSpacing: 0.3,
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: noirCard,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: warmWhite,
        letterSpacing: 0.3,
      ),
      contentTextStyle: TextStyle(
        fontSize: 15,
        color: warmWhite70,
        letterSpacing: 0.3,
        height: 1.5,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: noirCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: noirDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: spotlightGold, width: 1.5),
      ),
      hintStyle: const TextStyle(color: warmGrey),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: spotlightGold,
        foregroundColor: noirBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: spotlightGold,
      ),
    ),
    iconTheme: const IconThemeData(color: warmGrey),
  );
}
