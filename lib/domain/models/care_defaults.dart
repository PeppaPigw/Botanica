class CareDefaults {
  const CareDefaults({
    required this.waterBaseDays,
    required this.fertilizeBaseDays,
    required this.mistBaseDays,
    required this.rotateBaseDays,
    required this.pruneBaseDays,
  });

  final int waterBaseDays;
  final int fertilizeBaseDays;
  final int mistBaseDays;
  final int rotateBaseDays;
  final int pruneBaseDays;

  static const CareDefaults empty = CareDefaults(
    waterBaseDays: 7,
    fertilizeBaseDays: 30,
    mistBaseDays: 0,
    rotateBaseDays: 14,
    pruneBaseDays: 90,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'waterBaseDays': waterBaseDays,
        'fertilizeBaseDays': fertilizeBaseDays,
        'mistBaseDays': mistBaseDays,
        'rotateBaseDays': rotateBaseDays,
        'pruneBaseDays': pruneBaseDays,
      };

  static CareDefaults fromJson(Map<String, dynamic> json) => CareDefaults(
        waterBaseDays: (json['waterBaseDays'] as num?)?.toInt() ?? 7,
        fertilizeBaseDays: (json['fertilizeBaseDays'] as num?)?.toInt() ?? 30,
        mistBaseDays: (json['mistBaseDays'] as num?)?.toInt() ?? 0,
        rotateBaseDays: (json['rotateBaseDays'] as num?)?.toInt() ?? 14,
        pruneBaseDays: (json['pruneBaseDays'] as num?)?.toInt() ?? 90,
      );
}
