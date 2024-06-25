import 'package:flutter/material.dart';
import 'package:gitmate/const/colors.dart';
import 'add_post_screen.dart';
import 'dart:io';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final List<Map<String, dynamic>> posts = [];
  final List<Map<String, dynamic>> filteredPosts = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(_filterPosts);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _addPost(String title, String content, File? image) {
    setState(() {
      posts.add({
        "title": title,
        "content": content,
        "image": image,
      });
      _filterPosts();
    });
  }

  void _filterPosts() {
    setState(() {
      filteredPosts.clear();
      if (searchController.text.isEmpty) {
        filteredPosts.addAll(posts);
      } else {
        filteredPosts.addAll(posts.where((post) => post["title"]!
            .toLowerCase()
            .contains(searchController.text.toLowerCase())));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildPostList(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SizedBox(
          width: 60,
          height: 60,
          child: _buildFloatingActionButton(),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      automaticallyImplyLeading: false,
      centerTitle: false,
      leadingWidth: 50.0, // 리딩 위젯의 너비를 줄임
      leading: Padding(
        padding: EdgeInsets.only(left: 8.0), // 원하는 간격으로 설정
        child: Image.asset(
          'assets/images/logo.png',
          color: AppColors.backgroundColor,
        ),
      ),
      title: const Text(
        "커뮤니티",
        style: TextStyle(
          color: AppColors.backgroundColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: "검색",
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
      ),
    );
  }

  ListView _buildPostList() {
    return ListView.builder(
      itemCount: filteredPosts.length,
      itemBuilder: (context, index) {
        final post = filteredPosts[index];
        return _buildPostCard(post);
      },
    );
  }

  Card _buildPostCard(Map<String, dynamic> post) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post["image"] != null) Image.file(post["image"]),
            Text(
              post["title"] ?? "",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(post["content"] ?? ""),
          ],
        ),
      ),
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddPostScreen(addPost: _addPost),
          ),
        );
      },
      backgroundColor: AppColors.primaryColor,
      foregroundColor: AppColors.backgroundColor,
      elevation: 10,
      shape: const CircleBorder(),
      child: const Icon(Icons.edit),
    );
  }
}
