import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:websocketapp2/services/firebaseservice.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController sender = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    sender.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: sender,
                decoration: const InputDecoration(labelText: "Username"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: password,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);
                        setState(() => isLoading = true);
                        await FirebaseService().register(
                          email.text.trim(),
                          password.text.trim(),
                          sender.text.trim(),
                        );
                        if (!mounted) return;
                        setState(() => isLoading = false);
                        if (FirebaseAuth.instance.currentUser != null) {
                          navigator.pop();
                        } else {
                          messenger.showSnackBar(
                            const SnackBar(content: Text("Registration failed")),
                          );
                        }
                      },
                      child: const Text("Register"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

//typedef registerscreen = RegisterScreen;
