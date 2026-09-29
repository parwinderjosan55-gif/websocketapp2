import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:websocketapp2/model/usermodel.dart';
import 'package:websocketapp2/services/FCMPushNotificationService.dart';
import 'package:websocketapp2/services/firebaseservice.dart';
import 'package:websocketapp2/services/notificationservice.dart';

class ChatPage extends StatefulWidget {
  final UserModel receiver;

  const ChatPage({super.key, required this.receiver});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _lastNotifiedMessageId;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      _messageController.clear();
      await _firebaseService.sendMessage(
          widget.receiver.uid, messageText);
      _sendFcmNotification(messageText);
    }
  }

  Future<void> _sendFcmNotification(String messageText) async {
    try {
      String receiverToken = widget.receiver.fcmToken;
      if (receiverToken.isEmpty) {
        final doc = await _firebaseService.firestore
            .collection('users')
            .doc(widget.receiver.uid)
            .get();
        if (doc.exists && doc.data() != null) {
          receiverToken = doc.data()?['fcmToken'] ?? '';
        }
      }

      if (receiverToken.isNotEmpty) {
        final currentUserId = _auth.currentUser?.uid;
        String senderName = "New Message";
        if (currentUserId != null) {
          final currentUserDoc = await _firebaseService.firestore
              .collection('users')
              .doc(currentUserId)
              .get();
          if (currentUserDoc.exists && currentUserDoc.data() != null) {
            senderName = currentUserDoc.data()?['sender'] ??
                currentUserDoc.data()?['name'] ??
                _auth.currentUser?.email ??
                "New Message";
          }
        }

        await FcmService().sendNotification(
          token: receiverToken,
          title: senderName,
          body: messageText,
        );
      }
    } catch (e) {
      debugPrint("Error sending FCM notification: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiver.name.isNotEmpty ? widget.receiver.name : widget.receiver.email),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Center(child: Text("User not logged in"));
    }
    return StreamBuilder<QuerySnapshot>(                                        // this is the streambuilder code
      stream: _firebaseService.getMessages(currentUser.uid, widget.receiver.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No messages yet"));
        }

        final docs = snapshot.data!.docs;                   //   start the FCMNotification code under the streambuilder code
        if (docs.isNotEmpty) {
          final lastDoc = docs.last;
          final data = lastDoc.data() as Map<String, dynamic>;
          final messageId = lastDoc.id;
          final senderId = data['senderId'];


          if (senderId != currentUser.uid && _lastNotifiedMessageId != messageId) {
            if (_lastNotifiedMessageId != null) {
              final senderTitle = widget.receiver.name.isNotEmpty
                  ? widget.receiver.name
                  : widget.receiver.email;
              notificationservice().shownotification(
                id: messageId.hashCode,
                title: senderTitle,
                body: data['message'] ?? '',
              );
            }
            _lastNotifiedMessageId = messageId;
          }
        }                                            // the end of fcm notification code here

        return ListView(
          padding: const EdgeInsets.all(8.0),
          children: docs.map((document) => _buildMessageItem(document)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    final currentUserId = _auth.currentUser?.uid;
    bool isMe = data['senderId'] == currentUserId;

    var alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isMe ? Colors.teal : Colors.grey[300],
              ),
              child: Text(
                data['message'] ?? '',
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Enter message',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: sendMessage,
            icon: const Icon(Icons.send, color: Colors.teal),
          ),
        ],
      ),
    );
  }
}

typedef ChatScreen = ChatPage;
typedef chatscreen = ChatPage;
