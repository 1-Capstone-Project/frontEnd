import 'package:flutter/material.dart';
import 'package:gitmate/const/colors.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddEventScreen extends StatefulWidget {
  final Function(DateTime, String, String, String, String) onAddEvent;

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

  Future<void> _submitEvent() async {
    final startTimeStr = _allDay ? null : _startTime?.format(context);
    final endTimeStr = _allDay ? null : _endTime?.format(context);

    widget.onAddEvent(
      _selectedDate,
      _titleController.text,
      _contentController.text,
      startTimeStr ?? 'All Day',
      endTimeStr ?? 'All Day',
    );

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8080/schedules'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'title': _titleController.text,
          'description': _contentController.text,
          'schedule_date': DateFormat('yyyy-MM-dd').format(_selectedDate),
          'start_time': startTimeStr,
          'end_time': endTimeStr,
          'img_url': '',
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        print('Failed to add event. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to add event');
      }
    } catch (e) {
      print('Exception: $e');
      // 필요하다면 여기서 사용자에게 오류를 알릴 수 있습니다.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text("일정 추가"),
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
              TableCalendar(
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: AppColors.primaryColor,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonTextStyle: TextStyle(
                    color: AppColors.primaryColor,
                  ),
                  leftChevronIcon: Icon(
                    Icons.arrow_back_ios,
                    color: AppColors.primaryColor,
                  ),
                  rightChevronIcon: Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primaryColor,
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
                  Text("하루종일")
                ],
              ),
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
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitEvent,
                  child: Text("일정 만들기"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
