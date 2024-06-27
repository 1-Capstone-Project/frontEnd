import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gitmate/const/colors.dart';
import 'package:gitmate/screens/sign/sign_in_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  User? _user;
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  Future<void> _deleteAccount() async {
    if (_user != null) {
      try {
        // Firestore 프로필 문서 삭제
        await _firestore.collection('users').doc(_user!.uid).delete();

        // Firebase Storage의 프로필 사진 삭제
        String fileName = 'profile_images/${_user!.uid}.jpg';
        await _storage.ref(fileName).delete();

        // Firebase Auth 계정 삭제
        await _user!.delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.errorColor,
            content: Text('계정이 삭제되었습니다.'),
          ),
        );

        // 로그인 화면으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          _showReauthenticationDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('계정 삭제 중 오류가 발생했습니다. 다시 시도해주세요.'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('계정 삭제 중 오류가 발생했습니다. 다시 시도해주세요.'),
          ),
        );
      }
    }
  }

  Future<void> _reauthenticateAndDelete() async {
    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: _user!.email!,
        password: _passwordController.text,
      );
      await _user!.reauthenticateWithCredential(credential);
      // Reauthenticate and then delete account
      await _deleteAccount();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.errorColor,
          content: Text('재인증에 실패했습니다: ${e.message}'),
        ),
      );
    }
  }

  void _showReauthenticationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // 테두리 둥글게 조절
          ),
          title: const Text(
            '재인증 필요',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('계정을 삭제하려면 비밀번호를 입력해주세요.'),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryColor),
                  ),
                  hintText: '비밀번호',
                ),
                cursorColor: AppColors.primaryColor,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '취소',
                style: TextStyle(
                  color: AppColors.errorColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _reauthenticateAndDelete();
              },
              child: const Text(
                '확인',
                style: TextStyle(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // 테두리 둥글게 조절
          ),
          title: const Text(
            '[계정 삭제]',
            style: TextStyle(
              color: AppColors.errorColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text('정말로 이 계정을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showReauthenticationDialog();
              },
              child: const Text(
                '삭제',
                style: TextStyle(
                  color: AppColors.errorColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '취소',
                style: TextStyle(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text("계정"),
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text("이메일"),
            subtitle: Text(
              _user?.email ?? '로그인 정보가 없습니다.',
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: ElevatedButton(
                onPressed: _confirmDeleteAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('계정 삭제'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
