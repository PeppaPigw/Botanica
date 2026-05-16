class PlantMeta {
  const PlantMeta({
    this.potDiameterCm,
    this.soilType,
    this.lightLevel,
    this.lastRepotDate,
    this.lastFertilizeDate,
    this.lastAnniversaryShown,
  });

  final double? potDiameterCm;
  final String? soilType;
  final String? lightLevel;
  final DateTime? lastRepotDate;
  final DateTime? lastFertilizeDate;
  final DateTime? lastAnniversaryShown;

  static const Object _unset = Object();

  PlantMeta copyWith({
    Object? potDiameterCm = _unset,
    Object? soilType = _unset,
    Object? lightLevel = _unset,
    Object? lastRepotDate = _unset,
    Object? lastFertilizeDate = _unset,
    Object? lastAnniversaryShown = _unset,
  }) {
    return PlantMeta(
      potDiameterCm: identical(potDiameterCm, _unset)
          ? this.potDiameterCm
          : potDiameterCm as double?,
      soilType:
          identical(soilType, _unset) ? this.soilType : soilType as String?,
      lightLevel: identical(lightLevel, _unset)
          ? this.lightLevel
          : lightLevel as String?,
      lastRepotDate: identical(lastRepotDate, _unset)
          ? this.lastRepotDate
          : lastRepotDate as DateTime?,
      lastFertilizeDate: identical(lastFertilizeDate, _unset)
          ? this.lastFertilizeDate
          : lastFertilizeDate as DateTime?,
      lastAnniversaryShown: identical(lastAnniversaryShown, _unset)
          ? this.lastAnniversaryShown
          : lastAnniversaryShown as DateTime?,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PlantMeta &&
      other.potDiameterCm == potDiameterCm &&
      other.soilType == soilType &&
      other.lightLevel == lightLevel &&
      other.lastRepotDate == lastRepotDate &&
      other.lastFertilizeDate == lastFertilizeDate &&
      other.lastAnniversaryShown == lastAnniversaryShown;

  @override
  int get hashCode => Object.hash(
        potDiameterCm,
        soilType,
        lightLevel,
        lastRepotDate,
        lastFertilizeDate,
        lastAnniversaryShown,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'potDiameterCm': potDiameterCm,
        'soilType': soilType,
        'lightLevel': lightLevel,
        'lastRepotDate': lastRepotDate?.toIso8601String(),
        'lastFertilizeDate': lastFertilizeDate?.toIso8601String(),
        'lastAnniversaryShown': lastAnniversaryShown?.toIso8601String(),
      };

  static PlantMeta fromJson(Map<String, dynamic> json) => PlantMeta(
        potDiameterCm: (json['potDiameterCm'] as num?)?.toDouble(),
        soilType: json['soilType'] as String?,
        lightLevel: json['lightLevel'] as String?,
        lastRepotDate: json['lastRepotDate'] == null
            ? null
            : DateTime.tryParse(json['lastRepotDate'] as String),
        lastFertilizeDate: json['lastFertilizeDate'] == null
            ? null
            : DateTime.tryParse(json['lastFertilizeDate'] as String),
        lastAnniversaryShown: json['lastAnniversaryShown'] == null
            ? null
            : DateTime.tryParse(json['lastAnniversaryShown'] as String),
      );
}
