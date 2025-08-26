// No point documenting those members.
// ignore_for_file: public_member_api_docs
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.primaryLight,
    required this.accent,
    required this.secondary,
    required this.secondaryLabel,
    required this.inactive,
    required this.white,
    required this.danger,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
  });

  final Color primary;
  final Color primaryLight;
  final Color accent;

  final Color secondary;
  final Color secondaryLabel;
  final Color inactive;
  final Color white;
  final Color danger;

  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;

  static const light = AppColors(
    primary: Color(0xFFFF6E00),
    primaryLight: Colors.amber,
    accent: Color.fromARGB(255, 0, 122, 255),
    secondary: Colors.white,
    secondaryLabel: CupertinoColors.secondaryLabel,
    inactive: CupertinoColors.inactiveGray,
    white: Colors.white,
    danger: Color(0xFFD32F2F),
    surface: Colors.white,
    onSurface: Colors.black,
    surfaceVariant: Color(0xFFEEEEEE),
    onSurfaceVariant: Colors.black,
  );

  static const dark = AppColors(
    primary: Color(0xFFFF6E00),
    primaryLight: Colors.amber,
    accent: Color.fromARGB(255, 10, 132, 255),
    secondary: Color(0xFF121212),
    secondaryLabel: CupertinoColors.secondaryLabel,
    inactive: CupertinoColors.inactiveGray,
    white: Colors.white,
    danger: Color(0xFFD32F2F),
    surface: Color(0xFF1E1E1E),
    onSurface: Colors.white,
    surfaceVariant: Color(0xFF2A2A2A),
    onSurfaceVariant: Colors.white,
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? primaryLight,
    Color? accent,
    Color? secondary,
    Color? secondaryLabel,
    Color? inactive,
    Color? white,
    Color? danger,
    Color? success,
    Color? warning,
    Color? info,
    Color? surface,
    Color? onSurface,
    Color? surfaceVariant,
    Color? onSurfaceVariant,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      accent: accent ?? this.accent,
      secondary: secondary ?? this.secondary,
      secondaryLabel: secondaryLabel ?? this.secondaryLabel,
      inactive: inactive ?? this.inactive,
      white: white ?? this.white,
      danger: danger ?? this.danger,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;

    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondaryLabel: Color.lerp(secondaryLabel, other.secondaryLabel, t)!,
      inactive: Color.lerp(inactive, other.inactive, t)!,
      white: Color.lerp(white, other.white, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      onSurfaceVariant:
          Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
    );
  }
}
