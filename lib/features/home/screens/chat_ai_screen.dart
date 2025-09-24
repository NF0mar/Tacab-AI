import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
// import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:tacab_ai/features/home/screens/tacab_tts.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tacab_ai/features/home/screens/chat_history.dart';
import 'dart:async' show unawaited;


class ChatAIScreen extends StatefulWidget {
  const ChatAIScreen({super.key});

  @override
  State<ChatAIScreen> createState() => _ChatAIScreenState();
}

enum Sender { user, ai }

class ChatMessage {
  final String? text;
  // final File? image;
  final Sender sender;

  // ChatMessage({this.text, this.image, required this.sender});
  ChatMessage({this.text, required this.sender});
}

class _ChatAIScreenState extends State<ChatAIScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecorderInitialized = false;
  String? _recordedFilePath;
  bool _isRecording = false;
  bool _isSending = false;
  bool _isTranscribing = false; // true only during ASR
  bool _isGenerating = false; // true only during AI text generation
  final TacabTTS _tts = TacabTTS();
  String _recordingStatus = '';
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentConversationId;

  final TextEditingController _controller = TextEditingController();
  // File? _selectedImage; // Holds image before sending

  // Store chat messages shown in main chat area
  final List<ChatMessage> _messages = [];
  // Store chat history pairs for drawer
  List<Map<String, String?>> _chatHistoryPairs = [];

  bool get hasText => _controller.text.trim().isNotEmpty;

  String? _photoUrl;

// How many recent messages to include every time.
  static const int _contextTurns = 12;

