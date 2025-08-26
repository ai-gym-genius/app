// No point documenting theme.
// ignore_for_file: public_member_api_docs
import 'package:flutter/material.dart';

@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  const AppTextStyles({
    required this.display,
    required this.headline,
    required this.title,
    required this.body,
    required this.bodySmall,
    required this.label,
    required this.labelSmall,
  });

  factory AppTextStyles.fromScheme(ColorScheme s, TextTheme base) {
    return AppTextStyles(
      // Big screens titles like "Statistics"
      display: _montserrat(
        size: base.displayLarge?.fontSize ?? 34,
        weight: 820,
        color: s.onSurface,
        height: 1.1,
      ),

      // Screen/page titles ("Your Exercises", "Create Account")
      headline: _montserrat(
        size: base.headlineMedium?.fontSize ?? 28,
        weight: 720,
        color: s.onSurface,
        height: 1.15,
      ),

      // Section/exercise titles
      title: _montserrat(
        size: base.titleMedium?.fontSize ?? 16,
        weight: 620,
        color: s.onSurface,
        height: 1.2,
      ),

      // Body text
      body: _montserrat(
        size: base.bodyMedium?.fontSize ?? 16,
        weight: 420,
        color: s.onSurfaceVariant,
        height: 1.35,
      ),

      // Secondary body / subtitles
      bodySmall: _montserrat(
        size: base.bodySmall?.fontSize ?? 13,
        weight: 400,
        color: s.onSurfaceVariant,
        height: 1.3,
      ),

      // Buttons/inputs
      label: _montserrat(
        size: base.labelLarge?.fontSize ?? 16,
        weight: 600,
        color: s.onSurface,
        height: 1.2,
      ),

      // Captions/axes
      labelSmall: _montserrat(
        size: base.labelSmall?.fontSize ?? 10,
        weight: 500,
        color: s.onSurfaceVariant,
        height: 1.2,
      ),
    );
  }

  final TextStyle display;
  final TextStyle headline;
  final TextStyle title;
  final TextStyle body;
  final TextStyle bodySmall;
  final TextStyle label;
  final TextStyle labelSmall;

  @override
  AppTextStyles copyWith({
    TextStyle? display,
    TextStyle? headline,
    TextStyle? title,
    TextStyle? body,
    TextStyle? bodySmall,
    TextStyle? label,
    TextStyle? labelSmall,
  }) {
    return AppTextStyles(
      display: display ?? this.display,
      headline: headline ?? this.headline,
      title: title ?? this.title,
      body: body ?? this.body,
      bodySmall: bodySmall ?? this.bodySmall,
      label: label ?? this.label,
      labelSmall: labelSmall ?? this.labelSmall,
    );
  }

  @override
  AppTextStyles lerp(ThemeExtension<AppTextStyles>? other, double t) {
    if (other is! AppTextStyles) return this;
    return AppTextStyles(
      display: TextStyle.lerp(display, other.display, t)!,
      headline: TextStyle.lerp(headline, other.headline, t)!,
      title: TextStyle.lerp(title, other.title, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      label: TextStyle.lerp(label, other.label, t)!,
      labelSmall: TextStyle.lerp(labelSmall, other.labelSmall, t)!,
    );
  }

  // Helper to create Montserrat variable weights with fallback
  static TextStyle _montserrat({
    required double size,
    required double weight, // 100..900
    Color? color,
    FontStyle style = FontStyle.normal,
    double? height,
    double? letterSpacing,
  }) {
    // snap to nearest 100 for fallback
    final snapped = (weight / 100).clamp(1, 9).round() * 100;

    FontWeight fw(int w) => switch (w) {
          100 => FontWeight.w100,
          200 => FontWeight.w200,
          300 => FontWeight.w300,
          400 => FontWeight.w400,
          500 => FontWeight.w500,
          600 => FontWeight.w600,
          700 => FontWeight.w700,
          800 => FontWeight.w800,
          900 => FontWeight.w900,
          _ => FontWeight.normal,
        };

    return TextStyle(
      fontFamily: 'Montserrat',
      fontStyle: style,
      fontSize: size,
      fontWeight: fw(snapped),
      fontVariations: [FontVariation('wght', weight)],
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}
