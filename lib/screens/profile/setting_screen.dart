import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gitmate/screens/profile/account_screen.dart';
import 'package:gitmate/screens/sign/sign_in_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SignInScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text("설정"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("계정"),
            leading: const Icon(Icons.account_circle),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountScreen()),
              );
              print("계정 설정 클릭됨");
            },
          ),
          ListTile(
            title: const Text("알림"),
            leading: const Icon(Icons.notifications),
            onTap: () {
              // 알림 설정 화면으로 이동
              print("알림 설정 클릭됨");
            },
          ),
          ListTile(
            title: const Text("프라이버시"),
            leading: const Icon(Icons.lock),
            onTap: () {
              // 프라이버시 설정 화면으로 이동
              print("프라이버시 설정 클릭됨");
            },
          ),
          ListTile(
            title: const Text("일반"),
            leading: const Icon(Icons.settings),
            onTap: () {
              // 일반 설정 화면으로 이동
              print("일반 설정 클릭됨");
            },
          ),
          const Divider(),
          ListTile(
            title: const Text(
              "로그아웃",
              style: TextStyle(color: Colors.red),
            ),
            leading: const Icon(Icons.logout, color: Colors.red),
            onTap: _signOut,
          ),
        ],
      ),
    );
  }
}
