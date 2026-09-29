import 'package:flutter/material.dart';
import 'package:websocketapp2/screens/loginscreen.dart';
import 'package:websocketapp2/services/firebaseservice.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String name = "Loading...";
  String email = "";
  String status = "Online";

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = _firebaseService.firebaseAuth.currentUser;
    if (user != null) {
      email = user.email ?? "";
      try {
        final doc = await _firebaseService.firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          if (mounted) {
            setState(() {
              name = data['sender'] ?? data['name'] ?? 'User';
              email = data['email'] ?? email;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              name = "User";
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            name = "User";
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(status, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(email),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  await _firebaseService.firebaseAuth.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//typedef profile = ProfileScreen;
