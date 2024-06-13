import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final List<Map<String, String>> posts = [];
  final List<Map<String, String>> filteredPosts = [];
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

  void _addPost() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final titleController = TextEditingController();
        final contentController = TextEditingController();
        final imageController = TextEditingController();

        return AlertDialog(
          title: Text("새 게시물 추가"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(hintText: "제목"),
                ),
                TextField(
                  controller: contentController,
                  decoration: InputDecoration(hintText: "내용"),
                ),
                TextField(
                  controller: imageController,
                  decoration: InputDecoration(hintText: "이미지 URL"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  posts.add({
                    "title": titleController.text,
                    "content": contentController.text,
                    "image": imageController.text,
                  });
                  _filterPosts();
                });
                Navigator.of(context).pop();
              },
              child: Text("추가"),
            ),
          ],
        );
      },
    );
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text("커뮤니티"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "검색",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: filteredPosts.length,
        itemBuilder: (context, index) {
          final post = filteredPosts[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post["image"] != null && post["image"]!.isNotEmpty)
                    Image.network(post["image"]!),
                  Text(
                    post["title"] ?? "",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Text(post["content"] ?? ""),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPost,
        child: Icon(Icons.add),
      ),
    );
  }
}
