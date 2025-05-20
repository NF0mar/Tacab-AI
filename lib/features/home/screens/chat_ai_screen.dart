import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class ChatAIScreen extends StatefulWidget {
  const ChatAIScreen({super.key});

  @override
  State<ChatAIScreen> createState() => _ChatAIScreenState();
}

enum Sender { user, ai }

class ChatMessage {
  final String? text;
  final File? image;
  final Sender sender;

  ChatMessage({this.text, this.image, required this.sender});
}

class _ChatAIScreenState extends State<ChatAIScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecorderInitialized = false;
  String? _recordedFilePath;
  bool _isRecording = false;
  bool _isSending = false;

  final TextEditingController _controller = TextEditingController();
  // String? _submittedText;
  // File? _selectedImage;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  File? _selectedImage; // Holds image before sending

  // The list of chat messages
  final List<ChatMessage> _messages = [];
  bool get hasText => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _speech = stt.SpeechToText();
    _controller.addListener(() {
      setState(() {}); // Trigger rebuild when text changes
    });
  }

  void _initRecorder() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
    _isRecorderInitialized = true;
  }

  void _toggleRecording() async {
    if (!_isRecorderInitialized) return;

    if (_isRecording) {
      final filePath = await _recorder.stopRecorder();
      setState(() {
        _recordedFilePath = filePath;
        _isRecording = false;
      });

      if (filePath != null) {
        setState(() => _isSending = true); // Show loader
        await _sendAudioToASR(filePath);
        setState(() => _isSending = false); // Hide loader
      }
    } else {
      Directory tempDir = await getTemporaryDirectory();
      String filePath = '${tempDir.path}/somali_voice.wav';

      await _recorder.startRecorder(
        toFile: filePath,
        codec: Codec.pcm16WAV,
      );

      setState(() => _isRecording = true);
    }
  }

  // Future<void> _sendAudioToASR(String filePath) async {
  //   final request = http.MultipartRequest(
  //     'POST',
  //     Uri.parse(
  //         'https://api-inference.huggingface.co/models/tacab/tacab_asr'), // Adjust if needed
  //   );

  //   request.files.add(await http.MultipartFile.fromPath('file', filePath));
  //   final response = await request.send();

  //   if (response.statusCode == 200) {
  //     final respStr = await response.stream.bytesToString();
  //     final data = json.decode(respStr);
  //     final text = data['text'] ?? 'Voice not understood';

  //     setState(() {
  //       _messages.add(ChatMessage(text: text, sender: Sender.user));
  //       _messages.add(ChatMessage(
  //           text: "This is a reply from Tacab AI", sender: Sender.ai));
  //     });
  //   } else {
  //     print("❌ Error sending to ASR: ${response.statusCode}");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Failed to transcribe voice')),
  //     );
  //   }
  // }

  Future<void> _sendAudioToASR(String filePath) async {
    final url = Uri.parse('https://tacab-asr.hf.space/run/predict');
    final audioBytes = await File(filePath).readAsBytes();

    final requestBody = {
      "data": [
        {
          "name": "audio.wav",
          "data": base64Encode(audioBytes),
          "mime_type": "audio/wav"
        }
      ]
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final text = result['data'][0]?.toString().trim();

        setState(() {
          _messages.add(ChatMessage(
            text: text == null || text.isEmpty
                ? "Voice was recorded but not understood"
                : text,
            sender: Sender.user,
          ));
          _messages.add(ChatMessage(
            text: "This is a reply from Tacab AI",
            sender: Sender.ai,
          ));
        });
      } else {
        print("❌ ASR failed: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to transcribe (code ${response.statusCode})')),
        );
      }
    } catch (e) {
      print("❌ ASR exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error transcribing voice')),
      );
    }
  }

  // Future<void> _sendAudioToASR(String filePath) async {
  //   final url = Uri.parse(
  //     'https://api-inference.huggingface.co/models/tacab/tacab_asr',
  //   );

  //   final request = http.MultipartRequest('POST', url);

  //   // ✅ Corrected Authorization header
  //   request.headers['Authorization'] =
  //       'Bearer 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';

  //   request.files.add(await http.MultipartFile.fromPath('file', filePath));

  //   try {
  //     final response = await request.send();

  //     if (response.statusCode == 200) {
  //       final responseBody = await response.stream.bytesToString();
  //       final data = json.decode(responseBody);

  //       final text = data['text']?.toString().trim();

  //       setState(() {
  //         _messages.add(ChatMessage(
  //           text: text == null || text.isEmpty
  //               ? "Voice was recorded but not understood"
  //               : text,
  //           sender: Sender.user,
  //         ));

  //         _messages.add(ChatMessage(
  //           text: "This is a reply from Tacab AI",
  //           sender: Sender.ai,
  //         ));
  //       });
  //     } else {
  //       print("❌ ASR failed: ${response.statusCode}");
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //               "Failed to transcribe voice (code ${response.statusCode})"),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     print("❌ ASR error: $e");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //           content: Text("Something went wrong with transcription")),
  //     );
  //   }
  // }

  Future<void> _pickImage({bool fromCamera = false}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path); // Hold image temporarily
      });
    }
  }

  void _submitMessage() {
    if (_controller.text.trim().isEmpty && _selectedImage == null) return;

    setState(() {
      _messages.add(ChatMessage(
        text: _controller.text.trim().isEmpty ? null : _controller.text.trim(),
        image: _selectedImage,
        sender: Sender.user,
      ));

      _controller.clear();
      _selectedImage = null;

      // Simulated AI reply (replace with API later)
      _messages.add(ChatMessage(
          text: 'This is a reply from Tacab AI', sender: Sender.ai));
    });
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(fromCamera: true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          print('Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          print('Speech error: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Speech error: ${error.errorMsg}')),
          );
          setState(() => _isListening = false);
        },
      );

      if (available) {
        setState(() => _isListening = true);
        String transcript = "";

        _speech.listen(
          onResult: (val) {
            print('🎤 Speech result: ${val.recognizedWords}');
            print('🎤 Final result? ${val.finalResult}');
            transcript = val.recognizedWords;
            _controller.text = transcript;

            if (val.finalResult && transcript.trim().isNotEmpty) {
              setState(() => _isListening = false);
              _speech.stop(); // ✅ call without await
              Future.delayed(const Duration(milliseconds: 300), () {
                _submitMessage();
              });
            }
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition not available')),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {},
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage("assets/images/profile.jpg"),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_isSending)
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
                          Text("ask away using text 🧠, voice 🎤,\nor image 📷",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey))
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
                                      "assets/images/tacab_ai_icon.png"), // Add your AI avatar asset
                                ),
                              if (message.sender == Sender.ai)
                                const SizedBox(width: 8),
                              Flexible(
                                child: Container(
                                  padding: message.image != null
                                      ? EdgeInsets.zero
                                      : const EdgeInsets.all(12),
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
                                      if (message.image != null)
                                        Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.file(message.image!,
                                                  height: 150),
                                            ),
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _messages.removeAt(
                                                        _messages.length -
                                                            1 -
                                                            index);
                                                  });
                                                },
                                                child: const CircleAvatar(
                                                  radius: 12,
                                                  backgroundColor:
                                                      Colors.black54,
                                                  child: Icon(Icons.close,
                                                      size: 14,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
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
                                const CircleAvatar(
                                  radius: 16,
                                  backgroundImage:
                                      AssetImage("assets/images/profile.jpg"),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_selectedImage!, height: 150),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedImage = null);
                        },
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black54,
                          child:
                              Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_isRecording)
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  "Recording...",
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _showImageSourceOptions,
                    child: const Icon(Icons.camera_alt_outlined,
                        color: Colors.grey),
                  ),
                  const Gap(12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Ask Tacab',
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
                    // onTap: hasText ? _submitMessage : _toggleRecording,
                    onTap: _isSending
                        ? null
                        : (hasText ? _submitMessage : _toggleRecording),
                    child: Icon(
                      hasText
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
