import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gitmate/const/colors.dart';
import 'package:gitmate/screens/navigator.dart';
import 'package:image/image.dart' as img;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String confirmPassword = '';
  String nickname = '';
  String bio = '';
  File? _profileImage;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  bool _isLoading = false;
  bool _isEmailVerified = false;
  bool _isEmailSent = false;
  String _verificationMessage = '';

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<File> _compressImage(File file) async {
    final img.Image? image = img.decodeImage(await file.readAsBytes());
    if (image == null) {
      throw Exception('Failed to decode image.');
    }
    final img.Image compressedImage = img.copyResize(image, width: 800);
    final File compressedFile = File(file.path)
      ..writeAsBytesSync(img.encodeJpg(compressedImage, quality: 85));
    return compressedFile;
  }

  Future<void> _sendEmailVerification() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      setState(() {
        _isLoading = true;
      });
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        User? user = userCredential.user;

        if (user != null) {
          await user.sendEmailVerification();
          setState(() {
            _isEmailSent = true;
            _verificationMessage = '인증 이메일을 보냈습니다. 이메일을 확인해주세요.';
          });
        }
      } on FirebaseAuthException catch (e) {
        String message = '';
        if (e.code == 'weak-password') {
          message = '비밀번호가 약합니다.';
        } else if (e.code == 'email-already-in-use') {
          message = '계정이 이미 존재합니다.';
        } else {
          message = '계정을 다시 확인해주세요.';
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor: AppColors.errorColor,
        ));
      } catch (e) {
        print('Failed to send email verification: $e');
        setState(() {
          _verificationMessage = '이메일 인증을 보내는 중 오류가 발생했습니다.';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkEmailVerified() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      setState(() {
        _isEmailVerified = user.emailVerified;
        _verificationMessage =
            _isEmailVerified ? '인증이 완료되었습니다.' : '인증에 실패했습니다. 이메일을 다시 확인해주세요.';
      });
    }
  }

  Future<void> signUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('비밀번호를 재확인해주세요.'),
            backgroundColor: AppColors.errorColor,
          ),
        );
        return;
      }
      setState(() {
        _isLoading = true;
      });
      try {
        User? user = _auth.currentUser;

        if (user != null && _isEmailVerified) {
          await _saveUserData(user);
        } else {
          throw Exception('User is not verified');
        }
      } catch (e) {
        print('General error: $e');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('회원가입 중 오류가 발생했습니다.'),
          backgroundColor: AppColors.errorColor,
        ));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveUserData(User user) async {
    String? downloadUrl;
    if (_profileImage != null) {
      String fileName = 'profile_images/${user.uid}.jpg';
      try {
        File compressedImage = await _compressImage(_profileImage!);
        TaskSnapshot snapshot =
            await _storage.ref(fileName).putFile(compressedImage);
        downloadUrl = await snapshot.ref.getDownloadURL();
      } catch (e) {
        print('Image upload error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이미지 업로드 중 오류가 발생했습니다.'),
            backgroundColor: AppColors.errorColor,
          ),
        );
        return;
      }
    }

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'email': email,
        'imageUrl': downloadUrl,
        'nickname': nickname,
        'bio': bio,
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigator()),
      );
    } catch (e) {
      print('Firestore error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('사용자 정보를 저장하는 중 오류가 발생했습니다.'),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    required Function(String?) onSaved,
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$hintText를 입력해주세요.';
          }
          return null;
        },
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildButton(
      {required String text, required VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: const Text(
          '회원가입',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.primaryColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        radius: 60,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : null,
                        child: _profileImage == null
                            ? Icon(Icons.camera_alt,
                                size: 40, color: Colors.grey[400])
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      hintText: '이메일',
                      icon: Icons.email,
                      onSaved: (value) => email = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildButton(
                            text: _isEmailSent ? '인증 이메일 발송됨' : '인증 이메일 보내기',
                            onPressed:
                                _isEmailSent ? null : _sendEmailVerification,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildButton(
                            text: '인증 확인',
                            onPressed:
                                _isEmailSent ? _checkEmailVerified : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      hintText: '비밀번호',
                      icon: Icons.lock,
                      obscureText: true,
                      onSaved: (value) => password = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      hintText: '비밀번호 재확인',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      onSaved: (value) => confirmPassword = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      hintText: '닉네임',
                      icon: Icons.person,
                      onSaved: (value) => nickname = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      hintText: '자기소개',
                      icon: Icons.description,
                      onSaved: (value) => bio = value ?? '',
                    ),
                    const SizedBox(height: 24),
                    _buildButton(
                      text: '회원가입하기',
                      onPressed:
                          _isLoading || !_isEmailVerified ? null : signUp,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _verificationMessage,
                      style: TextStyle(
                        color: _isEmailVerified
                            ? Colors.green
                            : AppColors.errorColor,
                      ),
                      textAlign: TextAlign.center,
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
