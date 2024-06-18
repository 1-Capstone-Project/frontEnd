import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AddEventScreen extends StatefulWidget {
  final Function(DateTime, String, String) onAddEvent;

  const AddEventScreen({super.key, required this.onAddEvent});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  CalendarFormat _calendarFormat = CalendarFormat.month; // 캘린더 포맷 추가

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text("일정 추가"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _selectedDate,
              calendarFormat: _calendarFormat, // 캘린더 포맷 설정
              selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                });
              },
              onFormatChanged: (format) {
                // 포맷 변경 콜백
                setState(() {
                  _calendarFormat = format;
                });
              },
            ),
            SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(hintText: "제목"),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(hintText: "내용"),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onAddEvent(
                    _selectedDate,
                    _titleController.text,
                    _contentController.text,
                  );
                  Navigator.pop(context);
                },
                child: Text("일정 만들기"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
