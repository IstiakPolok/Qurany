import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

/// Thrown when the server returns a non-200 status code.
class MaintenanceException implements Exception {
  final int statusCode;
  const MaintenanceException(this.statusCode);

  @override
  String toString() => 'MaintenanceException: Server returned $statusCode';
}

/// Thrown when there is no internet connectivity.
class NoInternetException implements Exception {
  final String details;
  const NoInternetException([this.details = '']);

  @override
  String toString() => 'NoInternetException: $details';
}

class NetworkErrorHandler {
  /// Shows a "No Internet" alert dialog with only a "Try Again" button.
  /// [onRetry] is called when the user taps "Try Again".
  static Future<void> showNoInternetDialog({
    required VoidCallback onRetry,
  }) async {
    // Close any previously open dialog
    if (Get.isDialogOpen == true) {
      Get.back();
    }

    await Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Prevent back button dismiss
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.wifi_off_rounded, color: Colors.red, size: 28),
              SizedBox(width: 10),
              Text(
                'No Internet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Please check your internet connection and try again.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back(); // Close dialog
                  onRetry();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false, // Can't dismiss by tapping outside
    );
  }

  /// Shows a maintenance dialog with a Try Again button.
  /// [onRetry] is called when the user taps "Try Again".
  static Future<void> showMaintenanceMessage({
    required VoidCallback onRetry,
  }) async {
    if (Get.isDialogOpen == true) {
      Get.back();
    }

    await Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.construction_rounded,
                color: Color(0xFFF9A825),
                size: 28,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Under Maintenance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: const Text(
            'The app is under maintenance. Please try again after some time.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  onRetry();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Checks if an exception is a network connectivity error.
  static bool isNoInternetError(dynamic error) {
    if (error is SocketException) return true;
    if (error is http.ClientException) {
      return error.message.contains('SocketException') ||
          error.message.contains('Failed host lookup') ||
          error.message.contains('Connection refused') ||
          error.message.contains('Network is unreachable');
    }
    // Check nested exception toString
    final errorStr = error.toString();
    return errorStr.contains('SocketException') ||
        errorStr.contains('Failed host lookup');
  }
}
