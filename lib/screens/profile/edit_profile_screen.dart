import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gitmate/const/colors.dart';
import 'package:image/image.dart' as img; // 이미지 압축을 위한 패키지 추가

class EditProfileScreen extends StatefulWidget {
  final String? currentImageUrl;
  final String? currentNickname;
  final String? currentBio;

  const EditProfileScreen({
    super.key,
    this.currentImageUrl,
    this.currentNickname,
    this.currentBio,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  User? _user;
  File? _newProfileImage;
  final _formKey = GlobalKey<FormState>();
  late String _nickname;
  late String _bio;
  bool _isLoading = false;
  DateTime? _lastNicknameChange;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _nickname = widget.currentNickname ?? '';
    _bio = widget.currentBio ?? '';
    _loadLastNicknameChangeDate();
  }

  Future<void> _loadLastNicknameChangeDate() async {
    if (_user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_user!.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _lastNicknameChange = data.containsKey('lastNicknameChange')
              ? (data['lastNicknameChange'] as Timestamp).toDate()
              : null;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newProfileImage = File(pickedFile.path);
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

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final now = DateTime.now();
      if (_lastNicknameChange != null &&
          now.difference(_lastNicknameChange!).inDays < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('닉네임은 하루에 한 번만 변경할 수 있습니다.'),
            backgroundColor: AppColors.errorColor,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        String? downloadUrl = widget.currentImageUrl;
        if (_newProfileImage != null) {
          // Firebase Storage에 이미지 업로드
          String fileName = 'profile_images/${_user!.uid}.jpg';
          try {
            File compressedImage = await _compressImage(_newProfileImage!);
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

        // Firestore에 사용자 정보 업데이트
        try {
          await _firestore.collection('users').doc(_user!.uid).update({
            'imageUrl': downloadUrl,
            'nickname': _nickname,
            'bio': _bio,
            'lastNicknameChange': now,
          });
        } catch (e) {
          print('Firestore error: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('사용자 정보를 업데이트하는 중 오류가 발생했습니다.'),
              backgroundColor: AppColors.errorColor,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        setState(() {
          _isLoading = false;
        });

        // 업데이트 완료 후 이전 화면으로 복귀
        Navigator.pop(context, true);
      } catch (e) {
        print('General error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필 업데이트 중 오류가 발생했습니다.'),
            backgroundColor: AppColors.errorColor,
          ),
        );
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
          '프로필 편집',
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
                        backgroundColor: AppColors.primaryColor,
                        radius: 50,
                        backgroundImage: _newProfileImage != null
                            ? FileImage(_newProfileImage!)
                            : (widget.currentImageUrl != null
                                ? NetworkImage(widget.currentImageUrl!)
                                : const AssetImage(
                                    'assets/images/logo.png')) as ImageProvider,
                        child: _newProfileImage == null &&
                                widget.currentImageUrl == null
                            ? const Icon(Icons.camera_alt,
                                size: 50, color: Colors.grey)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    const Row(
                      children: [
                        Text('닉네임'),
                      ],
                    ),
                    TextFormField(
                      initialValue: _nickname,
                      decoration: const InputDecoration(
                        hintText: '닉네임',
                        focusedBorder: UnderlineInputBorder(
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
                        _nickname = value ?? '';
                      },
                    ),
                    const SizedBox(height: 30.0),
                    const Row(
                      children: [
                        Text('자기소개'),
                      ],
                    ),
                    TextFormField(
                      initialValue: _bio,
                      decoration: const InputDecoration(
                        hintText: '자기소개',
                        focusedBorder: UnderlineInputBorder(
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
                        _bio = value ?? '';
                      },
                    ),
                    const SizedBox(height: 15.0),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('프로필 저장'),
                      ),
                    ),
                  ],
                ),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
