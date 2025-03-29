import 'dart:async';

import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:starcy/core/routes/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: "https://txuvmmvubieskhcwwmrh.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR4dXZtbXZ1Ymllc2toY3d3bXJoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzM5NDQ1MjMsImV4cCI6MjA0OTUyMDUyM30.0ajES5QDCgFo33n8EHqqFQN1LZ6Z2HOOjrltgWhNNXQ",
  );

  if (!kIsWeb) {
    FlutterForegroundTask.initCommunicationPort();
  }

  /*runApp(
    DevicePreview(
      enabled: kIsWeb,
      builder: (context) => MyApp(),
    ),
  )*/

  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: ScreenUtil.defaultSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => ToastificationWrapper(
        child: MaterialApp.router(
          title: 'Starcy',
          theme: ThemeData(
            fontFamily: 'Inter',
            useMaterial3: true,
            colorScheme: const ColorScheme(
              brightness: Brightness.light,
              primary: Colors.black,
              onPrimary: Colors.white,
              secondary: Colors.white,
              onSecondary: Colors.black,
              error: Colors.red,
              onError: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          routerConfig: _appRouter.config(),
        ),
      ),
    );
  }
}
