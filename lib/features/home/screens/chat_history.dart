import 'package:cloud_firestore/cloud_firestore.dart';

class ChatHistory {
  /// Build the drawer's history pairs (most recent first).
  static Future<List<Map<String, String?>>> loadHistoryPairs({
    required FirebaseFirestore firestore,
    required String userId,
  }) async {
    final snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .orderBy('created_at', descending: true)
        .get();

    final loadedPairs = <Map<String, String?>>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final messages = List.from(data['messages'] ?? []);
      if (messages.isEmpty) continue; // skip brand-new/empty convos

      String? firstUserMessage;
      String? firstAiResponse;

      final userMsg = messages.firstWhere(
        (m) =>
            m['sender'] == 'user' &&
            (m['text'] ?? '').toString().trim().isNotEmpty,
        orElse: () => null,
      );
      firstUserMessage = userMsg?['text'];

      final aiMsg = messages.firstWhere(
        (m) =>
            m['sender'] == 'ai' &&
            (m['text'] ?? '').toString().trim().isNotEmpty,
        orElse: () => null,
      );
      firstAiResponse = aiMsg?['text'];

      final u = (firstUserMessage ?? '').trim();
      final a = (firstAiResponse ?? '').trim();
      if (u.isEmpty && a.isEmpty) continue;

      // ✅ include created_at (falls back to updated_at if present)
      final ts = (data['created_at'] ?? data['updated_at']);
      String? createdIso;
      if (ts is Timestamp) {
        createdIso = ts.toDate().toIso8601String();
      } else if (ts is DateTime) {
        createdIso = ts.toIso8601String();
      }

      loadedPairs.add({
        'user_message': u.isEmpty ? null : u,
        'ai_response': a.isEmpty ? null : a,
        'conversation_id': doc.id,
        'created_at': createdIso, // 👈 new field
      });
    }

    return loadedPairs;
  }

  /// Create a new empty conversation, returns its id.
  static Future<String> startNewConversation({
    required FirebaseFirestore firestore,
    required String userId,
  }) async {
    final doc = await firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .add({
      'messages': [],
      'created_at': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  /// Append a user/ai exchange into the active conversation.
  // static Future<void> saveExchange({
  //   required FirebaseFirestore firestore,
  //   required String userId,
  //   required String conversationId,
  //   required String userText,
  //   required String aiText,
  // }) async {
  //   final docRef = firestore
  //       .collection('users')
  //       .doc(userId)
  //       .collection('conversations')
  //       .doc(conversationId);

  //   await docRef.update({
  //     'messages': FieldValue.arrayUnion([
  //       {'text': userText, 'sender': 'user'},
  //       {'text': aiText, 'sender': 'ai'},
  //     ]),
  //     'updated_at':
  //         FieldValue.serverTimestamp(), // 👈 optional, for future sort
  //   });
  // }

  static Future<void> saveExchange({
    required FirebaseFirestore firestore,
    required String userId,
    required String conversationId,
    required String userText,
    required String aiText,
  }) async {
    final docRef = firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .doc(conversationId);

    // Unique ids ensure arrayUnion never dedups your messages
    final stamp = DateTime.now().microsecondsSinceEpoch.toString();

    await docRef.update({
      'messages': FieldValue.arrayUnion([
        {'id': 'u_$stamp', 'text': userText, 'sender': 'user'},
        {'id': 'a_$stamp', 'text': aiText, 'sender': 'ai'},
      ]),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }


  /// Load all messages for a conversation (used when tapping a history item).
  static Future<List<Map<String, dynamic>>> loadConversationMessages({
    required FirebaseFirestore firestore,
    required String userId,
    required String conversationId,
  }) async {
    final doc = await firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .doc(conversationId)
        .get();

    final data = doc.data();
    final messages = List<Map<String, dynamic>>.from(
      (data?['messages'] ?? []) as List,
    );
    return messages;
  }

  /// Read the stored conversation summary ("memory").
  static Future<String?> getSummary({
    required FirebaseFirestore firestore,
    required String userId,
    required String conversationId,
  }) async {
    final doc = await firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .doc(conversationId)
        .get();
    return (doc.data()?['summary'] as String?)?.trim();
  }

  /// Persist/update the summary.
  static Future<void> setSummary({
    required FirebaseFirestore firestore,
    required String userId,
    required String conversationId,
    required String summary,
  }) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .doc(conversationId)
        .update({
      'summary': summary.trim(),
      'updated_at': FieldValue.serverTimestamp()
    });
  }
}
