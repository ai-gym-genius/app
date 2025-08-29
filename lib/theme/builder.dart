import 'package:flutter/material.dart';

import 'package:gym_genius/theme/tokens/colors.dart';
import 'package:gym_genius/theme/tokens/text.dart';

/// Builder that adjusts for brightness.
ThemeData buildTheme({
  required Brightness brightness,
  required AppColors colors,
}) {
  final scheme = ColorScheme(
    primary: colors.primary,
    onPrimary: Colors.black,
    secondary: colors.secondary,
    onSecondary: colors.onSurface,
    error: colors.danger,
    onError: colors.onSurface,
    surface: colors.surface,
    onSurface: colors.onSurface,
    brightness: brightness,
  );

  final base = ThemeData(
    brightness: brightness,
    useMaterial3: true,
  );

  final textTokens = AppTextStyles.fromScheme(
    scheme,
    base.textTheme,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    textTheme: base.textTheme,
    extensions: [
      colors,
      textTokens,
    ],
  );
}
