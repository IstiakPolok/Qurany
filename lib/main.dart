import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qurany/firebase_options.dart';
import 'package:qurany/core/services/location_service.dart';
import 'package:qurany/core/services/purchase_api.dart';
import 'package:qurany/core/services/notification_service.dart';

import 'route/app_routes.dart';
import 'core/localization/app_translations.dart';
import 'core/services_class/local_service/shared_preferences_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Notification Service
  await NotificationService().init(requestPermissionOnInit: false);

  configEasyLoading();

  // Lock orientation to portrait only (disable orientation changes)
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize RevenueCat
  await PurchaseApi.init();

  print("------------------------------------------------");
  print("✅ Connected to Firebase Project: ${Firebase.app().options.projectId}");
  print("------------------------------------------------");

  // Initialize LocationService
  Get.put(LocationService());

  // Get saved language pref
  final String savedLang = await SharedPreferencesHelper.getLanguage();
  Locale initialLocale = const Locale('en');
  switch (savedLang) {
    case 'English':
      initialLocale = const Locale('en');
      break;
    case 'العربية':
      initialLocale = const Locale('ar');
      break;
    case 'اردو':
      initialLocale = const Locale('ur');
      break;
    case 'Türkçe':
      initialLocale = const Locale('tr');
      break;
    case 'Bahasa':
      initialLocale = const Locale('id');
      break;
    case 'Français':
      initialLocale = const Locale('fr');
      break;
  }

  runApp(MyApp(initialLocale: initialLocale));
}

void configEasyLoading() {
  EasyLoading.instance
    ..loadingStyle = EasyLoadingStyle.custom
    ..backgroundColor = Colors.grey
    ..textColor = Colors.white
    ..indicatorColor = Colors.white
    ..maskColor = Colors.green
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  final Locale initialLocale;
  const MyApp({super.key, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Quarany',
        translations: AppTranslations(),
        locale: initialLocale,
        fallbackLocale: const Locale('en'),
        getPages: AppRoute.routes,
        initialRoute: AppRoute.splashScreen,
        theme: ThemeData(textTheme: GoogleFonts.figtreeTextTheme()),
        builder: EasyLoading.init(),
      ),
    );
  }
}
