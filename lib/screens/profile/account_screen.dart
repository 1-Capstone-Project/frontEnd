import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text("계정"),
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text("이메일"),
            subtitle: Text(
              _user?.email ?? '로그인 정보가 없습니다.',
            ),
          ),
        ],
      ),
    );
  }
}
