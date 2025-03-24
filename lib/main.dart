import 'dart:async';

import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_foreground_task/models/notification_permission.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:starcy/core/routes/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:starcy/core/services/background_task_handler.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize background task
  // await BackgroundTaskService.initializeBackgroundTask();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Load environment variables
  // if(kIsWeb){
  //   await dotenv.load(fileName: "env");
  // }else {
  //   await dotenv.load(fileName: ".env");
  // }

  await Supabase.initialize(
    url: 'https://hdqtnuphhgpyerlwbtbo.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhkcXRudXBoaGdweWVybHdidGJvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE0OTczOTAsImV4cCI6MjA1NzA3MzM5MH0.vmTWkiSzdmWXaN4f4MOdqUNrCZuuzJTbzYBU7_w3Y3A',
  );

  FlutterForegroundTask.initCommunicationPort();
  _startAutoRecording();

  runApp(
    DevicePreview(
      enabled: kIsWeb,
      builder: (context) => MyApp(),
    ),
  );
}

Future<void> _startAutoRecording() async {
  final NotificationPermission notificationPermission =
      await FlutterForegroundTask.checkNotificationPermission();
  if (notificationPermission != NotificationPermission.granted) {
    await FlutterForegroundTask.requestNotificationPermission();
  }
  await Permission.microphone.request();
  BackgroundRecordService backgroundRecordService = BackgroundRecordService();
  backgroundRecordService.startRecord();
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
      builder: (context, child) => MaterialApp.router(
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
    );
  }
}
