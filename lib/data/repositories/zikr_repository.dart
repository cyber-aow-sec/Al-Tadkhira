import 'package:al_tadkhira/data/datasources/db_helper.dart';
import 'package:al_tadkhira/data/models/zikr.dart';

class ZikrRepository {
  final DatabaseHelper _dbHelper;

  ZikrRepository(this._dbHelper);

  Future<Zikr> create(Zikr zikr) async {
    final db = await _dbHelper.database;
    return await db.transaction((txn) async {
      final id = await txn.insert('zikr', zikr.toMap());

      if (zikr.parts.isNotEmpty) {
        for (var part in zikr.parts) {
          await txn.insert('zikr_parts', part.copyWith(zikrId: id).toMap());
        }
      }

      // Return with ID and parts (with updated zikrId if we wanted, but parts in memory are fine)
      // Actually, we should return the object as saved.
      // Let's just return the input zikr with the new ID.
      return zikr.copyWith(id: id);
    });
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
      final zikrMap = maps.first;
      final partsMaps = await db.query(
        'zikr_parts',
        where: 'zikr_id = ?',
        whereArgs: [id],
        orderBy: 'sort_order ASC',
      );

      final parts = partsMaps.map((m) => ZikrPart.fromMap(m)).toList();
      return Zikr.fromMap(zikrMap, parts: parts);
    } else {
      return null;
    }
  }

  Future<List<Zikr>> readAll() async {
    final db = await _dbHelper.database;
    final orderBy = 'sort_order ASC';
    final result = await db.query('zikr', orderBy: orderBy);

    // For each zikr, fetch parts.
    // Optimization: Fetch all parts and map them in memory if list is large,
    // but for this app, N+1 is acceptable.
    List<Zikr> zikrs = [];
    for (var map in result) {
      final id = map['id'] as int;
      final partsMaps = await db.query(
        'zikr_parts',
        where: 'zikr_id = ?',
        whereArgs: [id],
        orderBy: 'sort_order ASC',
      );
      final parts = partsMaps.map((m) => ZikrPart.fromMap(m)).toList();
      zikrs.add(Zikr.fromMap(map, parts: parts));
    }
    return zikrs;
  }

  Future<int> update(Zikr zikr) async {
    final db = await _dbHelper.database;
    return await db.transaction((txn) async {
      final count = await txn.update(
        'zikr',
        zikr.toMap(),
        where: 'id = ?',
        whereArgs: [zikr.id],
      );

      // Replace parts
      await txn.delete(
        'zikr_parts',
        where: 'zikr_id = ?',
        whereArgs: [zikr.id],
      );

      if (zikr.parts.isNotEmpty) {
        for (var part in zikr.parts) {
          await txn.insert(
            'zikr_parts',
            part.copyWith(zikrId: zikr.id).toMap(),
          );
        }
      }

      return count;
    });
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('zikr', where: 'id = ?', whereArgs: [id]);
  }
}
