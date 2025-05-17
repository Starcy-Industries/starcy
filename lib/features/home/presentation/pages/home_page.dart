import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:auto_route/auto_route.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:audio/audio.dart';

import 'package:starcy/components/chat.dart';
import 'package:starcy/utils/evi_message.dart' as evi;
import 'package:starcy/utils/config.dart';
import 'package:starcy/components/settings.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _audio = Audio();
  WebSocketChannel? _chatChannel;
  bool _isConnected = false;
  bool _isMuted = false;
  var chatEntries = <ChatEntry>[];

  @override
  Widget build(BuildContext context) {
    return const Settings();
  }

  @override
  void initState() {
    super.initState();
    _connect();
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  // EVI sends back transcripts of both the user's and assistants speech,
  // along with an analysis of the emotional content of the speech.
  // This method takes of a message from EVI, parses it into a ChatMessage
  // and adds it to `chatEntries` so it can be displayed.
  void appendNewChatMessage(evi.ChatMessage chatMessage, evi.Inference models) {
    final role = chatMessage.role == 'assistant' ? Role.assistant : Role.user;
    final entry = ChatEntry(
        role: role,
        timestamp: DateTime.now().toString(),
        content: chatMessage.content,
        scores: _HumeHelper.extractTopThreeEmotions(models));
    setState(() {
      chatEntries.add(entry);
    });
  }

  // Opens a websocket connection to the EVI API and registers a listener to handle
  // incoming messages.
  void _connect() {
    setState(() {
      _isConnected = true;
    });
    if (ConfigManager.instance.humeApiKey.isNotEmpty &&
        ConfigManager.instance.humeAccessToken.isNotEmpty) {
      throw Exception(
          'Please use either an API key or an access token, not both');
    }

    var uri = 'wss://api.hume.ai/v0/evi/chat';
    if (ConfigManager.instance.humeAccessToken.isNotEmpty) {
      uri += '?access_token=${ConfigManager.instance.humeAccessToken}';
    } else if (ConfigManager.instance.humeApiKey.isNotEmpty) {
      uri += '?api_key=${ConfigManager.instance.humeApiKey}';
    } else {
      throw Exception('Please set your Hume API credentials in main.dart');
    }

    if (ConfigManager.instance.humeConfigId.isNotEmpty) {
      uri += "&config_id=${ConfigManager.instance.humeConfigId}";
    }

    _chatChannel = WebSocketChannel.connect(Uri.parse(uri));

    _chatChannel!.stream.listen(
      (event) async {
        final message = evi.EviMessage.decode(event);
        debugPrint("Received message: ${message.type}");
        // This message contains audio data for playback.
        switch (message) {
          case (evi.ErrorMessage errorMessage):
            debugPrint("Error: ${errorMessage.message}");
            break;
          case (evi.ChatMetadataMessage chatMetadataMessage):
            debugPrint("Chat metadata: ${chatMetadataMessage.rawJson}");
            _prepareAudioSettings();
            await _startRecording();
            break;
          case (evi.AudioOutputMessage audioOutputMessage):
            _audio.enqueueAudio(audioOutputMessage.data);
            break;
          case (evi.UserInterruptionMessage _):
            _handleInterruption();
            break;
          // These messages contain the transcript text of the user's or the assistant's speech
          // as well as emotional analysis of the speech.
          case (evi.AssistantMessage assistantMessage):
            appendNewChatMessage(
                assistantMessage.message, assistantMessage.models);
            break;
          case (evi.UserMessage userMessage):
            appendNewChatMessage(userMessage.message, userMessage.models);
            _handleInterruption();
            break;
          case (evi.UnknownMessage unknownMessage):
            debugPrint("Unknown message: ${unknownMessage.rawJson}");
            break;
        }
      },
      onError: (error) {
        debugPrint("Connection error: $error");
        _handleConnectionClosed();
      },
      onDone: () {
        debugPrint("Connection closed");
        _handleConnectionClosed();
      },
    );

    debugPrint("Connected");
  }

  void _disconnect() {
    _handleConnectionClosed();
    _handleInterruption();
    _chatChannel?.sink.close();
    debugPrint("Disconnected");
  }

  void _handleConnectionClosed() {
    setState(() {
      _isConnected = false;
    });
    _stopRecording();
  }

  void _handleInterruption() {
    _audio.stopPlayback();
  }

  void _muteInput() {
    _stopRecording();
    setState(() {
      _isMuted = true;
    });
  }

  void _prepareAudioSettings() {
    // set session settings to prepare EVI for receiving linear16 encoded audio
    // https://dev.hume.ai/docs/empathic-voice-interface-evi/configuration#session-settings
    _chatChannel!.sink.add(jsonEncode({
      'type': 'session_settings',
      'audio': {
        'encoding': 'linear16',
        'sample_rate': 48000,
        'channels': 1,
      },
    }));
  }

  void _sendAudio(String base64) {
    _chatChannel!.sink.add(jsonEncode({
      'type': 'audio_input',
      'data': base64,
    }));
  }

  Future<void> _startRecording() async {
    _audio.audioStream.listen((data) async {
      _sendAudio(data);
    });
    _audio.audioStream.handleError((error) {
      debugPrint("Error recording audio: $error");
    });

    await _audio.startRecording();
  }

  void _stopRecording() {
    _audio.stopRecording();
  }

  void _unmuteInput() {
    _startRecording();
    setState(() {
      _isMuted = false;
    });
  }
}

class _HumeHelper {
  static List<Score> extractTopThreeEmotions(evi.Inference models) {
    // extract emotion scores from the message
    final scores = models.prosody?.scores ?? {};

    // convert the emotions object into an array of key-value pairs
    final scoresArray = scores.entries.toList();

    // sort the array by the values in descending order
    scoresArray.sort((a, b) => b.value.compareTo(a.value));

    // extract the top three emotions and convert them back to an object
    final topThreeEmotions = scoresArray.take(3).map((entry) {
      return Score(emotion: entry.key, score: entry.value);
    }).toList();

    return topThreeEmotions;
  }
}
