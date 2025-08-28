import 'package:flutter/material.dart';

import 'package:gym_genius/theme/tokens/colors.dart';
import 'package:gym_genius/theme/tokens/text.dart';

/// Extension for easier theme-related objects access.
extension AppThemeX on BuildContext {
  /// App's predefined [Color]s.
  AppColors get colors => Theme.of(this).extension<AppColors>()!;

  /// App's predefined [TextStyle]s.
  AppTextStyles get txt => Theme.of(this).extension<AppTextStyles>()!;
}
