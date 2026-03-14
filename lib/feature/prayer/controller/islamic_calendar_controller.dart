import 'package:get/get.dart';
import 'package:hijri/hijri_calendar.dart';
import '../model/hijri_special_day_model.dart';
import '../services/islamic_misc_service.dart';
import 'dart:developer' as developer;

class IslamicCalendarController extends GetxController {
  final IslamicMiscService _miscService = IslamicMiscService();

  final RxList<HijriSpecialDayModel> specialDays = <HijriSpecialDayModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt currentHijriYear = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final hDate = HijriCalendar.now();
    currentHijriYear.value = hDate.hYear;
    fetchSpecialDays(currentHijriYear.value);
  }

  Future<void> fetchSpecialDays(int year) async {
    try {
      isLoading(true);
      final days = await _miscService.getHijriSpecialDays(year);
      specialDays.assignAll(days);
      currentHijriYear.value = year;
    } catch (e) {
      developer.log('Error in IslamicCalendarController.fetchSpecialDays: $e');
    } finally {
      isLoading(false);
    }
  }

  List<HijriSpecialDayModel> getEventsForDay(DateTime day) {
    return specialDays.where((event) {
      final eventDate = event.gregorian.toDateTime();
      return eventDate.year == day.year &&
          eventDate.month == day.month &&
          eventDate.day == day.day;
    }).toList();
  }

  void onFocusedDayChanged(DateTime focusedDay) {
    final hDate = HijriCalendar.fromDate(focusedDay);
    if (hDate.hYear != currentHijriYear.value) {
      fetchSpecialDays(hDate.hYear);
    }
  }
}
