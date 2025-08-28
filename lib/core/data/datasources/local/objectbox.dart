import 'package:gym_genius/core/data/datasources/local/objectbox.g.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// A class that initializes the ObjectBox database.
class Objectbox {
  /// Constructor for the [Objectbox] class.
  factory Objectbox() => _instance;

  /// Private constructor for the [Objectbox] class.
  Objectbox._internal();

  /// The instance of the [Objectbox] class.
  static final _instance = Objectbox._internal();

  /// The store for the [Objectbox] class.
  late final Store _store;

  /// The store for the [Objectbox] class.
  Store get store => _store;

  /// Initializes the [Objectbox] class.
  static Future<Objectbox> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(appDir.path, 'auth-db');
    _instance._store = await openStore(
      directory: dbPath,
      macosApplicationGroup: 'group.cha.mobile',
    );

    final db = Objectbox._internal();
    return db;
  }
}
