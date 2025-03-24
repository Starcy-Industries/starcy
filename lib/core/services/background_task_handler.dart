import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<bool> isRecordingRunning = ValueNotifier(false);

class BackgroundRecordService {
  void startRecord() async {
    try {
      print("------------------------------1111");
      await _requestRecordPermission();
      print("------------------------------2222");

      await _startService();
    } catch (e, s) {
      print("------------------------------ERROR");
      print(e.toString());
      print(s.toString());

      _handleError(e, s);
    }
  }

  void stopRecord() async {
    try {
      await _stopService();
    } catch (e, s) {
      _handleError(e, s);
    }
  }

  // private
  Future<void> _requestPlatformPermissions() async {
    final NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    if (Platform.isAndroid) {
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }
    }
  }

  Future<void> _requestRecordPermission() async {
    if (!await Permission.microphone.isGranted) {
      throw Exception(
          'To start record service, you must grant microphone permission.');
    }
  }

  Future<void> _initService() async {
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'record_service',
        channelName: 'Record Service',
        channelImportance: NotificationChannelImportance.HIGH,
        priority: NotificationPriority.HIGH,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        isOnceEvent: true,
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<void> _startService() async {
    if (await FlutterForegroundTask.isRunningService) {
      print("------------------------------3333");

      await FlutterForegroundTask.stopService();
    }
    print("------------------------------4444");

    await _requestPlatformPermissions();
    print("------------------------------5555");

    await _initService();
    print("------------------------------6666");

    final ServiceRequestResult result =
        await FlutterForegroundTask.startService(
      notificationTitle: 'Record Service',
      notificationText: '',
      callback: startRecordService,
      
    );

    if (!result.success) {
      throw result.error ??
          Exception('An error occurred and the service could not be started.');
    }
  }

  Future<void> _stopService() async {
    final ServiceRequestResult result =
        await FlutterForegroundTask.stopService();

    if (!result.success) {
      throw result.error ??
          Exception('An error occurred and the service could not be stopped.');
    }

    throw ("${result.success}");
  }

  // handler
  void _onReceiveTaskData(Object data) {
    Map res = data as Map;

    bool isCompleted = res["isCompleted"] ?? false;
    bool isRecordStarted = res["isRecordStarted"] ?? false;

    if (isCompleted) {
      isRecordingRunning.value = false;
    }
    if (isRecordStarted) {
      isRecordingRunning.value = true;
    }

    // print error to console.
    dev.log('-------------------DATA----------------------');
    dev.log(data.toString());
    dev.log('-----------------------------------------');

    // handle task data
  }

  void _handleError(Object e, StackTrace s) {
    String errorMessage;
    if (e is PlatformException) {
      errorMessage = '${e.code}: ${e.message}';
    } else {
      errorMessage = e.toString();
    }

    // print error to console.
    dev.log('-----------------Error------------------------');
    dev.log('$errorMessage\n${s.toString()}');
    dev.log('-----------------------------------------');

    // show error to user.
  }

  void detach() {
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
  }
}

@pragma('vm:entry-point')
void startRecordService() {
  FlutterForegroundTask.setTaskHandler(RecordServiceHandler());
}

class RecordServiceHandler extends TaskHandler {
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();

  // RecorderStream? _recorder;

  // String filepath = "";

  @override
  Future<void> onStart(DateTime timestamp) async {
    // WidgetsFlutterBinding.ensureInitialized();
    // _recorder = RecorderStream();
    // _recorder?.initialize(showLogs: true);
    _startRecord();
    FlutterForegroundTask.sendDataToMain({"isRecordStarted": true});

    int? value = 30;

    print("*****");
    print("*****");
    print(value);
    print("*****");
    print("*****");

    Future.delayed(Duration(seconds: value), () async {
      print("onStart");
      await _stopRecord();
      if (await FlutterForegroundTask.isRunningService) {
        FlutterForegroundTask.stopService();
      }
    });
  }

  bool canClose = false;

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  void onDestroy(DateTime timestamp) {
    print("onDestroy");
    _stopRecord();
  }

  String? userId;

  @override
  Future<void> onReceiveData(Object data) async {
    if (data is Map) {
      bool res = ((data)['action.stopRecord'] as bool?) ?? false;
      if (res) {
        print("onNotificationButtonPressed");
        await _stopRecord();
        if (await FlutterForegroundTask.isRunningService) {
          await FlutterForegroundTask.stopService();
        }
      }
    }
  }

  @override
  void onNotificationButtonPressed(String id) async {
    if (id == "action.stopRecord") {
      print("onNotificationButtonPressed");
      await _stopRecord();
      if (await FlutterForegroundTask.isRunningService) {
        FlutterForegroundTask.stopService();
      }
    }
  }

  // RecognitionConfig _getConfig() => RecognitionConfig(
  //       encoding: AudioEncoding.LINEAR16,
  //       model: RecognitionModel.basic,
  //       enableAutomaticPunctuation: true,
  //       sampleRateHertz: 16000,
  //       languageCode: 'en-US',
  //     );

  // StreamSubscription<List<int>>? _audioStreamSubscription;
  // BehaviorSubject<List<int>>? _audioStream;

  String text = "";
  List<int> recordedFileBytes = [];

