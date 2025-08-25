import 'package:flutter/material.dart';
import 'dart:io' show Platform;

/// ===============================
/// TOKENS PRINCIPALES (Fluent 2)
/// ===============================

@immutable
class FluentTokens extends ThemeExtension<FluentTokens> {
  // ---- Color tokens (alias) ----
  final Color accent; // Primary/Accent base
  final Color onAccent; // Texto/icono sobre accent
  final Color bg; // Fondo base (background layer 1)
  final Color bg2; // Superficie (background layer 2)
  final Color bg3; // Contenedor (background layer 3)
  final Color surface; // Superficie para cards/dialogs
  final Color onSurface; // Texto/iconos en superficies
  final Color stroke1; // Borde sutil
  final Color stroke2; // Borde medio
  final Color stroke3; // Borde fuerte
  final Color error; // Danger
  final Color onError;

  // ---- Shape / Stroke ----
  final double radiusXs; // 2
  final double radiusSm; // 4 (por defecto)
  final double radiusMd; // 8
  final double radiusLg; // 12
  final double radiusXl; // 16
  final double strokeWidth; // 1 px
  final double focusStrokeWidth; // 2 px (anillo de foco)

  const FluentTokens({
    // colors
    required this.accent,
    required this.onAccent,
    required this.bg,
    required this.bg2,
    required this.bg3,
    required this.surface,
    required this.onSurface,
    required this.stroke1,
    required this.stroke2,
    required this.stroke3,
    required this.error,
    required this.onError,
    // shape
    required this.radiusXs,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusXl,
    required this.strokeWidth,
    required this.focusStrokeWidth,
  });

  @override
  FluentTokens copyWith({
    Color? accent,
    Color? onAccent,
    Color? bg,
    Color? bg2,
    Color? bg3,
    Color? surface,
    Color? onSurface,
    Color? stroke1,
    Color? stroke2,
    Color? stroke3,
    Color? error,
    Color? onError,
    double? radiusXs,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusXl,
    double? strokeWidth,
    double? focusStrokeWidth,
  }) {
    return FluentTokens(
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      bg: bg ?? this.bg,
      bg2: bg2 ?? this.bg2,
      bg3: bg3 ?? this.bg3,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      stroke1: stroke1 ?? this.stroke1,
      stroke2: stroke2 ?? this.stroke2,
      stroke3: stroke3 ?? this.stroke3,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      radiusXs: radiusXs ?? this.radiusXs,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusXl: radiusXl ?? this.radiusXl,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      focusStrokeWidth: focusStrokeWidth ?? this.focusStrokeWidth,
    );
  }

