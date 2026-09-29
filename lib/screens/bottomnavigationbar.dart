import 'package:flutter/material.dart';
import 'package:websocketapp2/screens/peoplescreen.dart';
import 'package:websocketapp2/screens/profilescreen.dart';
import 'package:websocketapp2/services/FCMPushNotificationService.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  final List<Widget> screens = const [
    PeopleScreen(),
    ProfileScreen(),
  ];

  int currentindex = 0;

  @override
  void initState() {
    super.initState();
    _initFcm();
  }

  void _initFcm() async {
    try {
      await FcmService().init();
    } catch (e) {
      debugPrint("FCM initialization error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentindex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentindex,
        onTap: (int index) {
          setState(() {
            currentindex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "People"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

//typedef bottomnavegation = BottomNavigationScreen;
//typedef BottomNavigation = BottomNavigationScreen;
//typedef BottomNavigationBarScreen = BottomNavigationScreen;
