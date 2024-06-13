import 'package:flutter/material.dart';
import 'package:gitmate/screens/sign/sigin_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text("설정"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text("계정"),
            leading: Icon(Icons.account_circle),
            onTap: () {
              // 계정 설정 화면으로 이동
              print("계정 설정 클릭됨");
            },
          ),
          ListTile(
            title: Text("알림"),
            leading: Icon(Icons.notifications),
            onTap: () {
              // 알림 설정 화면으로 이동
              print("알림 설정 클릭됨");
            },
          ),
          ListTile(
            title: Text("프라이버시"),
            leading: Icon(Icons.lock),
            onTap: () {
              // 프라이버시 설정 화면으로 이동
              print("프라이버시 설정 클릭됨");
            },
          ),
          ListTile(
            title: Text("일반"),
            leading: Icon(Icons.settings),
            onTap: () {
              // 일반 설정 화면으로 이동
              print("일반 설정 클릭됨");
            },
          ),
          Divider(),
          ListTile(
            title: Text(
              "로그아웃",
              style: TextStyle(color: Colors.red),
            ),
            leading: Icon(Icons.logout, color: Colors.red),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      SiginScreen(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
