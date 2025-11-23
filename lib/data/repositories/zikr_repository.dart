import 'package:al_tadkhira/data/datasources/db_helper.dart';
import 'package:al_tadkhira/data/models/zikr.dart';

class ZikrRepository {
  final DatabaseHelper _dbHelper;

  ZikrRepository(this._dbHelper);

  Future<Zikr> create(Zikr zikr) async {
    final db = await _dbHelper.database;
    final id = await db.insert('zikr', zikr.toMap());
    return zikr.copyWith(id: id);
  }

  Future<Zikr?> read(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'zikr',
      columns: null,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Zikr.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Zikr>> readAll() async {
    final db = await _dbHelper.database;
    final orderBy = 'sort_order ASC';
    final result = await db.query('zikr', orderBy: orderBy);

    return result.map((json) => Zikr.fromMap(json)).toList();
  }

  Future<int> update(Zikr zikr) async {
    final db = await _dbHelper.database;
    return db.update(
      'zikr',
      zikr.toMap(),
      where: 'id = ?',
      whereArgs: [zikr.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('zikr', where: 'id = ?', whereArgs: [id]);
  }
}
