import 'package:flutter/material.dart';
import 'package:websocketapp2/model/usermodel.dart';
import 'package:websocketapp2/screens/chatscreen.dart';
import 'package:websocketapp2/services/firebaseservice.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final currentUserId = _firebaseService.firebaseAuth.currentUser?.uid;
    List<UserModel> users = await _firebaseService.getuser();
    if (currentUserId != null) {
      users = users.where((u) => u.uid != currentUserId).toList();
    }
    if (!mounted) return;
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  void _showAddUserByEmailDialog() {
    final emailController = TextEditingController();
    bool isSearching = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text("Start Chat by Email"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "User Email",
                      hintText: "example@gmail.com",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  if (isSearching) ...[
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSearching ? null : () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isSearching
                      ? null
                      : () async {
                          final inputEmail = emailController.text.trim().toLowerCase();
                          if (inputEmail.isEmpty) return;

                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);
                          final dialogNavigator = Navigator.of(dialogContext);

                          final currentUser = _firebaseService.firebaseAuth.currentUser;
                          if (currentUser != null &&
                              currentUser.email?.toLowerCase() == inputEmail) {
                            messenger.showSnackBar(
                              const SnackBar(content: Text("You cannot chat with yourself")),
                            );
                            return;
                          }

                          setDialogState(() => isSearching = true);

                          try {
                            final query = await _firebaseService.firestore
                                .collection('users')
                                .where('email', isEqualTo: inputEmail)
                                .get();

                            if (!mounted) return;

                            if (query.docs.isNotEmpty) {
                              final userData = query.docs.first.data();
                              final targetUser = UserModel.fromJson(userData);

                              dialogNavigator.pop(); // Close dialog

                              _fetchUsers(); // Refresh list

                              navigator.push(
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(receiver: targetUser),
                                ),
                              );
                            } else {
                              setDialogState(() => isSearching = false);
                              messenger.showSnackBar(
                                SnackBar(content: Text("No user found with email $inputEmail")),
                              );
                            }
                          } catch (e) {
                            if (!mounted) return;
                            setDialogState(() => isSearching = false);
                            messenger.showSnackBar(
                              SnackBar(content: Text("Error searching user: $e")),
                            );
                          }
                        },
                  child: const Text("Start Chat"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("People"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchUsers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(child: Text("No other users found"))
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    final displayName = user.name.isNotEmpty ? user.name : user.email;
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(displayName),
                      subtitle: Text(user.email),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(receiver: user),
                          ),
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddUserByEmailDialog,
        icon: const Icon(Icons.mark_email_unread_outlined),
        label: const Text("Chat by Email"),
      ),
    );
  }
}

//typedef peoplescreen = PeopleScreen;
