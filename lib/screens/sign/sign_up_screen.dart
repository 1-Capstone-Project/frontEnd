import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gitmate/const/colors.dart';
import 'package:gitmate/screens/navigator.dart';
import 'package:image/image.dart' as img; // 이미지 압축을 위한 패키지 추가

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
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        User? user = userCredential.user;

        if (user != null) {
          String? downloadUrl;
          if (_profileImage != null) {
            // Firebase Storage에 이미지 업로드
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
              setState(() {
                _isLoading = false;
              });
              return;
            }
          }

          // Firestore에 사용자 정보 저장
          try {
            await _firestore.collection('users').doc(user.uid).set({
              'email': email,
              'imageUrl': downloadUrl,
              'nickname': nickname,
              'bio': bio,
            });
          } catch (e) {
            print('Firestore error: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('사용자 정보를 저장하는 중 오류가 발생했습니다.'),
                backgroundColor: AppColors.errorColor,
              ),
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }

          // 회원가입 성공 시 메인 화면으로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigator()),
          );
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
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        print('General error: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('회원가입 중 오류가 발생했습니다.'),
          backgroundColor: AppColors.errorColor,
        ));
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          '로그인',
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
            Navigator.pop(context); // 로그인 화면으로 이동
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: _formKey,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        radius: 50,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : null,
                        child: _profileImage == null
                            ? const Icon(Icons.camera_alt,
                                size: 50, color: Colors.grey)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: '이메일',
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primaryColor),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primaryColor),
                        ),
                      ),
                      cursorColor: AppColors.primaryColor,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이메일을 입력해주세요.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        email = value ?? '';
                      },
                    ),
                    const SizedBox(height: 15.0),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: '비밀번호',
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primaryColor),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primaryColor),
                        ),
                      ),
                      cursorColor: AppColors.primaryColor,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호를 입력해주세요.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        password = value ?? '';
                      },
                    ),
                    const SizedBox(height: 15.0),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: '비밀번호 재확인',
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primaryColor),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primaryColor),
                        ),
                      ),
                      cursorColor: AppColors.primaryColor,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호를 확인해주세요.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        confirmPassword = value ?? '';
                      },
                    ),
                    const SizedBox(height: 15.0),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: '닉네임',
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primaryColor),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primaryColor),
                        ),
                      ),
                      cursorColor: AppColors.primaryColor,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '닉네임을 입력해주세요.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        nickname = value ?? '';
                      },
                    ),
                    const SizedBox(height: 15.0),
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: '자기소개',
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primaryColor),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primaryColor),
                        ),
                      ),
                      cursorColor: AppColors.primaryColor,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '자기소개를 입력해주세요.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        bio = value ?? '';
                      },
                    ),
                    const SizedBox(height: 15.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : signUp, // 로딩 중이면 버튼 비활성화
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('회원가입하기'),
                      ),
                    ),
                  ],
                ),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
