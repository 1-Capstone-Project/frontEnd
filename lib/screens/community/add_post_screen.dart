import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPostScreen extends StatefulWidget {
  final Function(String title, String content, File? image) addPost;

  const AddPostScreen({super.key, required this.addPost});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Image picker error: $e");
    }
  }

  Future<void> _uploadPost() async {
    final title = titleController.text;
    final content = contentController.text;

    if (title.isEmpty || content.isEmpty || _selectedImage == null) {
      print("Title, content and image must not be empty");
      return;
    }

    // S3에 이미지 업로드 및 URL 받아오기
    final imgURL = await _uploadImageToS3(_selectedImage!);

    if (imgURL != null) {
      // 서버에 게시물 정보 전송
      final response = await http.post(
        Uri.parse('http://gitmate-backend.com/posts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'description': content,
          'img_url': imgURL,
        }),
      );

      if (response.statusCode == 200) {
        print("Post uploaded successfully");
        Navigator.pop(context);
      } else {
        print("Failed to upload post");
      }
    }
  }

  Future<String?> _uploadImageToS3(File image) async {
    // 이미지 업로드 로직 구현 (S3 SDK 또는 HTTP 요청)
    // 업로드 성공 시 이미지 URL 반환
    // 여기서는 예시로 null을 반환합니다.
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          "새 게시물 추가",
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[300],
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.cover)
                    : Icon(Icons.add_a_photo, color: Colors.grey[800]),
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: titleController,
              decoration: InputDecoration(hintText: "제목"),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: contentController,
              decoration: InputDecoration(hintText: "내용"),
              maxLines: 3,
            ),
            SizedBox(height: 8.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _uploadPost,
                child: Text("게시물 올리기"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
