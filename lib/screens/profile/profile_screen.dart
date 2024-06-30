import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gitmate/const/colors.dart';
import 'details/setting_screen.dart';
import 'details/edit_profile_screen.dart';
import 'package:intl/intl.dart';

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
            _imageFile = null;
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: false,
          backgroundColor: AppColors.primaryColor,
          title: const Text(
            "프로필",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          leadingWidth: 50.0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Image.asset(
              'assets/images/logo.png',
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingScreen()),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildProfileHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildCommunityTab(),
                  _buildPostsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  radius: 50,
                  backgroundImage: _profileImageUrl != null
                      ? NetworkImage(_profileImageUrl!)
                      : null,
                  child: _profileImageUrl == null
                      ? const Icon(Icons.person, size: 50, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nickname ?? '닉네임',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _bio ?? '자기소개를 입력해주세요.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
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
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('프로필 편집', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: const TabBar(
        indicatorColor: AppColors.primaryColor,
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: Colors.grey,
        tabs: [
          Tab(text: "커뮤니티"),
          Tab(text: "게시물"),
        ],
      ),
    );
  }

  Widget _buildCommunityTab() {
    return const Center(
      child: Text("커뮤니티 기능이 준비 중입니다."),
    );
  }

  Widget _buildPostsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .where('user_id', isEqualTo: _user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('게시물이 없습니다.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final event = doc.data() as Map<String, dynamic>;

            return Card(
              color: AppColors.backgroundColor,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (event['image_urls'] != null &&
                      event['image_urls'].isNotEmpty)
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      child: CarouselSlider.builder(
                        itemCount: event['image_urls'].length,
                        itemBuilder: (context, index, realIndex) {
                          return Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Image.network(
                                event['image_urls'][index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${index + 1}/${event['image_urls'].length}',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                        options: CarouselOptions(
                          height: 200,
                          viewportFraction: 1,
                          enlargeCenterPage: false,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                event['title'],
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  // 수정 기능 구현 예정
                                } else if (value == 'delete') {
                                  _deleteEvent(doc.id);
                                } else if (value == 'report') {
                                  // 신고 기능 구현 예정
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                return [
                                  PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Text('수정'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Text('삭제'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'report',
                                    child: Text('신고'),
                                  ),
                                ];
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          event['description'],
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${DateFormat('yyyy.MM.dd').format(DateTime.parse(event['schedule_date']))} ${event['start_time'] ?? ''} - ${event['end_time'] ?? ''}",
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteEvent(String eventId) async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('일정이 삭제되었습니다.')),
      );
    } catch (e) {
      print('Failed to delete event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('일정 삭제에 실패했습니다.')),
      );
    }
  }
}
