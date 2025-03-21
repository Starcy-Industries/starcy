import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'notification_service.dart';
import 'background_service.dart';
import 'permission_dialog.dart';

class PermissionManager {
  static Future<void> initialize() async {
    await NotificationService.initialize();
    await BackgroundService.initialize();
  }

  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  static Future<bool> requestBackgroundPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.ignoreBatteryOptimizations.status.isDenied) {
        final status = await Permission.ignoreBatteryOptimizations.request();
        return status.isGranted;
      }
      return true;
    }
    return true;
  }

  static Future<Map<String, bool>> checkPermissionStatus() async {
    return {
      'notification': await Permission.notification.isGranted,
      'microphone': await Permission.microphone.isGranted,
      'batteryOptimization': Platform.isAndroid
          ? await Permission.ignoreBatteryOptimizations.isGranted
          : true,
    };
  }

  static Future<bool> requestPermissions(BuildContext context) async {
    // Show permission explanation dialog first

    await initialize();

    // Request permissions one by one
    final notificationGranted =
        await NotificationService.requestNotificationPermission();
    final microphoneGranted = await requestMicrophonePermission();
    final backgroundGranted = await requestBackgroundPermissions();

    // Check if all permissions are granted
    final allGranted =
        notificationGranted && microphoneGranted && backgroundGranted;

    // Only start background service if all permissions are granted
    if (allGranted) {
      await startBackgroundService();
    }

    return allGranted;
  }

  static Future<void> startBackgroundService() async {
    final permissionStatus = await checkPermissionStatus();
    final allGranted = permissionStatus.values.every((granted) => granted);

    if (allGranted) {
      await BackgroundService.startBackgroundService();
      debugPrint('Background service started successfully');
    } else {
      debugPrint('Cannot start background service - permissions not granted');
    }
  }

  static Future<void> stopBackgroundService() async {
    await BackgroundService.stopBackgroundService();
  }
}