// Local cache of the long-term memory summary for the active conversation.
  String _conversationSummary = '';

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _controller.addListener(() {
      setState(() {}); // Trigger rebuild when text changes
    });
    _warmUpTacabApis();
    _loadChatHistory();
    _startNewConversation();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _photoUrl = user?.photoURL;
    });
  }

  // void _warmUpTacabApis() async {
  //   await http.post(
  //     Uri.parse("https://tacab-somali-textgen.hf.space/generate"),
  //     headers: {"Content-Type": "application/json"},
  //     body: json.encode({"inputs": "salaan"}),
  //   );

  //   await http.post(
  //     Uri.parse("https://tacab-tts.hf.space/synthesize"),
  //     headers: {"Content-Type": "application/json"},
  //     body: json.encode({"inputs": "hello"}),
  //   );
  // }

  void _warmUpTacabApis() async {
    // Warm up LLM /ask
    await http
        .post(
          Uri.parse("https://nurfarah57-txt-generation.hf.space/ask"),
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            "question": "salaan",
            "max_new_tokens": 32,
            "force_fallback": false,
            "lang": "so"
          }),
        )
        .catchError((_) {});

    // Warm up TTS
    await http
        .post(
          Uri.parse("https://tacab-tts.hf.space/synthesize"),
          headers: {"Content-Type": "application/json"},
          body: json.encode({"inputs": "hello"}),
        )
        .catchError((_) {});
  }

  Future<void> _loadChatHistory() async {
    if (userId == null) return;
    try {
      final loadedPairs = await ChatHistory.loadHistoryPairs(
        firestore: _firestore,
        userId: userId!,
      );
      setState(() {
        _chatHistoryPairs = loadedPairs;
      });
    } catch (e) {
      print("Failed to load chat history: $e");
    }
  }

  Future<void> _startNewConversation() async {
    if (userId == null) return;
    try {
      final id = await ChatHistory.startNewConversation(
        firestore: _firestore,
        userId: userId!,
      );
      _currentConversationId = id;
      _conversationSummary = '';

      setState(() {
        _messages.clear();
      });

      await _loadChatHistory();
    } catch (e) {
      print("Failed to start conversation: $e");
    }
  }

  Future<void> _saveChatToFirestore(String userText, String aiText) async {
    if (_currentConversationId == null || userId == null) {
      print("No active conversation");
      return;
    }

    try {
      await ChatHistory.saveExchange(
        firestore: _firestore,
        userId: userId!,
        conversationId: _currentConversationId!,
        userText: userText,
        aiText: aiText,
      );
    } catch (e) {
      print("Failed to save chat: $e");
    }
  }

  void _initRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      print('❌ Microphone permission not granted');
      return;
    }

    await _recorder.openRecorder();
    await _recorder.setSubscriptionDuration(const Duration(milliseconds: 500));

    _isRecorderInitialized = true;
    print('✅ Recorder initialized');
  }

  void _toggleRecording() async {
    if (!_isRecording) {
      Directory tempDir = await getTemporaryDirectory();
      String path = '${tempDir.path}/recorded_audio.mp4';
      // String path = '${tempDir.path}/recorded_audio.wav';
      // await _recorder.startRecorder(toFile: path);
      print('🎙️ Starting recorder at path: $path');
      await _recorder.startRecorder(
        toFile: path,
        codec: Codec.aacMP4,
        sampleRate: 16000, // ✅ must match model's expected rate
        numChannels: 1, // ✅ must be mono
      );
      print('🎙️ Recorder started');

      _recordedFilePath = path;

      setState(() {
        _isRecording = true;
        _recordingStatus = 'Recording...';
      });
    } else {
      await stopRecording();
    }
  }

  Future<void> stopRecording() async {
    setState(() {
      _isSending = false; // STOP only recording here, not sending
      _isRecording = false;
    });

    String? recordingPath = await _recorder.stopRecorder();
    if (recordingPath != null) {
      final file = File(recordingPath);
      final size = await file.length();
      print('📁 Recorded file size: $size bytes');
      if (size < 2000) {
        print('⚠️ File too small. Likely invalid audio.');
      }
    }
    print('📤 Recording stopped. File path: $recordingPath');

    if (recordingPath == null || !File(recordingPath).existsSync()) {
      setState(() {
        _recordingStatus = 'Recording failed or was too short.';
      });
      return;
    }

    _recordedFilePath = recordingPath;
    await _sendAudioToASR(_recordedFilePath!);
  }

  Future<void> _sendAudioToASR(String filePath) async {
    setState(() {
      _isTranscribing = true;
      _recordingStatus = 'Converting audio...';
    });

    final File file = File(filePath);
    final uri = Uri.parse("https://audio-converter-y0vc.onrender.com/convert");

    try {
      final request = http.MultipartRequest("POST", uri);
      request.files.add(await http.MultipartFile.fromPath("file", filePath));

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200) {
        // Save the received WAV file to a temporary location
        final bytes = await streamedResponse.stream.toBytes();
        final tempDir = await getTemporaryDirectory();
        final convertedFilePath = '${tempDir.path}/converted_audio.wav';
        final convertedFile = File(convertedFilePath);
        await convertedFile.writeAsBytes(bytes);

        setState(() {
          _recordingStatus = 'Audio converted. Sending to ASR...';
        });

        // 🔁 Send the converted file to your Hugging Face ASR
        final asrUri = Uri.parse("https://tacab-asr2025.hf.space/transcribe");
        // Uri.parse("https://tacab-asr-transcription.hf.space/transcribe");
        final asrRequest = http.MultipartRequest("POST", asrUri);
        asrRequest.files
            .add(await http.MultipartFile.fromPath("file", convertedFilePath));

        final asrResponse = await asrRequest.send();

        if (asrResponse.statusCode == 200) {
          final responseBody = await asrResponse.stream.bytesToString();
          final data = json.decode(responseBody);
          final transcribedText = data["text"]?.trim() ?? "";

          if (transcribedText.isNotEmpty) {
            setState(() {
              _controller.text = transcribedText;
              _recordingStatus = 'Voice transcribed.';
            });
            await _submitMessage();
            // Auto-clear status after 3 seconds
            Future.delayed(Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  _recordingStatus = '';
                });
              }
            });
          } else {
            setState(() {
              _recordingStatus = 'Voice transcribed but not understood.';
            });
          }
        } else {
          setState(() {
            _recordingStatus = 'ASR Error: ${asrResponse.statusCode}';
          });
        }
      } else {
        setState(() {
          _recordingStatus = 'Conversion error: ${streamedResponse.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _recordingStatus = 'Exception: $e';
      });
    } finally {
      setState(() {
        _isTranscribing = false;
      });
    }
  }

  String _formatDateYMD(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)}'; // e.g. 2025-09-24
  }

  // Future<void> _pickImage({bool fromCamera = false}) async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(
  //     source: fromCamera ? ImageSource.camera : ImageSource.gallery,
  //   );
  //   if (pickedFile != null) {
  //     setState(() {
  //       _selectedImage = File(pickedFile.path); // Hold image temporarily
  //     });
  //   }
  // }

  Future<void> _convertTextToSpeech(String text) async {
    final filePath = await _tts.synthesizeAndSaveAudio(text);
    if (filePath != null) {
      await _tts.playAudio(filePath);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to synthesize speech')),
      );
    }
  }

  bool _shouldSummarize() {
    // Summarize every 10 messages OR when the prompt would get too long.
    return _messages.length % 10 == 0 ||
        _buildConversationPrompt("").length > 3000;
  }

  Future<void> _summarizeAndPersist() async {
    if (_currentConversationId == null || userId == null) return;

    // Build a compact transcript to summarize (last ~30 messages).
    final start = _messages.length - 30;
    final recent = _messages.sublist(start < 0 ? 0 : start);

    final summaryPrompt = StringBuffer()
      ..writeln(
          "Summarize the following chat into a short memory for Tacab AI ")
      ..writeln("that helps continue the conversation naturally. "
          "Keep it in Somali. Capture lasting user facts, preferences, "
          "goals, and unresolved follow-ups. 3–6 short bullets. "
          "Do NOT repeat the whole conversation.")
      ..writeln("\n### Chat")
      ..writeln(recent.map((m) {
        final role = (m.sender == Sender.user) ? "User" : "Assistant";
        return "$role: ${(m.text ?? '').trim()}";
      }).join("\n"))
      ..writeln("\n### Memory bullets:");

    try {
      final uri = Uri.parse('https://nurfarah57-txt-generation.hf.space/ask');
      final payload = <String, dynamic>{
        'question': summaryPrompt.toString(),
        'max_new_tokens': 200,
        'force_fallback': false,
        'lang': 'so',
      };

      final resp = await http
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 30));

      if (resp.statusCode == 200) {
        final body = utf8.decode(resp.bodyBytes);
        String summary = "";
        try {
          final decoded = json.decode(body);
          if (decoded is Map) {
            if (decoded['answer'] is String &&
                (decoded['answer'] as String).trim().isNotEmpty) {
              summary = (decoded['answer'] as String).trim();
            } else if (decoded['generated_text'] is String &&
                (decoded['generated_text'] as String).trim().isNotEmpty) {
              summary = (decoded['generated_text'] as String).trim();
            } else if (decoded['text'] is String &&
                (decoded['text'] as String).trim().isNotEmpty) {
              summary = (decoded['text'] as String).trim();
            }
          }
        } catch (_) {}

        if (summary.isNotEmpty) {
          setState(() => _conversationSummary = summary);
          await ChatHistory.setSummary(
            firestore: _firestore,
            userId: userId!,
            conversationId: _currentConversationId!,
            summary: summary,
          );
        }
      }
    } catch (_) {
      // Silent fail: memory is optional; chat keeps working.
    }
  }

  String _buildConversationPrompt(String latestUserText) {
    final buf = StringBuffer();

    // Gentle, natural system guidance for the model's style.
    buf.writeln("### Instructions");
    buf.writeln("You are Tacab AI, a friendly, concise assistant. "
        "Keep continuity with the chat history and the memory. "
        "Default to Somali unless the user uses another language. "
        "Use 2–5 short sentences, be natural, and ask at most one clarifying question only if needed.");

    // Long-term memory summary (if any).
    if (_conversationSummary.trim().isNotEmpty) {
      buf.writeln("\n### Memory");
      buf.writeln(_conversationSummary.trim());
    }

    // Short-term rolling context.
    buf.writeln("\n### Dialogue");
    final start = _messages.length - _contextTurns;
    final recent = _messages.sublist(start < 0 ? 0 : start);
    for (final m in recent) {
      final role = (m.sender == Sender.user) ? "User" : "Assistant";
      final text = (m.text ?? "").trim();
      if (text.isEmpty) continue;
      buf.writeln("$role: $text");
    }

    // Latest user turn to answer now.
    buf.writeln("User: $latestUserText");
    buf.writeln("Assistant:");
    return buf.toString();
  }

  Future<void> _submitMessage() async {
    // if (_controller.text.trim().isEmpty && _selectedImage == null) return;
    if (_controller.text.trim().isEmpty) return;

    final userText = _controller.text.trim();

    setState(() {
      _messages.add(ChatMessage(
        text: userText,
        // image: _selectedImage,
        sender: Sender.user,
      ));
      _controller.clear();
      // _selectedImage = null;
      _isGenerating = true;
    });

    try {
      final uri = Uri.parse('https://nurfarah57-txt-generation.hf.space/ask');
      final prompt = _buildConversationPrompt(userText);

      final payload = <String, dynamic>{
        'question': prompt,
        'max_new_tokens': 384,
        'force_fallback': false,
        'lang': 'so',
      };

      // final payload = <String, dynamic>{
      //   'question': userText,
      //   'max_new_tokens': 384,
      //   'force_fallback': false,
      //   'lang': 'so',
      // };

      // Retry a couple of times on gateway/cold-start errors.
      const transient = {502, 503, 504};
      http.Response? resp;
      for (var attempt = 0; attempt < 3; attempt++) {
        resp = await http
            .post(
              uri,
              headers: const {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: json.encode(payload),
            )
            .timeout(const Duration(seconds: 30));
        if (!transient.contains(resp.statusCode)) break;
        await Future.delayed(Duration(milliseconds: 400 * (attempt + 1)));
      }

      if (resp == null) {
        throw 'no_response_from_server';
      }

      if (resp.statusCode == 200) {
        // Robust JSON decode (handles non-UTF8 as well).
        final body = utf8.decode(resp.bodyBytes);
        String aiText = "Tacab AI didn't respond.";

        try {
          final decoded = json.decode(body);

          if (decoded is Map) {
            // Prefer a direct answer string
            if (decoded['answer'] is String &&
                (decoded['answer'] as String).trim().isNotEmpty) {
              aiText = (decoded['answer'] as String).trim();
            } else if (decoded['generated_text'] is String &&
                (decoded['generated_text'] as String).trim().isNotEmpty) {
              aiText = (decoded['generated_text'] as String).trim();
            } else if (decoded['text'] is String &&
                (decoded['text'] as String).trim().isNotEmpty) {
              aiText = (decoded['text'] as String).trim();
            } else if (decoded['bullets'] is List) {
              final bullets = (decoded['bullets'] as List)
                  .whereType<String>()
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList();
              if (bullets.isNotEmpty) {
                aiText = '• ${bullets.join('\n• ')}';
              }
            } else if (decoded['message'] is String &&
                (decoded['message'] as String).trim().isNotEmpty) {
              aiText = (decoded['message'] as String).trim();
            }
          }
        } catch (_) {
          // Keep default fallback if parsing fails
        }

        setState(() {
          _messages.add(ChatMessage(text: aiText, sender: Sender.ai));
          _isGenerating = false;
        });

        // Speak it and persist
        await _convertTextToSpeech(aiText);
        await _saveChatToFirestore(userText, aiText);

        if (_shouldSummarize()) {
          unawaited(_summarizeAndPersist()); // fire and forget
        }
      } else {
        setState(() {
          _messages.add(ChatMessage(
            text: 'Error ${resp!.statusCode}: Tacab AI failed.',
            sender: Sender.ai,
          ));
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: '⚠️ Error: $e',
          sender: Sender.ai,
        ));
      });
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  // Future<void> _submitMessage() async {
  //   if (_controller.text.trim().isEmpty && _selectedImage == null) return;

  //   final userText = _controller.text.trim();

  //   setState(() {
  //     _messages.add(ChatMessage(
  //       text: userText,
  //       image: _selectedImage,
  //       sender: Sender.user,
  //     ));
  //     _controller.clear();
  //     _selectedImage = null;
  //     _isGenerating = true;
  //   });

  //   try {
  //     final response = await http.post(
  //       Uri.parse("https://tacab-somali-agriculture-app.hf.space/generate"),
  //       headers: {"Content-Type": "application/json"},
  //       body: json.encode({"prompt": userText}),
  //       // body: json.encode(
  //       //     {"prompt": userText, "max_length": 128, "temperature": 0.7}),
  //     );

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       final aiText = data["generated_text"] ?? "Tacab AI didn't respond";

  //       setState(() {
  //         _messages.add(ChatMessage(text: aiText, sender: Sender.ai));
  //         _isGenerating = false;
  //       });

  //       await _convertTextToSpeech(aiText);
  //       await _saveChatToFirestore(userText, aiText);
  //     } else {
  //       setState(() {
  //         _messages.add(ChatMessage(
  //           text: "Error ${response.statusCode}: Tacab AI failed.",
  //           sender: Sender.ai,
  //         ));
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _messages.add(ChatMessage(
  //         text: "⚠️ Error: $e",
  //         sender: Sender.ai,
  //       ));
  //     });
  //   } finally {
  //     setState(() => _isGenerating = false);
  //   }
  // }

  // void _showImageSourceOptions() {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (context) {
  //       return SafeArea(
  //         child: Wrap(
  //           children: [
  //             ListTile(
  //               leading: const Icon(Icons.camera_alt),
  //               title: const Text('Camera'),
  //               onTap: () {
  //                 Navigator.pop(context);
  //                 // _pickImage(fromCamera: true);
  //               },
  //             ),
  //             ListTile(
  //               leading: const Icon(Icons.photo_library),
  //               title: const Text('Gallery'),
  //               onTap: () {
  //                 Navigator.pop(context);
  //                 // _pickImage();
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFF73964A),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundImage: _photoUrl != null
                          ? NetworkImage(_photoUrl!)
                          : const AssetImage(
                                  'assets/images/profile_placeholder.png')
                              as ImageProvider,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FirebaseAuth.instance.currentUser?.displayName ??
                                'User',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            FirebaseAuth.instance.currentUser?.email ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Chat History',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: _chatHistoryPairs.isEmpty
                    ? const Center(child: Text('No chat history'))
                    : ListView.builder(
                        itemCount: _chatHistoryPairs.length,
                        itemBuilder: (context, index) {
                          final pair = _chatHistoryPairs[index];
                          // return ListTile(
                          //   title: Text(
                          //     pair['user_message'] ?? '',
                          //     maxLines: 1,
                          //     overflow: TextOverflow.ellipsis,
                          //   ),
                          //   subtitle: Text(
                          //     pair['ai_response'] ?? '',
                          //     maxLines: 1,
                          //     overflow: TextOverflow.ellipsis,
                          //   ),
                          //   onTap: () async {
                          //     final docId = pair['conversation_id'];
                          //     if (docId == null) return;

                          //     // final doc = await _firestore
                          //     //     .collection('users')
                          //     //     .doc(userId)
                          //     //     .collection('conversations')
                          //     //     .doc(docId)
                          //     //     .get();

                          //     // final data = doc.data();
                          //     // final messages =
                          //     //     List.from(data?['messages'] ?? []);
                          //     final messages =
                          //         await ChatHistory.loadConversationMessages(
                          //       firestore: _firestore,
                          //       userId: userId!,
                          //       conversationId: docId,
                          //     );

                          //     setState(() {
                          //       _currentConversationId = docId;
                          //       _messages.clear();
                          //       _messages.addAll(
                          //         messages.map((m) => ChatMessage(
                          //               text: m['text'],
                          //               sender: m['sender'] == 'user'
                          //                   ? Sender.user
                          //                   : Sender.ai,
                          //             )),
                          //       );
                          //       _controller.clear();
                          //       // _selectedImage = null;
                          //     });

                          //     Navigator.pop(context);
                          //   },

                          //   // onTap: () {
                          //   //   Navigator.pop(context);
                          //   // },
                          // );
                          return ListTile(
                            title: Text(
                              pair['user_message'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              pair['ai_response'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              _formatDateYMD(
                                  pair['created_at']), // 👈 shows created date
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            ),
                            onTap: () async {
                              final docId = pair['conversation_id'];
                              if (docId == null) return;

                              final messages =
                                  await ChatHistory.loadConversationMessages(
                                firestore: _firestore,
                                userId: userId!,
                                conversationId: docId,
                              );

                              final summary = await ChatHistory.getSummary(
                                firestore: _firestore,
                                userId: userId!,
                                conversationId: docId,
                              );

                              // setState(() {
                              //   _currentConversationId = docId;
                              //   _messages
                              //     ..clear()
                              //     ..addAll(messages.map((m) => ChatMessage(
                              //           text: m['text'],
                              //           sender: m['sender'] == 'user'
                              //               ? Sender.user
                              //               : Sender.ai,
                              //         )));
                              //   _controller.clear();
                              // });
                              setState(() {
                                _currentConversationId = docId;
                                _conversationSummary = summary ?? '';
                                _messages
                                  ..clear()
                                  ..addAll(messages.map((m) => ChatMessage(
                                        text: m['text'],
                                        sender: m['sender'] == 'user'
                                            ? Sender.user
                                            : Sender.ai,
                                      )));
                                _controller.clear();
                              });

                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundImage: _photoUrl != null
                  ? NetworkImage(_photoUrl!)
                  : const AssetImage('assets/images/profile_placeholder.png')
                      as ImageProvider,
              radius: 18,
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_isTranscribing)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 12),
                    Text("Transcribing voice...",
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.auto_awesome,
                              size: 40, color: Color(0xFF73964A)),
                          Gap(8),
                          Text("Chat with our",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black54)),
                          Text("TACAB AI",
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF73964A))),
                          Gap(4),
                          // Text("ask away using text 🧠, voice 🎤,\nor image 📷",
                          //     textAlign: TextAlign.center,
                          //     style: TextStyle(color: Colors.grey)),
                          Text("ask away using text 🧠 or voice 🎤",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[_messages.length - 1 - index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: message.sender == Sender.user
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (message.sender == Sender.ai)
                                const CircleAvatar(
                                  radius: 16,
                                  backgroundImage: AssetImage(
                                      "assets/images/tacab_ai_icon.png"),
                                ),
                              if (message.sender == Sender.ai)
                                const SizedBox(width: 8),
                              Flexible(
                                child: Container(
                                  // padding: message.image != null
                                  //     ? EdgeInsets.zero
                                  //     : const EdgeInsets.all(12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: message.sender == Sender.user
                                        ? Colors.green[100]
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // if (message.image != null)
                                      //   Stack(
                                      //     children: [
                                      //       ClipRRect(
                                      //         borderRadius:
                                      //             BorderRadius.circular(12),
                                      //         child: Image.file(message.image!,
                                      //             height: 150),
                                      //       ),
                                      //       Positioned(
                                      //         top: 4,
                                      //         right: 4,
                                      //         child: GestureDetector(
                                      //           onTap: () {
                                      //             setState(() {
                                      //               _messages.removeAt(
                                      //                   _messages.length -
                                      //                       1 -
                                      //                       index);
                                      //             });
                                      //           },
                                      //           child: const CircleAvatar(
                                      //             radius: 12,
                                      //             backgroundColor:
                                      //                 Colors.black54,
                                      //             child: Icon(Icons.close,
                                      //                 size: 14,
                                      //                 color: Colors.white),
                                      //           ),
                                      //         ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      if (message.text != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: Text(message.text!),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              if (message.sender == Sender.user)
                                const SizedBox(width: 8),
                              if (message.sender == Sender.user)
                                CircleAvatar(
                                  backgroundImage: _photoUrl != null
                                      ? NetworkImage(_photoUrl!)
                                      : const AssetImage(
                                              'assets/images/profile_placeholder.png')
                                          as ImageProvider,
                                  radius: 18,
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            if (_isGenerating)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage:
                          AssetImage("assets/images/tacab_ai_icon.png"),
                    ),
                    SizedBox(width: 8),
                    TypingIndicator(),
                  ],
                ),
              ),
            // if (_selectedImage != null)
            //   Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 16),
            //     child: Stack(
            //       children: [
            //         ClipRRect(
            //           borderRadius: BorderRadius.circular(12),
            //           child: Image.file(_selectedImage!, height: 150),
            //         ),
            //         Positioned(
            //           top: 4,
            //           right: 4,
            //           child: GestureDetector(
            //             onTap: () => setState(() => _selectedImage = null),
            //             child: const CircleAvatar(
            //               radius: 12,
            //               backgroundColor: Colors.black54,
            //               child:
            //                   Icon(Icons.close, size: 14, color: Colors.white),
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            if (_isRecording)
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  "Recording...",
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            if (_recordingStatus.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  _recordingStatus,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // GestureDetector(
                  //   onTap: _showImageSourceOptions,
                  //   child: const Icon(Icons.camera_alt_outlined,
                  //       color: Colors.grey),
                  // ),
                  // const Gap(12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: _isRecording ? 'Recording...' : 'Ask Tacab',
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const Gap(12),
                  GestureDetector(
                    onTap: (_isTranscribing || _isGenerating)
                        ? null
                        : (hasText ? _submitMessage : _toggleRecording),
                    child: Icon(
                      hasText && !_isRecording
                          ? Icons.send
                          : (_isRecording ? Icons.stop : Icons.mic),
                      color:
                          _isRecording ? Colors.red : const Color(0xFF73964A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dotOne;
  late Animation<double> _dotTwo;
  late Animation<double> _dotThree;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat();

    _dotOne = Tween<double>(begin: 0, end: -4).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut)));
    _dotTwo = Tween<double>(begin: 0, end: -4).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOut)));
    _dotThree = Tween<double>(begin: 0, end: -4).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut)));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildDot(Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, animation.value),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: CircleAvatar(radius: 3, backgroundColor: Colors.black54),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text("Tacab AI is replying",
            style: TextStyle(color: Colors.black87)),
        const SizedBox(width: 8),
        buildDot(_dotOne),
        buildDot(_dotTwo),
        buildDot(_dotThree),
      ],
    );
  }
}
