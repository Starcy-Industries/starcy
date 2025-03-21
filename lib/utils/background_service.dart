import 'package:workmanager/workmanager.dart';
import 'package:flutter/material.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'backgroundTask':
        await NotificationService.showBackgroundNotification();
        break;
    }
    return true;
  });
}

class BackgroundService {
  static const String taskName = 'backgroundTask';

  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false, // Set to true for debugging
    );
  }

  static Future<void> startBackgroundService() async {
    try {
      await Workmanager().registerPeriodicTask(
        'starcyBackgroundTask',
        taskName,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );
      debugPrint('Background service registered successfully');
    } catch (e) {
      debugPrint('Failed to register background service: $e');
    }
  }

  static Future<void> stopBackgroundService() async {
    try {
      await Workmanager().cancelAll();
      await NotificationService.cancelBackgroundNotification();
      debugPrint('Background service stopped');
    } catch (e) {
      debugPrint('Failed to stop background service: $e');
    }
  }
}
