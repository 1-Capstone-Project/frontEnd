import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gitmate/const/colors.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEventScreen extends StatefulWidget {
  final Function(DateTime, String, String, String, String, List<String>)
      onAddEvent;

  const AddEventScreen({super.key, required this.onAddEvent});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _allDay = false;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<File> _selectedImages = [];
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> _pickImage() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> _submitEvent() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('제목과 내용을 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        final user = _auth.currentUser;
        for (var image in _selectedImages) {
          final fileName =
              'event_images/${user!.uid}_${DateTime.now().millisecondsSinceEpoch}_${_selectedImages.indexOf(image)}.jpg';
          final snapshot = await _storage.ref(fileName).putFile(image);
          final imageUrl = await snapshot.ref.getDownloadURL();
          imageUrls.add(imageUrl);
        }
      }

      final startTimeStr = _allDay ? null : _startTime?.format(context);
      final endTimeStr = _allDay ? null : _endTime?.format(context);

      widget.onAddEvent(
        _selectedDate,
        _titleController.text,
        _contentController.text,
        startTimeStr ?? 'All Day',
        endTimeStr ?? 'All Day',
        imageUrls,
      );

      await FirebaseFirestore.instance.collection('events').add({
        'user_id': _auth.currentUser!.uid,
        'schedule_date': _selectedDate.toIso8601String(),
        'title': _titleController.text,
        'description': _contentController.text,
        'start_time': startTimeStr,
        'end_time': endTimeStr,
        'image_urls': imageUrls,
      });

      Navigator.pop(context);
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add event: $e'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        centerTitle: false,
        title: const Text(
          '일정 추가',
          style: TextStyle(
            color: AppColors.backgroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.backgroundColor,
          ),
          onPressed: () {
            Navigator.pop(context); // 로그인 화면으로 이동
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  color: Colors.grey[200],
                  height: 200,
                  child: Center(
                    child: _selectedImages.isEmpty
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "이미지 선택",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 100, child: Divider()),
                              Text(
                                "절대 개인정보가\n포함된 이미지를 넣지마세요",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.errorColor,
                                  fontSize: 12,
                                ),
                              )
                            ],
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedImages.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Image.file(_selectedImages[index]),
                              );
                            },
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: "제목",
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryColor),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryColor),
                  ),
                ),
                cursorColor: AppColors.primaryColor,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: "내용",
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryColor),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryColor),
                  ),
                ),
                cursorColor: AppColors.primaryColor,
              ),
              const SizedBox(height: 20),
              TableCalendar(
                calendarStyle: const CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: AppColors.primaryColor,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonTextStyle: TextStyle(
                    color: AppColors.primaryColor,
                  ),
                  leftChevronIcon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.grey,
                  ),
                  rightChevronIcon: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                  ),
                ),
                firstDay: DateTime.utc(2000, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: _selectedDate,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDate = selectedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
              ),
              const SizedBox(height: 20),
              if (!_allDay) ...[
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text(_startTime == null
                            ? '시작 시간 선택'
                            : '시작 시간: ${_startTime!.format(context)}'),
                        onTap: () async {
                          final time = await showTimePicker(
                            helpText: "종료 시간",
                            cancelText: "취소",
                            confirmText: "적용",
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() {
                              _startTime = time;
                            });
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text(_endTime == null
                            ? '종료 시간 선택'
                            : '종료 시간: ${_endTime!.format(context)}'),
                        onTap: () async {
                          final time = await showTimePicker(
                            helpText: "종료 시간",
                            cancelText: "취소",
                            confirmText: "적용",
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() {
                              _endTime = time;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
              Row(
                children: [
                  Checkbox(
                    value: _allDay,
                    onChanged: (value) {
                      setState(() {
                        _allDay = value!;
                        if (_allDay) {
                          _startTime = null;
                          _endTime = null;
                        }
                      });
                    },
                  ),
                  const Text("하루종일")
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.backgroundColor,
                  ),
                  child: const Text("일정 만들기"),
                ),
              ),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
