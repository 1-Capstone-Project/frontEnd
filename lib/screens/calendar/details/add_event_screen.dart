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
        SnackBar(content: Text('Failed to add event: $e')),
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: const Text('일정 추가', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(),
              const SizedBox(height: 20),
              _buildTextField(_titleController, "제목"),
              const SizedBox(height: 20),
              _buildTextField(_contentController, "내용", maxLines: 3),
              const SizedBox(height: 20),
              _buildCalendar(),
              const SizedBox(height: 20),
              if (!_allDay) _buildTimeSelectors(),
              _buildAllDayCheckbox(),
              const SizedBox(height: 20),
              _buildSubmitButton(),
              if (_isLoading)
                const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryColor)),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _selectedImages.isEmpty
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("이미지 선택", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text(
                    "절대 개인정보가 포함된 이미지를 넣지마세요",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.errorColor, fontSize: 12),
                  )
                ],
              )
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(_selectedImages[index],
                          fit: BoxFit.cover, width: 150),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryColor),
        ),
      ),
      cursorColor: AppColors.primaryColor,
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar(
        calendarStyle: const CalendarStyle(
          selectedDecoration: BoxDecoration(
              color: AppColors.primaryColor, shape: BoxShape.circle),
          todayDecoration:
              BoxDecoration(color: Colors.orangeAccent, shape: BoxShape.circle),
        ),
        headerStyle:
            const HeaderStyle(formatButtonVisible: false, titleCentered: true),
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
    );
  }

  Widget _buildTimeSelectors() {
    return Row(
      children: [
        Expanded(
          child: _buildTimeSelector(
              '시작 시간', _startTime, (time) => setState(() => _startTime = time)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTimeSelector(
              '종료 시간', _endTime, (time) => setState(() => _endTime = time)),
        ),
      ],
    );
  }

  Widget _buildTimeSelector(
      String label, TimeOfDay? time, Function(TimeOfDay) onSelect) {
    return InkWell(
      onTap: () async {
        final selectedTime = await showTimePicker(
          context: context,
          initialTime: time ?? TimeOfDay.now(),
        );
        if (selectedTime != null) {
          onSelect(selectedTime);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          time == null ? label : time.format(context),
          style: TextStyle(color: time == null ? Colors.grey : Colors.black),
        ),
      ),
    );
  }

  Widget _buildAllDayCheckbox() {
    return Row(
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
          activeColor: AppColors.primaryColor,
        ),
        const Text("하루종일"),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitEvent,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text("일정 만들기", style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
