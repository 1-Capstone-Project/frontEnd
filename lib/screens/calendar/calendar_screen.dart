import 'package:flutter/material.dart';
import 'package:gitmate/const/colors.dart';
import 'add_event_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final response =
          await http.get(Uri.parse('http://127.0.0.1:8080/schedules'));

      if (response.statusCode == 200) {
        final List<dynamic> events = json.decode(response.body);

        print('Decoded events: $events');

        setState(() {
          _events = events.map((event) {
            try {
              return {
                'date': DateTime.parse(event['schedule_date']),
                'title': event['title'],
                'content': event['description'],
                'start_time':
                    event['start_time'] == '' ? null : event['start_time'],
                'end_time': event['end_time'] == '' ? null : event['end_time'],
              };
            } catch (e) {
              rethrow;
            }
          }).toList();
        });
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  void _addEvent(DateTime date, String title, String content, String startTime,
      String endTime) {
    setState(() {
      _events.add({
        'date': date,
        'title': title,
        'content': content,
        'start_time': startTime,
        'end_time': endTime,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "일정",
          style: TextStyle(
            color: AppColors.backgroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leadingWidth: 50.0, // 리딩 위젯의 너비를 줄임
        leading: Padding(
          padding: EdgeInsets.only(left: 8.0), // 원하는 간격으로 설정
          child: Image.asset(
            'assets/images/logo.png',
            color: AppColors.backgroundColor,
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SizedBox(
          width: 60,
          height: 60,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEventScreen(onAddEvent: _addEvent),
                ),
              );
            },
            backgroundColor: AppColors.primaryColor,
            foregroundColor: AppColors.backgroundColor,
            shape: CircleBorder(),
            elevation: 10,
            child: Icon(Icons.calendar_month),
          ),
        ),
      ),
      body: _events.isEmpty
          ? Center(
              child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ))
          : ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(event['title']),
                    subtitle: Text(event['content']),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${event['date'].year}-${event['date'].month.toString().padLeft(2, '0')}-${event['date'].day.toString().padLeft(2, '0')}",
                        ),
                        if (event['start_time'] != null &&
                            event['end_time'] != null) ...[
                          Text("시작: ${event['start_time']}"),
                          Text("종료: ${event['end_time']}"),
                        ] else if (event['start_time'] == null &&
                            event['end_time'] == null) ...[
                          Text("하루 종일"),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
