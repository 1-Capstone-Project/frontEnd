import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class EditEventScreen extends StatefulWidget {
  final Map<String, dynamic> event;
  final Function onEditEvent;

  const EditEventScreen(
      {super.key, required this.event, required this.onEditEvent});

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String content = '';
  String startTime = '';
  String endTime = '';
  List<String> imageUrls = [];
  List<File> newImages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    title = widget.event['title'];
    content = widget.event['content'];
    startTime = widget.event['start_time'];
    endTime = widget.event['end_time'];
    imageUrls = List<String>.from(widget.event['image_urls']);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        newImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<List<String>> _uploadImages(List<File> images) async {
    List<String> newImageUrls = [];
    for (File image in images) {
      String fileName =
          'event_images/${FirebaseAuth.instance.currentUser!.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      UploadTask task = FirebaseStorage.instance.ref(fileName).putFile(image);
      TaskSnapshot snapshot = await task;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      newImageUrls.add(downloadUrl);
    }
    return newImageUrls;
  }

  Future<void> _editEvent() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      setState(() {
        _isLoading = true;
      });
      try {
        List<String> newImageUrls = await _uploadImages(newImages);
        imageUrls.addAll(newImageUrls);

        await FirebaseFirestore.instance
            .collection('events')
            .doc(widget.event['id'])
            .update({
          'title': title,
          'description': content,
          'start_time': startTime,
          'end_time': endTime,
          'image_urls': imageUrls,
        });

        widget.onEditEvent(widget.event['id'], {
          'title': title,
          'description': content,
          'start_time': startTime,
          'end_time': endTime,
          'image_urls': imageUrls,
        });

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to edit event: $e')),
        );
      } finally {
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
        title: const Text('Edit Event'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: title,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        title = value ?? '';
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      initialValue: content,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        content = value ?? '';
                      },
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Pick Images'),
                    ),
                    const SizedBox(height: 16.0),
                    imageUrls.isNotEmpty
                        ? Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: imageUrls.map((imageUrl) {
                              return Image.network(
                                imageUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              );
                            }).toList(),
                          )
                        : const Text('No images selected'),
                    const SizedBox(height: 16.0),
                    newImages.isNotEmpty
                        ? Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: newImages.map((image) {
                              return Image.file(
                                image,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              );
                            }).toList(),
                          )
                        : const Text('No new images selected'),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _editEvent,
                      child: const Text('Edit Event'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
