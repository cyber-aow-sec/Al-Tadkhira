import 'package:al_tadkhira/data/datasources/db_helper.dart';
import 'package:al_tadkhira/data/models/zikr_history.dart';

class HistoryRepository {
  final DatabaseHelper _dbHelper;

  HistoryRepository(this._dbHelper);

  Future<ZikrHistory> log(ZikrHistory history) async {
    final db = await _dbHelper.database;
    final id = await db.insert('zikr_history', history.toMap());
    return ZikrHistory(
      id: id,
      zikrId: history.zikrId,
      count: history.count,
      timestamp: history.timestamp,
      source: history.source,
    );
  }

  Future<List<ZikrHistory>> getForDay(DateTime date) async {
    final db = await _dbHelper.database;
    final startOfDay = DateTime(
      date.year,
      date.month,
      date.day,
    ).toIso8601String();
    final endOfDay = DateTime(
      date.year,
      date.month,
      date.day,
      23,
      59,
      59,
    ).toIso8601String();

    final result = await db.query(
      'zikr_history',
      where: 'timestamp >= ? AND timestamp <= ?',
      whereArgs: [startOfDay, endOfDay],
    );

    return result.map((json) => ZikrHistory.fromMap(json)).toList();
  }

  Future<int> getCountForZikrToday(int zikrId, DateTime date) async {
    final db = await _dbHelper.database;
    final startOfDay = DateTime(
      date.year,
      date.month,
      date.day,
    ).toIso8601String();
    final endOfDay = DateTime(
      date.year,
      date.month,
      date.day,
      23,
      59,
      59,
    ).toIso8601String();

    final result = await db.rawQuery(
      '''
      SELECT SUM(count) as total 
      FROM zikr_history 
      WHERE zikr_id = ? AND timestamp >= ? AND timestamp <= ?
    ''',
      [zikrId, startOfDay, endOfDay],
    );

    if (result.isNotEmpty && result.first['total'] != null) {
      return result.first['total'] as int;
    }
    return 0;
  }

  Future<Map<int, int>> getAllCountsForToday(DateTime date) async {
    final db = await _dbHelper.database;
    final startOfDay = DateTime(
      date.year,
      date.month,
      date.day,
    ).toIso8601String();
    final endOfDay = DateTime(
      date.year,
      date.month,
      date.day,
      23,
      59,
      59,
    ).toIso8601String();

    final result = await db.rawQuery(
      '''
      SELECT zikr_id, SUM(count) as total 
      FROM zikr_history 
      WHERE timestamp >= ? AND timestamp <= ?
      GROUP BY zikr_id
    ''',
      [startOfDay, endOfDay],
    );

    final Map<int, int> counts = {};
    for (var row in result) {
      counts[row['zikr_id'] as int] = row['total'] as int;
    }
    return counts;
  }
}
