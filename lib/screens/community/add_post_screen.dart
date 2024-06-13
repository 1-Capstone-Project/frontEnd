import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
                onPressed: () {
                  final title = titleController.text;
                  final content = contentController.text;
                  widget.addPost(title, content, _selectedImage);
                  Navigator.pop(context);
                },
                child: Text("게시물 올리기"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
