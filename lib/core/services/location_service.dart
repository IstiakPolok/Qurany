import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';

class LocationService extends GetxService {
  static LocationService get instance => Get.find<LocationService>();

  final RxString currentLocation = 'Loading...'.obs;
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLocation();
  }

  Future<void> fetchLocation() async {
    try {
      isLoading(true);
      currentLocation.value = 'Loading...';

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        currentLocation.value = 'Location services disabled';
        isLoading(false);
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          currentLocation.value = 'Location permission denied';
          isLoading(false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        currentLocation.value = 'Location permission denied';
        isLoading(false);
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      currentPosition.value = position;

      // Get address from coordinates
      await _getAddressFromCoordinates(position.latitude, position.longitude);
    } catch (e) {
      print('Error fetching location: $e');
      currentLocation.value = 'Unable to get location';
    } finally {
      isLoading(false);
    }
  }

  Future<void> _getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String city = place.locality ?? place.subAdministrativeArea ?? '';
        String country = place.country ?? '';

        if (city.isNotEmpty && country.isNotEmpty) {
          currentLocation.value = '$city, $country';
        } else if (city.isNotEmpty) {
          currentLocation.value = city;
        } else if (country.isNotEmpty) {
          currentLocation.value = country;
        } else {
          currentLocation.value = 'Unknown location';
        }
      } else {
        currentLocation.value = 'Unknown location';
      }
    } catch (e) {
      print('Error getting address: $e');
      currentLocation.value = 'Unknown location';
    }
  }

  // Refresh location
  Future<void> refreshLocation() async {
    await fetchLocation();
  }
}
