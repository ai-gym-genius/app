import 'package:gym_genius/core/data/datasources/local/objectbox.g.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class Objectbox {
  factory Objectbox() => _instance;
  Objectbox._internal();
  static final _instance = Objectbox._internal();

  late final Store _store;
  Store get store => _store;

  static Future<Objectbox> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(appDir.path, 'auth-db');
    _instance._store = await openStore(
        directory: dbPath, macosApplicationGroup: 'group.cha.mobile');

    final db = Objectbox._internal();
    return db;
  }
}
