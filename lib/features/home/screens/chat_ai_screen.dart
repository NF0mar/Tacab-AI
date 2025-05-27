// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'dart:io';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:tacab_ai/features/home/screens/ChatHistoryScreen.dart';
// import 'dart:convert';
// import 'package:tacab_ai/features/home/screens/tacab_tts.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ChatAIScreen extends StatefulWidget {
//   const ChatAIScreen({super.key});

//   @override
//   State<ChatAIScreen> createState() => _ChatAIScreenState();
// }

// enum Sender { user, ai }

// class ChatMessage {
//   final String? text;
//   final File? image;
//   final Sender sender;

//   ChatMessage({this.text, this.image, required this.sender});
// }

// class _ChatAIScreenState extends State<ChatAIScreen> {
//   final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
//   bool _isRecorderInitialized = false;
//   String? _recordedFilePath;
//   bool _isRecording = false;
//   bool _isSending = false;
//   final TacabTTS _tts = TacabTTS();
//   final String? userId = FirebaseAuth.instance.currentUser?.uid;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   final TextEditingController _controller = TextEditingController();
//   // String? _submittedText;
//   // File? _selectedImage;
//   late stt.SpeechToText _speech;
//   bool _isListening = false;
//   File? _selectedImage; // Holds image before sending

//   // The list of chat messages
//   final List<ChatMessage> _messages = [];
//   bool get hasText => _controller.text.trim().isNotEmpty;

//   @override
//   void initState() {
//     super.initState();
//     _initRecorder();
//     _speech = stt.SpeechToText();
//     _controller.addListener(() {
//       setState(() {}); // Trigger rebuild when text changes
//     });
//     _warmUpTacabApis(); // Warm up Tacab APIs on startup
//     _loadChatHistory();
//   }

//   void _warmUpTacabApis() async {
//     await http.post(
//       Uri.parse("https://tacab-somali-textgen.hf.space/generate"),
//       headers: {"Content-Type": "application/json"},
//       body: json.encode({"inputs": "salaan"}), // Tiny dummy prompt
//     );

//     await http.post(
//       Uri.parse("https://tacab-tts.hf.space/synthesize"),
//       headers: {"Content-Type": "application/json"},
//       body: json.encode({"inputs": "hello"}), // Small warm-up text
//     );
//   }

//   Future<void> _loadChatHistory() async {
//     if (userId == null) return;

//     try {
//       final snapshot = await _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('chat_history')
//           .orderBy('timestamp', descending: false)
//           .get();

//       final loadedMessages = <ChatMessage>[];

//       for (var doc in snapshot.docs) {
//         final data = doc.data();
//         loadedMessages
//             .add(ChatMessage(text: data['user_message'], sender: Sender.user));
//         loadedMessages
//             .add(ChatMessage(text: data['ai_response'], sender: Sender.ai));
//       }

//       setState(() {
//         _messages.clear();
//         _messages.addAll(loadedMessages);
//       });
//     } catch (e) {
//       print("Failed to load chat history: $e");
//     }
//   }

//   Future<void> _saveChatToFirestore(String userText, String aiText) async {
//     if (userId == null) {
//       print("User not logged in, skipping Firestore save");
//       return;
//     }
//     try {
//       await _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('chat_history')
//           .add({
//         'user_message': userText,
//         'ai_response': aiText,
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//       print("Chat saved to Firestore");
//     } catch (e) {
//       print("Failed to save chat to Firestore: $e");
//     }
//   }

//   void _initRecorder() async {
//     await Permission.microphone.request();
//     await _recorder.openRecorder();
//     _isRecorderInitialized = true;
//   }

//   void _toggleRecording() async {
//     if (!_isRecorderInitialized) return;

//     if (_isRecording) {
//       final filePath = await _recorder.stopRecorder();
//       setState(() {
//         _recordedFilePath = filePath;
//         _isRecording = false;
//       });

//       final file = File(filePath!);
//       final length = await file.length();

//       if (!await file.exists() || length < 1000) {
//         print("❌ Invalid audio: size = $length bytes");
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Recording too short. Try again.")),
//         );
//         return;
//       }

//       print("✅ Recording valid. Sending to ASR...");
//       setState(() => _isSending = true);
//       await _sendAudioToASR(filePath);
//       setState(() => _isSending = false);
//     } else {
//       Directory tempDir = await getTemporaryDirectory();
//       String filePath = '${tempDir.path}/somali_voice.wav';

