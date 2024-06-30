import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gitmate/const/colors.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({required this.postId, super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _commentController = TextEditingController();

  Future<void> _addComment(String postId, String comment) async {
    if (comment.isNotEmpty) {
      final user = _auth.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .add({
          'user_id': user.uid,
          'comment': comment,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _commentController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('게시물 상세'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.backgroundColor,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('게시물을 찾을 수 없습니다.'));
          }

          final post = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post['image_urls'] != null && post['image_urls'].isNotEmpty)
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 250.0,
                      enableInfiniteScroll: false,
                      enlargeCenterPage: true,
                      viewportFraction: 0.9,
                    ),
                    items: List<String>.from(post['image_urls']).map((url) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15.0),
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['title'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        post['description'],
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24.0),
                      const Text(
                        '댓글',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('posts')
                            .doc(widget.postId)
                            .collection('comments')
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Text('아직 댓글이 없습니다.');
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.docs.length,
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemBuilder: (context, index) {
                              final commentDoc = snapshot.data!.docs[index];
                              final comment =
                                  commentDoc.data() as Map<String, dynamic>;
                              return FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(comment['user_id'])
                                    .get(),
                                builder: (context, userSnapshot) {
                                  if (userSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const SizedBox.shrink();
                                  }
                                  final userProfile = userSnapshot.data?.data()
                                      as Map<String, dynamic>?;
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: userProfile != null &&
                                              userProfile['imageUrl'] != null
                                          ? NetworkImage(
                                              userProfile['imageUrl'])
                                          : null,
                                      child: userProfile == null ||
                                              userProfile['imageUrl'] == null
                                          ? const Icon(Icons.person)
                                          : null,
                                    ),
                                    title: Text(
                                      userProfile?['nickname'] ?? 'Unknown',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(comment['comment']),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 8,
          right: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: '댓글을 입력하세요...',
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              color: AppColors.primaryColor,
              onPressed: () {
                _addComment(widget.postId, _commentController.text);
              },
            ),
          ],
        ),
      ),
    );
  }
}
