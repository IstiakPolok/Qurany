class HijriSpecialDayModel {
  final String name;
  final int hijriMonth;
  final String hijriMonthName;
  final int hijriDay;
  final GregorianDate gregorian;

  HijriSpecialDayModel({
    required this.name,
    required this.hijriMonth,
    required this.hijriMonthName,
    required this.hijriDay,
    required this.gregorian,
  });

  factory HijriSpecialDayModel.fromJson(Map<String, dynamic> json) {
    return HijriSpecialDayModel(
      name: json['name'],
      hijriMonth: json['hijri_month'],
      hijriMonthName: json['hijri_month_name'],
      hijriDay: json['hijri_day'],
      gregorian: GregorianDate.fromJson(json['gregorian']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'hijri_month': hijriMonth,
      'hijri_month_name': hijriMonthName,
      'hijri_day': hijriDay,
      'gregorian': gregorian.toJson(),
    };
  }
}

class GregorianDate {
  final String date;
  final String day;
  final int month;
  final String year;

  GregorianDate({
    required this.date,
    required this.day,
    required this.month,
    required this.year,
  });

  factory GregorianDate.fromJson(Map<String, dynamic> json) {
    return GregorianDate(
      date: json['date'],
      day: json['day'],
      month: json['month'],
      year: json['year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'day': day,
      'month': month,
      'year': year,
    };
  }

  DateTime toDateTime() {
    return DateTime.parse('${year}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}');
  }
}
