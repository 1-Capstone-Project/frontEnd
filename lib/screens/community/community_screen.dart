import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gitmate/const/colors.dart';
import 'package:gitmate/screens/community/details/add_post_screen.dart';
import 'details/post_detail_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<Map<String, dynamic>?> _fetchUserProfile(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>?;
      }
    } catch (e) {
      print('Failed to fetch user profile: $e');
    }
    return null;
  }

  Future<void> _deletePost(String postId) async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.primaryColor,
          content: Text('게시물이 삭제되었습니다.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete post: $e')),
      );
    }
  }

  Future<void> _toggleLike(String postId, String userId, bool isLiked) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    if (isLiked) {
      await postRef.update({
        'likes': FieldValue.arrayRemove([userId])
      });
    } else {
      await postRef.update({
        'likes': FieldValue.arrayUnion([userId])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "커뮤니티",
          style: TextStyle(
            color: AppColors.backgroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leadingWidth: 50.0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Image.asset(
            'assets/images/logo.png',
            color: AppColors.backgroundColor,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '게시물 제목 검색',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.primaryColor),
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
              cursorColor: AppColors.primaryColor,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('posts').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('아직 게시물이 없습니다.'));
                }

                var filteredDocs = snapshot.data!.docs.where((doc) {
                  final post = doc.data() as Map<String, dynamic>;
                  final title = post['title'] as String? ?? '';
                  return title
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase());
                }).toList();

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final post = doc.data() as Map<String, dynamic>;

                    return FutureBuilder<Map<String, dynamic>?>(
                      future: _fetchUserProfile(post['user_id']),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        }
                        final userProfile = userSnapshot.data;
                        final isCurrentUser =
                            _auth.currentUser!.uid == post['user_id'];
                        final isLiked = post['likes'] != null &&
                            post['likes'].contains(_auth.currentUser!.uid);

                        return Card(
                          color: AppColors.backgroundColor,
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PostDetailScreen(postId: doc.id),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: userProfile != null
                                            ? NetworkImage(
                                                userProfile['imageUrl'] ?? '')
                                            : null,
                                        child: userProfile == null
                                            ? const Icon(Icons.person)
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              userProfile?['nickname'] ??
                                                  'Unknown',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              post['title'] ?? 'No title',
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        onSelected: (value) {
                                          if (value == 'delete') {
                                            _deletePost(doc.id);
                                          } else if (value == 'edit') {
                                            // TODO: Implement edit functionality
                                          } else if (value == 'report') {
                                            // TODO: Implement report functionality
                                          }
                                        },
                                        itemBuilder: (BuildContext context) {
                                          if (isCurrentUser) {
                                            return {'수정', '삭제'}
                                                .map((String choice) {
                                              return PopupMenuItem<String>(
                                                value: choice == '수정'
                                                    ? 'edit'
                                                    : 'delete',
                                                child: Text(choice),
                                              );
                                            }).toList();
                                          } else {
                                            return {'신고'}.map((String choice) {
                                              return PopupMenuItem<String>(
                                                value: 'report',
                                                child: Text(choice),
                                              );
                                            }).toList();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(post['description'] ?? 'No description'),
                                  const SizedBox(height: 12),
                                  if (post['image_urls'] != null &&
                                      post['image_urls'].isNotEmpty)
                                    SizedBox(
                                      height: 120,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: post['image_urls'].length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(right: 8),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                post['image_urls'][index],
                                                fit: BoxFit.cover,
                                                width: 120,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          isLiked
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isLiked
                                              ? Colors.red
                                              : Colors.grey,
                                        ),
                                        onPressed: () {
                                          _toggleLike(doc.id,
                                              _auth.currentUser!.uid, isLiked);
                                        },
                                      ),
                                      Text('${post['likes']?.length ?? 0}'),
                                      const Spacer(),
                                      FutureBuilder<QuerySnapshot>(
                                        future: FirebaseFirestore.instance
                                            .collection('posts')
                                            .doc(doc.id)
                                            .collection('comments')
                                            .orderBy('timestamp',
                                                descending: true)
                                            .limit(1)
                                            .get(),
                                        builder: (context, commentSnapshot) {
                                          if (commentSnapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const SizedBox.shrink();
                                          }
                                          final commentCount = commentSnapshot
                                                  .data?.docs.length ??
                                              0;
                                          return Row(
                                            children: [
                                              const Icon(Icons.comment,
                                                  color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Text('$commentCount'),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPostScreen()),
          );
        },
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.backgroundColor,
        child: const Icon(Icons.edit),
      ),
    );
  }
}
