import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gitmate/const/colors.dart';
import 'setting_screen.dart';
import 'edit_profile_screen.dart'; // 편집 화면 import

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  User? _user;
  String? _profileImageUrl;
  String? _nickname;
  String? _bio;
  String? _errorMessage;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (_user != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(_user!.uid).get();
        if (userDoc.exists) {
          if (mounted) {
            setState(() {
              _profileImageUrl = userDoc['imageUrl'] as String?;
              _nickname = userDoc['nickname'] as String?;
              _bio = userDoc['bio'] as String?;
            });
          }
        } else {
          setState(() {
            _errorMessage = '사용자 문서가 존재하지 않습니다.';
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = '프로필 이미지를 불러오는데 실패했습니다. 네트워크 연결을 확인해주세요. 오류: $e';
          });
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (mounted) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
      await _uploadProfileImage();
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_user != null && _imageFile != null) {
      try {
        String fileName = 'profile_images/${_user!.uid}.jpg';
        TaskSnapshot snapshot =
            await _storage.ref(fileName).putFile(_imageFile!);
        String downloadUrl = await snapshot.ref.getDownloadURL();

        await _firestore.collection('users').doc(_user!.uid).update({
          'imageUrl': downloadUrl,
        });

        if (mounted) {
          setState(() {
            _profileImageUrl = downloadUrl;
            _imageFile = null; // 이미지 파일 초기화
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = '프로필 이미지를 업로드하는데 실패했습니다. 다시 시도해주세요. 오류: $e';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "프로필",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.backgroundColor,
          ),
        ),
        leadingWidth: 50.0, // 리딩 위젯의 너비를 줄임
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0), // 원하는 간격으로 설정
          child: Image.asset(
            'assets/images/logo.png',
            color: AppColors.backgroundColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: AppColors.backgroundColor,
            ),
            onPressed: () {
              // SettingScreen으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
          child: Column(
            children: [
              Row(
                children: [
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    )
                  else
                    GestureDetector(
                      child: _profileImageUrl != null
                          ? CircleAvatar(
                              backgroundColor: Colors.grey,
                              radius: 60,
                              backgroundImage: NetworkImage(_profileImageUrl!),
                            )
                          : const CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey,
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (_nickname != null)
                    Text(
                      _nickname!,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (_bio != null)
                    Text(
                      _bio!,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(
                          currentImageUrl: _profileImageUrl,
                          currentNickname: _nickname,
                          currentBio: _bio,
                        ),
                      ),
                    ).then((value) {
                      if (value == true) {
                        _loadUserProfile();
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.backgroundColor,
                  ),
                  child: const Text('프로필 편집'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