  @override
  ThemeExtension<FluentTokens> lerp(
    ThemeExtension<FluentTokens>? other,
    double t,
  ) {
    if (other is! FluentTokens) return this;
    return FluentTokens(
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      bg: Color.lerp(bg, other.bg, t)!,
      bg2: Color.lerp(bg2, other.bg2, t)!,
      bg3: Color.lerp(bg3, other.bg3, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      stroke1: Color.lerp(stroke1, other.stroke1, t)!,
      stroke2: Color.lerp(stroke2, other.stroke2, t)!,
      stroke3: Color.lerp(stroke3, other.stroke3, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      radiusXs: _lerpDouble(radiusXs, other.radiusXs, t),
      radiusSm: _lerpDouble(radiusSm, other.radiusSm, t),
      radiusMd: _lerpDouble(radiusMd, other.radiusMd, t),
      radiusLg: _lerpDouble(radiusLg, other.radiusLg, t),
      radiusXl: _lerpDouble(radiusXl, other.radiusXl, t),
      strokeWidth: _lerpDouble(strokeWidth, other.strokeWidth, t),
      focusStrokeWidth: _lerpDouble(
        focusStrokeWidth,
        other.focusStrokeWidth,
        t,
      ),
    );
  }

  static double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

/// ====== Spacing ramp (Fluent) ======
/// Base 4px + excepciones 2,6,10
class Space {
  static const s2 = 2.0;
  static const s4 = 4.0;
  static const s6 = 6.0;
  static const s8 = 8.0;
  static const s10 = 10.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s20 = 20.0;
  static const s24 = 24.0;
  static const s32 = 32.0;
  static const s40 = 40.0;
  static const s48 = 48.0;
  static const s56 = 56.0;
  static const s64 = 64.0;
}

/// ====== Motion tokens ======
class FluentMotion {
  static const short = Duration(milliseconds: 120);
  static const medium = Duration(milliseconds: 180);
  static const long = Duration(milliseconds: 280);

  static const emphasized = Curves.easeOutCubic;
  static const standard = Curves.easeInOutCubic;
}

/// ====== Sombra/Elevación ======
class FluentShadows {
  // Sombras sutiles, coherentes con Fluent (no muy oscuras).
  static List<BoxShadow> low(Color base) => [
    BoxShadow(
      color: base.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  static List<BoxShadow> medium(Color base) => [
    BoxShadow(
      color: base.withValues(alpha: 0.10),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  static List<BoxShadow> high(Color base) => [
    BoxShadow(
      color: base.withValues(alpha: 0.12),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
  ];
}

/// Acceso rápido a tokens desde BuildContext.
extension FluentTokensX on BuildContext {
  FluentTokens get tokens => Theme.of(this).extension<FluentTokens>()!;
  BorderRadius get brXs => BorderRadius.circular(tokens.radiusXs);
  BorderRadius get brSm => BorderRadius.circular(tokens.radiusSm);
  BorderRadius get brMd => BorderRadius.circular(tokens.radiusMd);
  BorderRadius get brLg => BorderRadius.circular(tokens.radiusLg);
  BorderRadius get brXl => BorderRadius.circular(tokens.radiusXl);
}

/// ===============================
/// THEME DATA (Light / Dark)
/// ===============================

ThemeData fluentLightTheme() {
  const tokens = FluentTokens(
    accent: Color(0xFF0F6CBD), // Fluent Blue
    onAccent: Colors.white,
    bg: Color(0xFFF8F8F8),
    bg2: Color(0xFFFFFFFF),
    bg3: Color(0xFFF2F2F2),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF111111),
    stroke1: Color(0xFFE0E0E0),
    stroke2: Color(0xFFBFBFBF),
    stroke3: Color(0xFF8A8A8A),
    error: Color(0xFFD13438), // Fluent Red-ish
    onError: Colors.white,
    radiusXs: 2,
    radiusSm: 4,
    radiusMd: 8,
    radiusLg: 12,
    radiusXl: 16,
    strokeWidth: 1,
    focusStrokeWidth: 2,
  );
  return _buildTheme(brightness: Brightness.light, t: tokens);
}

ThemeData fluentDarkTheme() {
  const tokens = FluentTokens(
    accent: Color(0xFF6CA6FF), // Accent adaptado para dark
    onAccent: Colors.black, // Contraste sobre azul claro
    bg: Color(0xFF111111),
    bg2: Color(0xFF1A1A1A),
    bg3: Color(0xFF222222),
    surface: Color(0xFF1A1A1A),
    onSurface: Color(0xFFF2F2F2),
    stroke1: Color(0xFF2D2D2D),
    stroke2: Color(0xFF3A3A3A),
    stroke3: Color(0xFF5A5A5A),
    error: Color(0xFFFF6B6F),
    onError: Colors.black,
    radiusXs: 2,
    radiusSm: 4,
    radiusMd: 8,
    radiusLg: 12,
    radiusXl: 16,
    strokeWidth: 1,
    focusStrokeWidth: 2,
  );
  return _buildTheme(brightness: Brightness.dark, t: tokens);
}

ThemeData _buildTheme({
  required Brightness brightness,
  required FluentTokens t,
}) {
  final isDark = brightness == Brightness.dark;

  // ColorScheme base usando tokens
  final scheme = ColorScheme(
    brightness: brightness,
    primary: t.accent,
    onPrimary: t.onAccent,
    secondary: t.accent,
    onSecondary: t.onAccent,
    surface: t.surface,
    onSurface: t.onSurface,
    error: t.error,
    onError: t.onError,
    tertiary: t.accent,
    onTertiary: t.onAccent,
    surfaceContainerLowest: t.bg, // antes background
    surfaceContainerLow: t.bg2,
    surfaceContainer: t.bg2,
    surfaceContainerHigh: t.bg3,
    surfaceContainerHighest: t.surface,
    outline: t.stroke1,
    outlineVariant: t.stroke2,
    inverseSurface: isDark ? Colors.white : const Color(0xFF121212),
    onInverseSurface: isDark ? const Color(0xFF121212) : Colors.white,
    inversePrimary: isDark ? const Color(0xFF0F6CBD) : const Color(0xFF6CA6FF),
    scrim: Colors.black.withValues(alpha: 0.60),
  );

  // Scrollbar (desktop/web) & Selection
  final scrollbar = ScrollbarThemeData(
    thickness: const WidgetStatePropertyAll(10),
    radius: Radius.circular(t.radiusSm),
    thumbVisibility: const WidgetStatePropertyAll(true),
    interactive: true,
    thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
      final base = scheme.onSurface.withValues(alpha: 0.30);
      if (states.contains(WidgetState.hovered) ||
          states.contains(WidgetState.dragged)) {
        return scheme.onSurface.withValues(alpha: 0.45);
      }
      return base;
    }),
    trackColor: WidgetStatePropertyAll(
      scheme.onSurface.withValues(alpha: 0.06),
    ),
  );

  final selection = TextSelectionThemeData(
    cursorColor: scheme.primary,
    selectionColor: scheme.primary.withValues(alpha: 0.25),
    selectionHandleColor: scheme.primary,
  );

  // Transiciones cortas
  final transitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: const FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: const FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.linux: const FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.windows: const FadeUpwardsPageTransitionsBuilder(),
    },
  );

  // Tipografía (rampa aproximada Fluent)
  const fontFallback = <String>[
    'Segoe UI Variable',
    'Segoe UI',
    'Inter',
    'SF Pro Text',
    'Roboto',
    'Arial',
  ];
  TextTheme type = _fluentTextTheme(
    brightness,
  ).apply(fontFamilyFallback: fontFallback);

  // ===== Botones =====
  final shapeSm = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(t.radiusSm),
  );
  final focusSide = WidgetStateProperty.resolveWith<BorderSide?>((states) {
    if (states.contains(WidgetState.focused)) {
      return BorderSide(color: scheme.primary, width: t.focusStrokeWidth);
    }
    return null;
  });
  final sideStroke1 = WidgetStateProperty.resolveWith<BorderSide?>((states) {
    final base = BorderSide(color: t.stroke1, width: t.strokeWidth);
    if (states.contains(WidgetState.disabled)) {
      return base.copyWith(color: t.stroke1.withValues(alpha: 0.4));
    }
    if (states.contains(WidgetState.focused)) {
      return BorderSide(color: scheme.primary, width: t.focusStrokeWidth);
    }
    return base;
  });

  final overlay = WidgetStateProperty.resolveWith<Color?>((states) {
    if (states.contains(WidgetState.pressed)) {
      return scheme.onSurface.withValues(alpha: 0.10);
    }
    if (states.contains(WidgetState.hovered)) {
      return scheme.onSurface.withValues(alpha: 0.06);
    }
    return null;
  });

  final filledButton = FilledButtonThemeData(
    style: ButtonStyle(
      shape: WidgetStatePropertyAll(shapeSm),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: Space.s16, vertical: Space.s10),
      ),
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.primary.withValues(alpha: 0.5);
        }
        return scheme.primary;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        return t.onAccent;
      }),
      overlayColor: overlay,
      side: focusSide,
      elevation: const WidgetStatePropertyAll(0),
    ),
  );

  final outlinedButton = OutlinedButtonThemeData(
    style: ButtonStyle(
      shape: WidgetStatePropertyAll(shapeSm),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: Space.s16, vertical: Space.s10),
      ),
      side: sideStroke1,
      foregroundColor: WidgetStatePropertyAll(scheme.onSurface),
      overlayColor: overlay,
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04);
        }
        if (states.contains(WidgetState.pressed)) {
          return (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06);
        }
        return Colors.transparent;
      }),
      elevation: const WidgetStatePropertyAll(0),
    ),
  );

  final textButton = TextButtonThemeData(
    style: ButtonStyle(
      shape: WidgetStatePropertyAll(shapeSm),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: Space.s12, vertical: Space.s10),
      ),
      foregroundColor: WidgetStatePropertyAll(scheme.primary),
      overlayColor: overlay,
      elevation: const WidgetStatePropertyAll(0),
    ),
  );

  // ===== Inputs =====
  final baseBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(t.radiusSm),
    borderSide: BorderSide(color: t.stroke1, width: t.strokeWidth),
  );
  final focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(t.radiusSm),
    borderSide: BorderSide(color: scheme.primary, width: t.focusStrokeWidth),
  );
  final errorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(t.radiusSm),
    borderSide: BorderSide(color: scheme.error, width: t.focusStrokeWidth),
  );

  final inputs = InputDecorationTheme(
    isDense: true,
    filled: true,
    fillColor: t.bg2,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: Space.s12,
      vertical: Space.s10,
    ),
    border: baseBorder,
    enabledBorder: baseBorder,
    focusedBorder: focusedBorder,
    errorBorder: errorBorder,
    focusedErrorBorder: errorBorder,
    hintStyle: type.bodyMedium?.copyWith(
      color: t.onSurface.withValues(alpha: 0.6),
    ),
    labelStyle: type.bodySmall?.copyWith(
      color: t.onSurface.withValues(alpha: 0.90),
    ),
    helperStyle: type.bodySmall?.copyWith(
      color: t.onSurface.withValues(alpha: 0.70),
    ),
    errorStyle: type.bodySmall?.copyWith(color: t.error),
  );

  // ===== Cards / Contenedores =====
  final card = CardThemeData(
    elevation: 0,
    color: t.surface,
    shadowColor: scheme.shadow,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(t.radiusMd),
      side: BorderSide(color: t.stroke1, width: t.strokeWidth),
    ),
    margin: const EdgeInsets.all(Space.s12),
  );

  // ===== SnackBar =====
  final snack = SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFF1E1E1E),
    contentTextStyle: type.bodyMedium?.copyWith(color: Colors.white),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(t.radiusSm),
    ),
    insetPadding: const EdgeInsets.all(Space.s12),
  );

  // ===== Dialog =====
  final dialog = DialogThemeData(
    backgroundColor: t.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(t.radiusMd),
      side: BorderSide(color: t.stroke1),
    ),
    elevation: 0,
  );

  // ===== Progress =====
  final progress = ProgressIndicatorThemeData(
    color: scheme.primary,
    linearTrackColor: t.stroke1,
    circularTrackColor: t.stroke1,
  );

  // ===== ListTile (para listas tipo Fluent) =====
  final listTile = ListTileThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(t.radiusSm),
    ),
    selectedColor: scheme.primary,
    iconColor: scheme.onSurface.withValues(alpha: 0.8),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: Space.s12,
      vertical: Space.s4,
    ),
    tileColor: Colors.transparent,
    selectedTileColor: scheme.primary.withValues(alpha: 0.08),
  );

  // Ensamblar ThemeData
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    textTheme: type,
    scaffoldBackgroundColor: t.bg,
    canvasColor: t.bg,
    dividerColor: t.stroke1,
    focusColor: scheme.primary.withValues(alpha: 0.12),
    iconTheme: IconThemeData(color: scheme.onSurface),
    inputDecorationTheme: inputs,
    cardTheme: card, // CardThemeData
    snackBarTheme: snack,
    dialogTheme: dialog,
    progressIndicatorTheme: progress,
    listTileTheme: listTile,
    filledButtonTheme: filledButton,
    outlinedButtonTheme: outlinedButton,
    textButtonTheme: textButton,
    scrollbarTheme: scrollbar,
    textSelectionTheme: selection,
    pageTransitionsTheme: transitions,
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    splashFactory: InkSparkle.splashFactory,
    extensions: <ThemeExtension<dynamic>>[t],
  );
}

