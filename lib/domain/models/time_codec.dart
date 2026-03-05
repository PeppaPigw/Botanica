int encodeUtcMillis(DateTime dateTime) =>
    dateTime.toUtc().millisecondsSinceEpoch;

DateTime decodeUtcMillis(int utcMillis) =>
    DateTime.fromMillisecondsSinceEpoch(utcMillis, isUtc: true);