//       await _recorder.startRecorder(
//         toFile: filePath,
//         codec: Codec.pcm16WAV,
//       );

//       setState(() => _isRecording = true);
//     }
//   }

//   Future<void> _sendAudioToASR(String filePath) async {
//     final uri =
//         Uri.parse("https://tacab-asr-transcription.hf.space/transcribe");

//     final request = http.MultipartRequest("POST", uri);
//     request.files.add(await http.MultipartFile.fromPath("file", filePath));

//     try {
//       final response = await request.send();

//       if (response.statusCode == 200) {
//         final responseBody = await response.stream.bytesToString();
//         final data = json.decode(responseBody);
//         final text =
//             data["text"] ?? "Voice was transcribed but not understood.";

//         setState(() {
//           _messages.add(ChatMessage(text: text, sender: Sender.user));
//           _controller.text = text;
//           _submitMessage(); // Send transcribed text to Tacab AI for reply
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("ASR Error: ${response.statusCode}")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("ASR Exception: $e")),
//       );
//     }
//   }

//   Future<void> _pickImage({bool fromCamera = false}) async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(
//       source: fromCamera ? ImageSource.camera : ImageSource.gallery,
//     );
//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path); // Hold image temporarily
//       });
//     }
//   }

//   Future<void> _convertTextToSpeech(String text) async {
//     final filePath = await _tts.synthesizeAndSaveAudio(text);
//     if (filePath != null) {
//       await _tts.playAudio(filePath);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to synthesize speech')),
//       );
//     }
//   }

//   Future<void> _submitMessage() async {
//     if (_controller.text.trim().isEmpty && _selectedImage == null) return;

//     final userText = _controller.text.trim();

//     setState(() {
//       _messages.add(ChatMessage(
//         text: userText,
//         image: _selectedImage,
//         sender: Sender.user,
//       ));
//       _controller.clear();
//       _selectedImage = null;
//       _isSending = true;
//     });

//     try {
//       final response = await http.post(
//         Uri.parse("https://tacab-somali-textgen.hf.space/generate"),
//         headers: {"Content-Type": "application/json"},
//         body: json.encode({"inputs": userText}),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final aiText = data["generated_text"] ?? "Tacab AI didn't respond";

//         setState(() {
//           _messages.add(ChatMessage(text: aiText, sender: Sender.ai));
//         });

//         await _convertTextToSpeech(aiText);

