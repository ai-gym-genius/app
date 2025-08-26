import 'package:flutter/material.dart';

import 'package:gym_genius/theme/tokens/colors.dart';
import 'package:gym_genius/theme/tokens/text.dart';

/// Extension for easier theme-related objects access.
extension AppThemeX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  AppTextStyles get txt => Theme.of(this).extension<AppTextStyles>()!;
}
