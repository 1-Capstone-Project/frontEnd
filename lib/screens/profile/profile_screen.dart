import 'package:flutter/material.dart';
import 'setting_screen.dart'; // SettingScreen을 가져오기 위해 import 추가

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text("프로필"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // SettingScreen으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingScreen()),
              );
            },
            style: ButtonStyle(
              overlayColor: WidgetStateProperty.all(Colors.transparent),
            ),
          ),
        ],
      ),
      body: Center(
        child: Text('Profile Content'),
      ),
    );
  }
}
