import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qurany/firebase_options.dart';

import 'route/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  configEasyLoading();

  // Lock orientation to portrait only (disable orientation changes)
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("------------------------------------------------");
  print("✅ Connected to Firebase Project: ${Firebase.app().options.projectId}");
  print("------------------------------------------------");
  runApp(MyApp());
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
  @override
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Quarany',
        getPages: AppRoute.routes,
        initialRoute: AppRoute.splashScreen,
        theme: ThemeData(textTheme: GoogleFonts.figtreeTextTheme()),
        builder: EasyLoading.init(),
      ),
    );
  }
}
