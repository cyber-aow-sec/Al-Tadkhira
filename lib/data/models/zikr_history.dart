class ZikrHistory {
  final int? id;
  final int zikrId;
  final int count;
  final DateTime timestamp;
  final String source; // 'manual', 'auto', 'imported'

  ZikrHistory({
    this.id,
    required this.zikrId,
    required this.count,
    required this.timestamp,
    this.source = 'manual',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'zikr_id': zikrId,
      'count': count,
      'timestamp': timestamp.toIso8601String(),
      'source': source,
    };
  }

  factory ZikrHistory.fromMap(Map<String, dynamic> map) {
    return ZikrHistory(
      id: map['id'],
      zikrId: map['zikr_id'],
      count: map['count'],
      timestamp: DateTime.parse(map['timestamp']),
      source: map['source'] ?? 'manual',
    );
  }
}
