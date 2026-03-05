double clamp01(double value) => value < 0 ? 0 : (value > 1 ? 1 : value);

class DrynessIndex {
  const DrynessIndex._();

  /// Returns a value in the range [0,1].
  ///
  /// A higher index indicates conditions where soil tends to dry faster.
  static double compute({
    required double tempC,
    required int humidityPercent,
  }) {
    final normalizedTemp = clamp01((tempC - 10) / 25); // ~10..35°C
    final normalizedHumidity = clamp01(humidityPercent / 100.0);

    // Temperature affects evaporation; humidity affects how quickly moisture
    // leaves both soil and leaves. Weight humidity slightly higher.
    final dryness = (normalizedTemp * 0.45) + ((1 - normalizedHumidity) * 0.55);

    return clamp01(dryness);
  }
}
