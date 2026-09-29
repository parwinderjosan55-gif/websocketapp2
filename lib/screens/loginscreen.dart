import 'package:flutter/material.dart';
import 'package:websocketapp2/screens/bottomnavigationbar.dart';
import 'package:websocketapp2/screens/registerscreen.dart';
import 'package:websocketapp2/services/firebaseservice.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                          bool success = await FirebaseService().login(
                            email.text.trim(),
                            password.text.trim(),
                          );
                          if (!mounted) return;
                          setState(() => isLoading = false);
                          if (success) {
                            navigator.pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const BottomNavigationScreen(),
                              ),
                            );
                          } else {
                            messenger.showSnackBar(
                              const SnackBar(content: Text("Invalid credentials")),
                            );
                          }
                        },
                        child: const Text('Login'),
                      ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text("Don't have an account? Sign up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//typedef loginsreen = LoginScreen;