/// Tipografía basada en rampa Fluent (aproximación)

const _windowsStack = <String>['Segoe UI Variable', 'Segoe UI', 'Arial'];
const _defaultStack = <String>['Inter', 'SF Pro Text', 'Roboto', 'Arial'];

TextTheme _fluentTextTheme(Brightness b) {
  final on = b == Brightness.dark ? Colors.white : const Color(0xFF111111);
  // Rampa levemente más compacta para desktop
  return TextTheme(
    displayLarge: TextStyle(
      fontSize: 64,
      height: 80 / 64,
      fontWeight: FontWeight.w600,
      color: on,
    ),
    headlineLarge: TextStyle(
      fontSize: 36,
      height: 46 / 36,
      fontWeight: FontWeight.w600,
      color: on,
    ),
    titleLarge: TextStyle(
      fontSize: 24,
      height: 32 / 24,
      fontWeight: FontWeight.w600,
      color: on,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      height: 26 / 18,
      fontWeight: FontWeight.w600,
      color: on,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      height: 22 / 16,
      fontWeight: FontWeight.w400,
      color: on,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w400,
      color: on,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w400,
      color: on.withValues(alpha: 0.9),
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w600,
      color: on,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w600,
      color: on,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      height: 14 / 11,
      fontWeight: FontWeight.w600,
      color: on.withValues(alpha: 0.9),
    ),
  ).apply(
    fontFamilyFallback: Platform.isWindows ? _windowsStack : _defaultStack,
  );
}
