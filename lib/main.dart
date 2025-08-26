import 'package:flutter/widgets.dart';
import 'package:gym_genius/app.dart';
import 'package:gym_genius/core/data/datasources/local/objectbox.dart';
import 'package:gym_genius/core/network/dio_service.dart';
import 'package:gym_genius/di.dart';

/// Here we might introduce [LaunchingType] that would register different
/// instances of services.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Objectbox.init();
  await DioService().init();

  setUpLocator(LaunchingType.development);

  runApp(const MainApp());
}
