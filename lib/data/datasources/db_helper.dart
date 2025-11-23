import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('al_tadkhira.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL'; // 0 or 1
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE zikr (
  id $idType,
  title $textType,
  note TEXT,
  daily_target $integerType,
  prayer_link $integerType,
  is_mandatory $boolType,
  color $integerType,
  auto_increment_allowed $boolType,
  sort_order $integerType
)
''');

    await db.execute('''
CREATE TABLE zikr_history (
  id $idType,
  zikr_id $integerType,
  count $integerType,
  timestamp $textType,
  source $textType,
  FOREIGN KEY (zikr_id) REFERENCES zikr (id) ON DELETE CASCADE
)
''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
