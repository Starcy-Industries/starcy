import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:auto_route/auto_route.dart';
import 'package:cupertino_modal_sheet/cupertino_modal_sheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:audio/audio.dart';

import 'package:starcy/features/home/presentation/pages/setting_page.dart';
import 'package:starcy/utils/sp.dart';
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
  @override
  Widget build(BuildContext context) {
    return const Settings();
  }

  @override
  void initState() {
    _connect();
    super.initState();
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
            _startRecording();
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

  void _startRecording() async {
    await _audio.startRecording();

    _audio.audioStream.listen((data) async {
      _sendAudio(data);
    });
    _audio.audioStream.handleError((error) {
      debugPrint("Error recording audio: $error");
    });
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

  final _audio = Audio();
  WebSocketChannel? _chatChannel;
  bool _isConnected = false;
  bool _isMuted = false;
  var chatEntries = <ChatEntry>[];
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    bool this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.grey.shade400,
        size: 24.appSp,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade400,
          fontSize: 16.appSp,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: Colors.grey.shade900.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.appSp),
      ),
      contentPadding:
          EdgeInsets.symmetric(horizontal: 16.appSp, vertical: 4.appSp),
    );
  }

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
}

class _Drawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.appSp),
          child: Column(
            children: [
              // Search bar at the top
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.appSp),
                child: Container(
                  height: 44.appSp,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10.appSp),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12.appSp),
                  child: Row(
                    children: [
                      Icon(Icons.search,
                          color: Colors.grey.shade400, size: 20.appSp),
                      SizedBox(width: 10.appSp),
                      Text(
                        'Search',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 16.appSp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Navigation items
              _DrawerItem(
                icon: Icons.build_circle_rounded,
                label: 'Starcy',
                isSelected: true,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 16.appSp),

              _DrawerItem(
                icon: Icons.grid_view_rounded,
                label: 'Explore GPTs',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 40.appSp),

              // No chats message
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80.appSp,
                      height: 80.appSp,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16.appSp),
                      ),
                      child: Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.grey.shade600,
                        size: 40.appSp,
                      ),
                    ),
                    SizedBox(height: 12.appSp),
                    Text(
                      'No chats',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.appSp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.appSp),
                    Text(
                      'As you talk with ChatGPT, your\nconversations will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14.appSp,
                      ),
                    ),
                    SizedBox(height: 24.appSp),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.appSp,
                          vertical: 16.appSp,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.appSp),
                        ),
                      ),
                      child: Text(
                        'Start new chat',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.appSp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // User profile at the bottom
              Builder(builder: (context) {
                final user = Supabase.instance.client.auth.currentSession?.user;
                // if (user == null) {
                //   return Container();
                // }
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    // open setting
                    showCupertinoModalSheet(
                      context: context,
                      builder: (context) => const SettingPage(),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 16.appSp),
                    child: Row(
                      children: [
                        Container(
                          width: 32.appSp,
                          height: 32.appSp,
                          decoration: BoxDecoration(
                            color: Colors.teal.shade300,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              user?.email?.split('')[0] ?? 'U',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.appSp,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.appSp),
                        Text(
                          '${user?.email?.split('@')[0]}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.appSp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.more_horiz, color: Colors.grey.shade600),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
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
