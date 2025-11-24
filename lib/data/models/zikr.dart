enum PrayerLink {
  none,
  fajr,
  dhuhr,
  asr,
  maghrib,
  isha,
  afterEachPrayer,
  anytime,
}

class ZikrPart {
  final int? id;
  final int? zikrId;
  final String description;
  final int target;
  final int sortOrder;

  ZikrPart({
    this.id,
    this.zikrId,
    required this.description,
    required this.target,
    this.sortOrder = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'zikr_id': zikrId,
      'description': description,
      'target': target,
      'sort_order': sortOrder,
    };
  }

  factory ZikrPart.fromMap(Map<String, dynamic> map) {
    return ZikrPart(
      id: map['id'],
      zikrId: map['zikr_id'],
      description: map['description'],
      target: map['target'] ?? 0,
      sortOrder: map['sort_order'] ?? 0,
    );
  }

  ZikrPart copyWith({
    int? id,
    int? zikrId,
    String? description,
    int? target,
    int? sortOrder,
  }) {
    return ZikrPart(
      id: id ?? this.id,
      zikrId: zikrId ?? this.zikrId,
      description: description ?? this.description,
      target: target ?? this.target,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class Zikr {
  final int? id;
  final String title;
  final String? note;
  final int dailyTarget;
  final PrayerLink prayerLink;
  final bool isMandatory;
  final int color; // ARGB int
  final bool autoIncrementAllowed;
  final int sortOrder;
  final List<ZikrPart> parts;

  Zikr({
    this.id,
    required this.title,
    this.note,
    this.dailyTarget = 0,
    this.prayerLink = PrayerLink.none,
    this.isMandatory = false,
    this.color = 0xFF2196F3, // Default blue
    this.autoIncrementAllowed = false,
    this.sortOrder = 0,
    this.parts = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'daily_target': dailyTarget,
      'prayer_link': prayerLink.index,
      'is_mandatory': isMandatory ? 1 : 0,
      'color': color,
      'auto_increment_allowed': autoIncrementAllowed ? 1 : 0,
      'sort_order': sortOrder,
    };
  }

  factory Zikr.fromMap(
    Map<String, dynamic> map, {
    List<ZikrPart> parts = const [],
  }) {
    return Zikr(
      id: map['id'],
      title: map['title'],
      note: map['note'],
      dailyTarget: map['daily_target'] ?? 0,
      prayerLink: PrayerLink.values[map['prayer_link'] ?? 0],
      isMandatory: map['is_mandatory'] == 1,
      color: map['color'] ?? 0xFF2196F3,
      autoIncrementAllowed: map['auto_increment_allowed'] == 1,
      sortOrder: map['sort_order'] ?? 0,
      parts: parts,
    );
  }

  Zikr copyWith({
    int? id,
    String? title,
    String? note,
    int? dailyTarget,
    PrayerLink? prayerLink,
    bool? isMandatory,
    int? color,
    bool? autoIncrementAllowed,
    int? sortOrder,
    List<ZikrPart>? parts,
  }) {
    return Zikr(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      prayerLink: prayerLink ?? this.prayerLink,
      isMandatory: isMandatory ?? this.isMandatory,
      color: color ?? this.color,
      autoIncrementAllowed: autoIncrementAllowed ?? this.autoIncrementAllowed,
      sortOrder: sortOrder ?? this.sortOrder,
      parts: parts ?? this.parts,
    );
  }
}
