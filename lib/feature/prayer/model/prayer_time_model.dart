class PrayerTimeModel {
  final Map<String, String> times;
  final PrayerDate date;
  final QiblaInfo qibla;
  final Map<String, ProhibitedTime> prohibitedTimes;
  final TimezoneInfo timezone;

  PrayerTimeModel({
    required this.times,
    required this.date,
    required this.qibla,
    required this.prohibitedTimes,
    required this.timezone,
  });

  factory PrayerTimeModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    return PrayerTimeModel(
      times: Map<String, String>.from(data['times'] as Map<String, dynamic>),
      date: PrayerDate.fromJson(data['date'] as Map<String, dynamic>),
      qibla: QiblaInfo.fromJson(data['qibla'] as Map<String, dynamic>),
      prohibitedTimes: (data['prohibited_times'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          ProhibitedTime.fromJson(value as Map<String, dynamic>),
        ),
      ),
      timezone: TimezoneInfo.fromJson(data['timezone'] as Map<String, dynamic>),
    );
  }
}

class PrayerDate {
  final String readable;
  final String timestamp;
  final HijriDate hijri;
  final GregorianDate gregorian;

  PrayerDate({
    required this.readable,
    required this.timestamp,
    required this.hijri,
    required this.gregorian,
  });

  factory PrayerDate.fromJson(Map<String, dynamic> json) {
    return PrayerDate(
      readable: json['readable'] as String,
      timestamp: json['timestamp'] as String,
      hijri: HijriDate.fromJson(json['hijri'] as Map<String, dynamic>),
      gregorian: GregorianDate.fromJson(
        json['gregorian'] as Map<String, dynamic>,
      ),
    );
  }
}

class HijriDate {
  final String date;
  final String day;
  final Map<String, String> weekday;
  final HijriMonth month;
  final String year;

  HijriDate({
    required this.date,
    required this.day,
    required this.weekday,
    required this.month,
    required this.year,
  });

  factory HijriDate.fromJson(Map<String, dynamic> json) {
    return HijriDate(
      date: json['date'] as String,
      day: json['day'] as String,
      weekday: Map<String, String>.from(
        json['weekday'] as Map<String, dynamic>,
      ),
      month: HijriMonth.fromJson(json['month'] as Map<String, dynamic>),
      year: json['year'] as String,
    );
  }
}

class HijriMonth {
  final int number;
  final String en;
  final String ar;
  final int days;

  HijriMonth({
    required this.number,
    required this.en,
    required this.ar,
    required this.days,
  });

  factory HijriMonth.fromJson(Map<String, dynamic> json) {
    return HijriMonth(
      number: json['number'] as int,
      en: json['en'] as String,
      ar: json['ar'] as String,
      days: json['days'] as int,
    );
  }
}

class GregorianDate {
  final String date;
  final String day;
  final Map<String, String> weekday;
  final GregorianMonth month;
  final String year;

  GregorianDate({
    required this.date,
    required this.day,
    required this.weekday,
    required this.month,
    required this.year,
  });

  factory GregorianDate.fromJson(Map<String, dynamic> json) {
    return GregorianDate(
      date: json['date'] as String,
      day: json['day'] as String,
      weekday: Map<String, String>.from(
        json['weekday'] as Map<String, dynamic>,
      ),
      month: GregorianMonth.fromJson(json['month'] as Map<String, dynamic>),
      year: json['year'] as String,
    );
  }
}

class GregorianMonth {
  final int number;
  final String en;

  GregorianMonth({required this.number, required this.en});

  factory GregorianMonth.fromJson(Map<String, dynamic> json) {
    return GregorianMonth(
      number: json['number'] as int,
      en: json['en'] as String,
    );
  }
}

class QiblaInfo {
  final QiblaDirection direction;
  final QiblaDistance distance;

  QiblaInfo({required this.direction, required this.distance});

  factory QiblaInfo.fromJson(Map<String, dynamic> json) {
    return QiblaInfo(
      direction: QiblaDirection.fromJson(
        json['direction'] as Map<String, dynamic>,
      ),
      distance: QiblaDistance.fromJson(
        json['distance'] as Map<String, dynamic>,
      ),
    );
  }
}

class QiblaDirection {
  final double degrees;
  final String from;
  final bool clockwise;

  QiblaDirection({
    required this.degrees,
    required this.from,
    required this.clockwise,
  });

  factory QiblaDirection.fromJson(Map<String, dynamic> json) {
    return QiblaDirection(
      degrees: (json['degrees'] as num).toDouble(),
      from: json['from'] as String,
      clockwise: json['clockwise'] as bool,
    );
  }
}

class QiblaDistance {
  final double value;
  final String unit;

  QiblaDistance({required this.value, required this.unit});

  factory QiblaDistance.fromJson(Map<String, dynamic> json) {
    return QiblaDistance(
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
    );
  }
}

class ProhibitedTime {
  final String start;
  final String end;

  ProhibitedTime({required this.start, required this.end});

  factory ProhibitedTime.fromJson(Map<String, dynamic> json) {
    return ProhibitedTime(
      start: json['start'] as String,
      end: json['end'] as String,
    );
  }
}

class TimezoneInfo {
  final String name;
  final String utcOffset;
  final String abbreviation;

  TimezoneInfo({
    required this.name,
    required this.utcOffset,
    required this.abbreviation,
  });

  factory TimezoneInfo.fromJson(Map<String, dynamic> json) {
    return TimezoneInfo(
      name: json['name'] as String,
      utcOffset: json['utc_offset'] as String,
      abbreviation: json['abbreviation'] as String,
    );
  }
}