//         // Save chat pair to Firestore
//         await _saveChatToFirestore(userText, aiText);
//       } else {
//         setState(() {
//           _messages.add(ChatMessage(
//             text: "Error ${response.statusCode}: Tacab AI failed.",
//             sender: Sender.ai,
//           ));
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _messages.add(ChatMessage(
//           text: "⚠️ Error: $e",
//           sender: Sender.ai,
//         ));
//       });
//     } finally {
//       setState(() => _isSending = false);
//     }
//   }

//   void _showImageSourceOptions() {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return SafeArea(
//           child: Wrap(
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.camera_alt),
//                 title: const Text('Camera'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImage(fromCamera: true);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('Gallery'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImage();
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _listen() async {
//     if (!_isListening) {
//       bool available = await _speech.initialize(
//         onStatus: (status) {
//           print('Speech status: $status');
//           if (status == 'done' || status == 'notListening') {
//             setState(() => _isListening = false);
//           }
//         },
//         onError: (error) {
//           print('Speech error: $error');
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Speech error: ${error.errorMsg}')),
//           );
//           setState(() => _isListening = false);
//         },
//       );

//       if (available) {
//         setState(() => _isListening = true);
//         String transcript = "";

//         _speech.listen(
//           onResult: (val) {
//             print('🎤 Speech result: ${val.recognizedWords}');
//             print('🎤 Final result? ${val.finalResult}');
//             transcript = val.recognizedWords;
//             _controller.text = transcript;

//             if (val.finalResult && transcript.trim().isNotEmpty) {
//               setState(() => _isListening = false);
//               _speech.stop(); // ✅ call without await
//               Future.delayed(const Duration(milliseconds: 300), () {
//                 _submitMessage();
//               });
//             }
//           },
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Speech recognition not available')),
//         );
//       }
//     } else {
//       setState(() => _isListening = false);
//       _speech.stop();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.menu, color: Colors.black87),
//           onPressed: () {
//              Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const ChatHistoryScreen()),
//             );
//           },
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 12),
//             child: CircleAvatar(
//               radius: 18,
//               backgroundImage: AssetImage("assets/images/profile.jpg"),
//             ),
//           )
//         ],
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             if (_isSending)
//               const Padding(
//                 padding: EdgeInsets.all(8),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularProgressIndicator(),
//                     SizedBox(width: 12),
//                     Text("Transcribing voice...",
//                         style: TextStyle(color: Colors.grey)),
//                   ],
//                 ),
//               ),
//             Expanded(
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: _messages.isEmpty
//                         ? Center(
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: const [
//                                 Icon(Icons.auto_awesome,
//                                     size: 40, color: Color(0xFF73964A)),
//                                 Gap(8),
//                                 Text("Chat with our",
//                                     style: TextStyle(
//                                         fontSize: 16, color: Colors.black54)),
//                                 Text("TACAB AI",
//                                     style: TextStyle(
//                                         fontSize: 24,
//                                         fontWeight: FontWeight.bold,
//                                         color: Color(0xFF73964A))),
//                                 Gap(4),
//                                 Text(
//                                     "ask away using text 🧠, voice 🎤,\nor image 📷",
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(color: Colors.grey)),
//                               ],
//                             ),
//                           )
//                         : ListView.builder(
//                             reverse: true,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 16, vertical: 10),
//                             itemCount: _messages.length,
//                             itemBuilder: (context, index) {
//                               final message =
//                                   _messages[_messages.length - 1 - index];
//                               return Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(vertical: 4),
//                                 child: Row(
//                                   mainAxisAlignment:
//                                       message.sender == Sender.user
//                                           ? MainAxisAlignment.end
//                                           : MainAxisAlignment.start,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     if (message.sender == Sender.ai)
//                                       const CircleAvatar(
//                                         radius: 16,
//                                         backgroundImage: AssetImage(
//                                             "assets/images/tacab_ai_icon.png"),
//                                       ),
//                                     if (message.sender == Sender.ai)
//                                       const SizedBox(width: 8),
//                                     Flexible(
//                                       child: Container(
//                                         padding: message.image != null
//                                             ? EdgeInsets.zero
//                                             : const EdgeInsets.all(12),
//                                         decoration: BoxDecoration(
//                                           color: message.sender == Sender.user
//                                               ? Colors.green[100]
//                                               : Colors.grey[300],
//                                           borderRadius:
//                                               BorderRadius.circular(12),
//                                         ),
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             if (message.image != null)
//                                               Stack(
//                                                 children: [
//                                                   ClipRRect(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             12),
//                                                     child: Image.file(
//                                                         message.image!,
//                                                         height: 150),
//                                                   ),
//                                                   Positioned(
//                                                     top: 4,
//                                                     right: 4,
//                                                     child: GestureDetector(
//                                                       onTap: () {
//                                                         setState(() {
//                                                           _messages.removeAt(
//                                                               _messages.length -
//                                                                   1 -
//                                                                   index);
//                                                         });
//                                                       },
//                                                       child: const CircleAvatar(
//                                                         radius: 12,
//                                                         backgroundColor:
//                                                             Colors.black54,
//                                                         child: Icon(Icons.close,
//                                                             size: 14,
//                                                             color:
//                                                                 Colors.white),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             if (message.text != null)
//                                               Padding(
//                                                 padding: const EdgeInsets.only(
//                                                     top: 8),
//                                                 child: Text(message.text!),
//                                               ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                     if (message.sender == Sender.user)
//                                       const SizedBox(width: 8),
//                                     if (message.sender == Sender.user)
//                                       const CircleAvatar(
//                                         radius: 16,
//                                         backgroundImage: AssetImage(
//                                             "assets/images/profile.jpg"),
//                                       ),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),
//                   ),

//                   // ✅ Tacab AI typing indicator
//                   if (_isSending)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 8),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: const [
//                           CircleAvatar(
//                             radius: 16,
//                             backgroundImage:
//                                 AssetImage("assets/images/tacab_ai_icon.png"),
//                           ),
//                           SizedBox(width: 8),
//                           TypingIndicator(),
//                         ],
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             if (_selectedImage != null)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Stack(
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Image.file(_selectedImage!, height: 150),
//                     ),
//                     Positioned(
//                       top: 4,
//                       right: 4,
//                       child: GestureDetector(
//                         onTap: () {
//                           setState(() => _selectedImage = null);
//                         },
//                         child: const CircleAvatar(
//                           radius: 12,
//                           backgroundColor: Colors.black54,
//                           child:
//                               Icon(Icons.close, size: 14, color: Colors.white),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             if (_isRecording)
//               const Padding(
//                 padding: EdgeInsets.only(bottom: 4),
//                 child: Text(
//                   "Recording...",
//                   style:
//                       TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: _showImageSourceOptions,
//                     child: const Icon(Icons.camera_alt_outlined,
//                         color: Colors.grey),
//                   ),
//                   const Gap(12),
//                   Expanded(
//                     child: TextField(
//                       controller: _controller,
//                       decoration: InputDecoration(
//                         hintText: 'Ask Tacab',
//                         fillColor: Colors.grey.shade100,
//                         filled: true,
//                         contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 12),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const Gap(12),
//                   GestureDetector(
//                     // onTap: hasText ? _submitMessage : _toggleRecording,
//                     onTap: _isSending
//                         ? null
//                         : (hasText ? _submitMessage : _toggleRecording),
//                     child: Icon(
//                       hasText
//                           ? Icons.send
//                           : (_isRecording ? Icons.stop : Icons.mic),
//                       color:
//                           _isRecording ? Colors.red : const Color(0xFF73964A),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class TypingIndicator extends StatefulWidget {
//   const TypingIndicator({super.key});

//   @override
//   State<TypingIndicator> createState() => _TypingIndicatorState();
// }

// class _TypingIndicatorState extends State<TypingIndicator>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _dotOne;
//   late Animation<double> _dotTwo;
//   late Animation<double> _dotThree;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 1000))
//       ..repeat();

//     _dotOne = Tween<double>(begin: 0, end: -4).animate(CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.0, 0.6, curve: Curves.easeInOut)));
//     _dotTwo = Tween<double>(begin: 0, end: -4).animate(CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.2, 0.8, curve: Curves.easeInOut)));
//     _dotThree = Tween<double>(begin: 0, end: -4).animate(CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.4, 1.0, curve: Curves.easeInOut)));
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Widget buildDot(Animation<double> animation) {
//     return AnimatedBuilder(
//       animation: animation,
//       builder: (_, __) => Transform.translate(
//         offset: Offset(0, animation.value),
//         child: const Padding(
//           padding: EdgeInsets.symmetric(horizontal: 2),
//           child: CircleAvatar(radius: 3, backgroundColor: Colors.black54),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         const Text("Tacab AI is replying",
//             style: TextStyle(color: Colors.black87)),
//         const SizedBox(width: 8),
//         buildDot(_dotOne),
//         buildDot(_dotTwo),
//         buildDot(_dotThree),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:tacab_ai/features/home/screens/tacab_tts.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecorderInitialized = false;
  String? _recordedFilePath;
  bool _isRecording = false;
  bool _isSending = false;
  final TacabTTS _tts = TacabTTS();
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _controller = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  File? _selectedImage; // Holds image before sending

  // Store chat messages shown in main chat area
  final List<ChatMessage> _messages = [];
  // Store chat history pairs for drawer
  List<Map<String, String?>> _chatHistoryPairs = [];

  bool get hasText => _controller.text.trim().isNotEmpty;

  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _speech = stt.SpeechToText();
    _controller.addListener(() {
      setState(() {}); // Trigger rebuild when text changes
    });
    _warmUpTacabApis();
    _loadChatHistory();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _photoUrl = user?.photoURL;
    });
  }

  void _warmUpTacabApis() async {
    await http.post(
      Uri.parse("https://tacab-somali-textgen.hf.space/generate"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"inputs": "salaan"}),
    );

    await http.post(
      Uri.parse("https://tacab-tts.hf.space/synthesize"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"inputs": "hello"}),
    );
  }

  Future<void> _loadChatHistory() async {
    if (userId == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chat_history')
          .orderBy('timestamp', descending: false)
          .get();

      final loadedMessages = <ChatMessage>[];
      final loadedPairs = <Map<String, String?>>[];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        loadedMessages
            .add(ChatMessage(text: data['user_message'], sender: Sender.user));
        loadedMessages
            .add(ChatMessage(text: data['ai_response'], sender: Sender.ai));
        loadedPairs.add({
          'user_message': data['user_message'] as String?,
          'ai_response': data['ai_response'] as String?,
        });
      }

      setState(() {
        _messages.clear();
        _messages.addAll(loadedMessages);
        _chatHistoryPairs = loadedPairs;
      });
    } catch (e) {
      print("Failed to load chat history: $e");
    }
  }

  Future<void> _saveChatToFirestore(String userText, String aiText) async {
    if (userId == null) {
      print("User not logged in, skipping Firestore save");
      return;
    }
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('chat_history')
          .add({
        'user_message': userText,
        'ai_response': aiText,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("Chat saved to Firestore");
      // Also update drawer list in real time
      setState(() {
        _chatHistoryPairs
            .add({'user_message': userText, 'ai_response': aiText});
      });
    } catch (e) {
      print("Failed to save chat to Firestore: $e");
    }
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

      final file = File(filePath!);
      final length = await file.length();

      if (!await file.exists() || length < 1000) {
        print("❌ Invalid audio: size = $length bytes");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recording too short. Try again.")),
        );
        return;
      }

      print("✅ Recording valid. Sending to ASR...");
      setState(() => _isSending = true);
      await _sendAudioToASR(filePath);
      setState(() => _isSending = false);
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

  Future<void> _sendAudioToASR(String filePath) async {
    final uri =
        Uri.parse("https://tacab-asr-transcription.hf.space/transcribe");

    final request = http.MultipartRequest("POST", uri);
    request.files.add(await http.MultipartFile.fromPath("file", filePath));

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);
        final text =
            data["text"] ?? "Voice was transcribed but not understood.";

        setState(() {
          _messages.add(ChatMessage(text: text, sender: Sender.user));
          _controller.text = text;
          _submitMessage();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ASR Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("ASR Exception: $e")),
      );
    }
  }

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

  Future<void> _submitMessage() async {
    if (_controller.text.trim().isEmpty && _selectedImage == null) return;

    final userText = _controller.text.trim();

    setState(() {
      _messages.add(ChatMessage(
        text: userText,
        image: _selectedImage,
        sender: Sender.user,
      ));
      _controller.clear();
      _selectedImage = null;
      _isSending = true;
    });

    try {
      final response = await http.post(
        Uri.parse("https://tacab-somali-textgen.hf.space/generate"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"inputs": userText}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final aiText = data["generated_text"] ?? "Tacab AI didn't respond";

        setState(() {
          _messages.add(ChatMessage(text: aiText, sender: Sender.ai));
        });

        await _convertTextToSpeech(aiText);

        await _saveChatToFirestore(userText, aiText);
      } else {
        setState(() {
          _messages.add(ChatMessage(
            text: "Error ${response.statusCode}: Tacab AI failed.",
            sender: Sender.ai,
          ));
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: "⚠️ Error: $e",
          sender: Sender.ai,
        ));
      });
    } finally {
      setState(() => _isSending = false);
    }
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
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
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
            transcript = val.recognizedWords;
            _controller.text = transcript;

            if (val.finalResult && transcript.trim().isNotEmpty) {
              setState(() => _isListening = false);
              _speech.stop();
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

  Future<String> generateTextWithOpenAI(String prompt) async {
    const apiKey = "sk-proj-..."; // Use your actual API key
    const endpoint = "https://api.openai.com/v1/chat/completions";

    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $apiKey",
    };

    final body = jsonEncode({
      "model": "gpt-3.5-turbo",
      "messages": [
        {"role": "user", "content": prompt}
      ],
      "temperature": 0.7,
      "max_tokens": 256,
    });

    final response =
        await http.post(Uri.parse(endpoint), headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["choices"][0]["message"]["content"].toString().trim();
    } else {
      throw Exception("OpenAI API Error: ${response.body}");
    }
  }


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
                            onTap: () {
                              Navigator.pop(context);
                              // Optional: Scroll or highlight in chat
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
                                // const CircleAvatar(
                                //   radius: 16,
                                //   backgroundImage:
                                //       AssetImage("assets/images/profile.jpg"),
                                // ),
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
            if (_isSending)
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
                        onTap: () => setState(() => _selectedImage = null),
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
