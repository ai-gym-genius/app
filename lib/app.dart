import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gym_genius/config/routes.dart' show routes;
import 'package:gym_genius/theme/builder.dart';
import 'package:gym_genius/theme/tokens/colors.dart';

/// Application entry point.
class MainApp extends StatelessWidget {
  /// no-doc.
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      theme: buildTheme(
        brightness: Brightness.light,
        colors: AppColors.light,
      ),
      darkTheme: buildTheme(
        brightness: Brightness.dark,
        colors: AppColors.dark,
      ),
      initialRoute: '/',
      routes: routes,
    );
  }
}
