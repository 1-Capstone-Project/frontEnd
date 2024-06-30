// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:gitmate/const/colors.dart';
// import 'package:gitmate/screens/navigator.dart';
// import 'package:gitmate/screens/sign/sign_up_screen.dart'; // 회원가입 화면 import

// class SignInScreen extends StatefulWidget {
//   const SignInScreen({super.key});

//   @override
//   State<SignInScreen> createState() => _SignInScreenState();
// }

// class _SignInScreenState extends State<SignInScreen> {
//   final _formKey = GlobalKey<FormState>();
//   String email = '';
//   String password = '';
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   Future<void> signIn() async {
//     if (_formKey.currentState?.validate() ?? false) {
//       _formKey.currentState?.save();
//       try {
//         UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//           email: email,
//           password: password,
//         );
//         // 로그인 성공 시 팝업창을 띄운 후 메인 화면으로 이동
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               backgroundColor: AppColors.backgroundColor,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10.0), // 테두리 둥글게 조절
//               ),
//               title: const Text(
//                 '[GitMate]',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: AppColors.primaryColor,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               content: const Text(
//                 '로그인 성공!',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop(); // 팝업 닫기
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const MainNavigator()),
//                     );
//                   },
//                   child: const Text(
//                     '시작하기',
//                     style: TextStyle(
//                       color: AppColors.primaryColor,
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       } on FirebaseAuthException catch (e) {
//         String message = '';
//         if (e.code == 'user-not-found') {
//           message = '해당 이메일에 관한 사용자를 찾을 수 없습니다.';
//         } else if (e.code == 'wrong-password') {
//           message = '비밀번호가 잘못되었습니다.';
//         } else {
//           message = '계정을 다시 확인해주세요.';
//         }
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text(message),
//           backgroundColor: AppColors.errorColor,
//         ));
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Image.asset(
//                   'assets/images/logo.png',
//                   color: AppColors.primaryColor,
//                   width: 80,
//                 ),
//                 const Text(
//                   'GitMate',
//                   style: TextStyle(
//                     color: AppColors.primaryColor,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 24,
//                   ),
//                 ),
//                 const SizedBox(height: 20.0),
//                 TextFormField(
//                   decoration: const InputDecoration(
//                     hintText: '이메일',
//                     focusedBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: AppColors.primaryColor),
//                     ),
//                     enabledBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: AppColors.primaryColor),
//                     ),
//                   ),
//                   cursorColor: AppColors.primaryColor,
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return '이메일을 확인해주세요.';
//                     }
//                     return null;
//                   },
//                   onSaved: (value) {
//                     email = value ?? '';
//                   },
//                 ),
//                 const SizedBox(height: 15.0),
//                 TextFormField(
//                   decoration: const InputDecoration(
//                     hintText: '비밀번호',
//                     focusedBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: AppColors.primaryColor),
//                     ),
//                     enabledBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: AppColors.primaryColor),
//                     ),
//                   ),
//                   cursorColor: AppColors.primaryColor,
//                   obscureText: true,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return '비밀번호를 확인해주세요.';
//                     }
//                     return null;
//                   },
//                   onSaved: (value) {
//                     password = value ?? '';
//                   },
//                 ),
//                 const SizedBox(height: 15.0),
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width,
//                   child: ElevatedButton(
//                     onPressed: signIn,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primaryColor,
//                       foregroundColor: Colors.white,
//                     ),
//                     child: const Text('로그인'),
//                   ),
//                 ),
//                 const SizedBox(height: 15.0),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const SignUpScreen(),
//                       ),
//                     );
//                   },
//                   child: const Text(
//                     '계정이 없으신가요? 회원가입',
//                     style: TextStyle(
//                       color: AppColors.primaryColor,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gitmate/const/colors.dart';
import 'package:gitmate/screens/navigator.dart';
import 'package:gitmate/screens/sign/sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              title: const Text(
                '[GitMate]',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                '로그인 성공!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MainNavigator()),
                    );
                  },
                  child: const Text(
                    '시작하기',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      } on FirebaseAuthException catch (e) {
        String message = '';
        if (e.code == 'user-not-found') {
          message = '해당 이메일에 관한 사용자를 찾을 수 없습니다.';
        } else if (e.code == 'wrong-password') {
          message = '비밀번호가 잘못되었습니다.';
        } else {
          message = '계정을 다시 확인해주세요.';
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor: AppColors.errorColor,
        ));
      }
    }
  }

  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    required Function(String?) onSaved,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: AppColors.primaryColor),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        obscureText: obscureText,
        validator: validator,
        onSaved: onSaved,
        cursorColor: AppColors.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      color: AppColors.primaryColor,
                      width: 80,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'GitMate',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildTextField(
                      hintText: '이메일',
                      icon: Icons.email,
                      onSaved: (value) => email = value ?? '',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이메일을 확인해주세요.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      hintText: '비밀번호',
                      icon: Icons.lock,
                      obscureText: true,
                      onSaved: (value) => password = value ?? '',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호를 확인해주세요.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '로그인',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        '계정이 없으신가요? 회원가입',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
