/// A timezone-less time-of-day value intended for scheduling UI preferences.
///
/// Keep this separate from Flutter's `TimeOfDay` so domain logic stays usable
/// from pure Dart tests and non-Flutter layers.
class LocalTime {
  final int hour;
  final int minute;

  const LocalTime({
    required this.hour,
    required this.minute,
  })  : assert(hour >= 0 && hour <= 23),
        assert(minute >= 0 && minute <= 59);

  int get minutesSinceMidnight => (hour * 60) + minute;

  static LocalTime fromMinutesSinceMidnight(int value) {
    if (value < 0 || value >= 24 * 60) {
      throw RangeError.range(value, 0, 24 * 60 - 1, 'value');
    }
    return LocalTime(hour: value ~/ 60, minute: value % 60);
  }

  @override
  String toString() => '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      other is LocalTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);
}
