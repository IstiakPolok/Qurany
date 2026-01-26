import 'dart:async';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/services/location_service.dart';
import '../model/prayer_time_model.dart';
import '../services/prayer_service.dart';

class PrayerController extends GetxController {
  final PrayerService _prayerService = PrayerService();
  final LocationService _locationService = Get.find<LocationService>();

  final Rx<PrayerTimeModel?> prayerData = Rx<PrayerTimeModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final Rx<DateTime> currentTime = DateTime.now().obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _startTimer();
    _loadPrayerTimes();

    // Listen to location changes
    ever(_locationService.currentPosition, (position) {
      if (position != null) {
        _loadPrayerTimes();
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      currentTime.value = DateTime.now();
    });
  }

  Future<void> _loadPrayerTimes() async {
    final position = _locationService.currentPosition.value;

    if (position == null) {
      print('Location not available, waiting...');
      return;
    }

    try {
      isLoading(true);
      error('');

      final data = await _prayerService.getPrayerTimes(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (data != null) {
        prayerData.value = data;
        print('Prayer times loaded successfully');
        print('Qibla direction: ${data.qibla.direction.degrees}°');
        print(
          'Distance to Makkah: ${data.qibla.distance.value} ${data.qibla.distance.unit}',
        );
      } else {
        error('Failed to load prayer times');
        print('Failed to load prayer times from API');
      }
    } catch (e) {
      error('Error loading prayer times: $e');
      print('Error in _loadPrayerTimes: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> refreshPrayerTimes() async {
    await _loadPrayerTimes();
  }

  String getNextPrayerName() {
    final data = prayerData.value;
    if (data == null) return 'Fajr';

    final now = currentTime.value;
    final currentTimeStr = DateFormat('HH:mm').format(now);

    final prayerTimes = [
      {'name': 'Fajr', 'time': data.times['Fajr'] ?? '00:00'},
      {'name': 'Dhuhr', 'time': data.times['Dhuhr'] ?? '00:00'},
      {'name': 'Asr', 'time': data.times['Asr'] ?? '00:00'},
      {'name': 'Maghrib', 'time': data.times['Maghrib'] ?? '00:00'},
      {'name': 'Isha', 'time': data.times['Isha'] ?? '00:00'},
    ];

    for (int i = 0; i < prayerTimes.length; i++) {
      final prayerTime = prayerTimes[i]['time']!;
      if (_isTimeBefore(currentTimeStr, prayerTime)) {
        return prayerTimes[i]['name']!;
      }
    }

    // If all prayers have passed, next is tomorrow's Fajr
    return 'Fajr';
  }

  String getTimeRemaining() {
    final data = prayerData.value;
    if (data == null) return '00:00:00';

    final now = currentTime.value;
    final nextPrayerName = getNextPrayerName();
    String? nextPrayerTime = data.times[nextPrayerName];

    if (nextPrayerTime == null) return '00:00:00';

    try {
      final todayDateStr = DateFormat('yyyy-MM-dd').format(now);
      final nextPrayerDateTime = DateFormat(
        'yyyy-MM-dd HH:mm',
      ).parse('$todayDateStr $nextPrayerTime');

      // If the prayer time has passed today, it's for tomorrow
      DateTime targetDateTime = nextPrayerDateTime;
      if (nextPrayerDateTime.isBefore(now)) {
        targetDateTime = nextPrayerDateTime.add(const Duration(days: 1));
      }

      final difference = targetDateTime.difference(now);

      if (difference.isNegative) return '00:00:00';

      final hours = difference.inHours;
      final minutes = (difference.inMinutes % 60);
      final seconds = (difference.inSeconds % 60);

      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } catch (e) {
      print('Error calculating time remaining: $e');
      return '00:00:00';
    }
  }

  bool _isTimeBefore(String time1, String time2) {
    try {
      final parts1 = time1.split(':');
      final parts2 = time2.split(':');

      final minutes1 = int.parse(parts1[0]) * 60 + int.parse(parts1[1]);
      final minutes2 = int.parse(parts2[0]) * 60 + int.parse(parts2[1]);

      return minutes1 < minutes2;
    } catch (e) {
      return false;
    }
  }

  // Get formatted Hijri date
  String getFormattedHijriDate() {
    final data = prayerData.value;
    if (data == null) {
      // Fallback to current date formatting
      return DateFormat('d MMMM yyyy').format(currentTime.value);
    }

    final hijri = data.date.hijri;
    return '${hijri.day} ${hijri.month.en} ${hijri.year}';
  }

  // Get Qibla direction in degrees
  double getQiblaDirection() {
    return prayerData.value?.qibla.direction.degrees ?? 0.0;
  }

  // Check if a prayer time has passed
  bool isPrayerPassed(String prayerName) {
    final data = prayerData.value;
    if (data == null) return false;

    final prayerTime = data.times[prayerName];
    if (prayerTime == null) return false;

    final now = currentTime.value;
    final currentTimeStr = DateFormat('HH:mm').format(now);

    return !_isTimeBefore(currentTimeStr, prayerTime);
  }
}
