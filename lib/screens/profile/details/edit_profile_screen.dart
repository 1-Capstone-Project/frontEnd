import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gitmate/const/colors.dart';
import 'package:image/image.dart' as img;

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

        await _firestore.collection('users').doc(_user!.uid).update({
          'imageUrl': downloadUrl,
          'nickname': _nickname,
          'bio': _bio,
          'lastNicknameChange': now,
        });

        setState(() {
          _isLoading = false;
        });

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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          '프로필 편집',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _newProfileImage != null
                              ? FileImage(_newProfileImage!)
                              : (widget.currentImageUrl != null
                                  ? NetworkImage(widget.currentImageUrl!)
                                  : null) as ImageProvider?,
                          child: _newProfileImage == null &&
                                  widget.currentImageUrl == null
                              ? const Icon(Icons.person,
                                  size: 60, color: Colors.grey)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildTextField(
                  label: '닉네임',
                  initialValue: _nickname,
                  onSaved: (value) => _nickname = value ?? '',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: '자기소개',
                  initialValue: _bio,
                  onSaved: (value) => _bio = value ?? '',
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('프로필 저장', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required Function(String?) onSaved,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
            ),
          ),
          cursorColor: AppColors.primaryColor,
          maxLines: maxLines,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$label을(를) 입력해주세요.';
            }
            return null;
          },
          onSaved: onSaved,
        ),
      ],
    );
  }
}
