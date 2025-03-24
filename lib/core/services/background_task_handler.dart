import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  // Request microphone permission
  final micStatus = await Permission.microphone.request();
  if (!micStatus.isGranted) {
    print('Microphone permission not granted');
    return;
  }

  if (service is AndroidServiceInstance) {
    service.on('stopService').listen((event) {
      service.stopSelf();
    });
  }

  // Keep the service alive
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
          title: "Starcy Service",
          content: "Running in background",
        );
      }
    }

    // Add your background task logic here
    // For example, periodic data sync, location updates, etc.
    print("Background service running... ${DateTime.now()}");
  });
}

class BackgroundTaskService {
  static Future<void> initializeBackgroundTask() async {
    final service = FlutterBackgroundService();

    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        foregroundServiceNotificationId: 888,
        initialNotificationTitle: 'Starcy Service',
        initialNotificationContent: 'Initializing',
      ),
    );
  }

  static Future<void> startBackgroundTask() async {
    final service = FlutterBackgroundService();
    service.startService();
  }

  static Future<void> stopBackgroundTask() async {
    final service = FlutterBackgroundService();
    service.invoke("stopService");
  }
}