  Future<void> _openRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
    //sampleRate = await _mRecorder!.getSampleRate();
  }

  Future<void> _startRecord() async {
    try {
      // Initialize the directory and filepath
      String responseText = "";

      // Use a broadcast stream so it can be listened to multiple times
      var recordingDataController = StreamController<Uint8List>.broadcast();

      await _audioRecorder.openRecorder(isBGService: !Platform.isIOS);

      if (Platform.isIOS) {
        await _openRecorder();
      }

      await _audioRecorder.startRecorder(
        toStream: recordingDataController.sink,
        numChannels: 1,
        sampleRate: 16000,
        bufferSize: 8192,
      );

      // Listen to the recording data stream and store bytes
      recordingDataController.stream.listen((buffer) {
        List<int> audioBytesList = buffer.toList();
        recordedFileBytes.addAll(audioBytesList);
      });

      // Load service account for Speech-to-Text
      // final serviceAccount = ServiceAccount.fromString(
      //     await rootBundle.loadString('assets/test_service_account.json'));
      // final speechToText = SpeechToText.viaServiceAccount(serviceAccount);
      // final config = _getConfig();

      // Start streaming recognition using the same broadcast stream
      // final responseStream = speechToText.streamingRecognize(
        // StreamingRecognitionConfig(config: config, interimResults: true),
        // recordingDataController.stream.map((chunk) => chunk.toList()),
      // );

      // Listen to the speech-to-text response stream
      // responseStream.listen((data) {
      //   if (data.results.isNotEmpty) {
      //     final currentText = data.results
      //         .map((e) => e.alternatives.first.transcript)
      //         .join('\n');

      //     if (data.results.firstOrNull?.isFinal ?? false) {
      //       responseText += '\n$currentText';
      //       text = responseText;
      //     } else {
      //       text = '$responseText\n$currentText';
      //     }
      //   } else {
      //     print("No transcription results received");
      //   }
      // }, onDone: () {
      //   print("Stream closed");
      // }, onError: (error) {
      //   print("Stream error: $error");
      // });

      // Update the foreground task notification
      FlutterForegroundTask.updateService(
        notificationTitle: 'Recording Service Started!',
        notificationText: 'Recording...',
        notificationButtons: [
          const NotificationButton(id: "action.stopRecord", text: 'Stop'),
        ],
      );
    } catch (e) {
      print("Error starting recorder or streaming: ${e.toString()}");
    }
  }

  Future<File> save(List<int> data, int sampleRate) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String filepath =
        '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.pcm';
    File recordedFile = File(filepath);

    var channels = 1;

    int byteRate = ((16 * sampleRate * channels) / 8).round();

    var size = data.length;

    var fileSize = size + 36;

    Uint8List header = Uint8List.fromList([
      // "RIFF"
      82, 73, 70, 70,
      fileSize & 0xff,
      (fileSize >> 8) & 0xff,
      (fileSize >> 16) & 0xff,
      (fileSize >> 24) & 0xff,
      // WAVE
      87, 65, 86, 69,
      // fmt
      102, 109, 116, 32,
      // fmt chunk size 16
      16, 0, 0, 0,
      // Type of format
      1, 0,
      // One channel
      channels, 0,
      // Sample rate
      sampleRate & 0xff,
      (sampleRate >> 8) & 0xff,
      (sampleRate >> 16) & 0xff,
      (sampleRate >> 24) & 0xff,
      // Byte rate
      byteRate & 0xff,
      (byteRate >> 8) & 0xff,
      (byteRate >> 16) & 0xff,
      (byteRate >> 24) & 0xff,
      // Uhm
      ((16 * channels) / 8).round(), 0,
      // bitsize
      16, 0,
      // "data"
      100, 97, 116, 97,
      size & 0xff,
      (size >> 8) & 0xff,
      (size >> 16) & 0xff,
      (size >> 24) & 0xff,
      ...data
    ]);
    recordedFile.writeAsBytesSync(header, flush: true);
    return recordedFile;
  }

  Future<void> _stopRecord() async {
    FlutterForegroundTask.sendDataToMain({"isCompleted": true});

    print("***************************_stopRecord*************************");

    // try {
    // await _recorder?.stop();
    // await _audioStreamSubscription?.cancel();
    // await _audioStream?.close();

    await _audioRecorder.stopRecorder();
    File file = await save(recordedFileBytes, 16000);

    try {
      print("Step 1: Checking if the file exists...");

      // Create a File instance

      // Check if the file exists
      if (await file.exists()) {
        print("Step 2: File exists. Getting file size...");

        // Get file length (in bytes)
        final fileSizeInBytes = await file.length();
        print("Step 3: File size in bytes: $fileSizeInBytes");

        // Convert bytes to MB
        final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
        print("Step 4: File size in MB: ${fileSizeInMB.toStringAsFixed(2)} MB");
      } else {
        print("Step 2: File does not exist at the provided path.");
      }
    } catch (e) {
      print("Error: $e");
    }

    // Recording recording = Recording(
    //   createdAt: DateTime.now().toString(),
    //   id: const Uuid().v4(),
    //   filePath: file.path,
    //   isFromLocal: true,
    //   tags: [],
    //   text: text,
    //   title:
    //       "Recording from ${DateTime.now().toString().substring(0, 11).trim()}"
    //           .firstLower(),
    //   mediaUrl: "",
    //   ownerId: "",
    //   color: "Red".toLowerCase(),
    // );

    // String recordKey = "record";

    // await SharedPreferences.getInstance().then(
    //   (value) async {
    //     List<String> records = value.getStringList(recordKey) ?? [];
    //     String recordString = json.encode(recording.toJson());
    //     records.add(recordString);
    //     return await value.setStringList(recordKey, records);
    //   },
    // );

    // print(recording.toJson());
    // } catch (e) {
    //   print(
    //       "***************************************${e.toString()}**********************************");
    // }

    print(
        "**********************SAVED SUCCESSFULLY******************************");
  }
}
