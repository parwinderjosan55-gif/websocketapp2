import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:websocketapp2/model/chatmodel.dart';
import 'package:websocketapp2/model/usermodel.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> register(String email, String password, String sender) async {
    try {
      UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);

      User? user = userCredential.user;
      if (user != null) {
        await firestore.collection('users').doc(user.uid).set({
          'email': email,
          'sender': sender,
          'name': sender,
          'uid': user.uid,
          'fcmToken': '',
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint('user register successfully');
      }
    } on FirebaseException catch (e) {
      debugPrint(e.message);
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseException catch (e) {
      debugPrint(e.message);
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<ChatMessageModel? > getchat(String uid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc =
      await firestore.collection("users").doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return null;
      }
    } on FirebaseException catch (e) {
      debugPrint("firestore error ${e.message}");
    } catch (e) {
      debugPrint("error fetching user data $e");
    }
    return null;
  }

  Future<List<UserModel>> getuser() async {
    try {
      QuerySnapshot snapshot = await firestore.collection('users').get();
      return snapshot.docs.map((doc) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } on FirebaseException catch (e) {
      debugPrint(e.message);
      return [];
    } catch (e) {
      debugPrint("error fetching users $e");
      return [];
    }
  }

  Future<void> sendMessage(String receiverId, String message) async {
    final String currentUserId = firebaseAuth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    await firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'senderId': currentUserId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
    });
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}


