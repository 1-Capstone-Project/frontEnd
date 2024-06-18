import 'package:flutter/material.dart';
import 'package:gitmate/const/colors.dart';
import 'add_event_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<Map<String, dynamic>> _events = [];

  void _addEvent(DateTime date, String title, String content) {
    setState(() {
      _events.add({
        'date': date,
        'title': title,
        'content': content,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text("일정"),
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
      body: ListView.builder(
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(event['title']),
              subtitle: Text(event['content']),
              trailing: Text(
                "${event['date'].year}-${event['date'].month}-${event['date'].day}",
              ),
            ),
          );
        },
      ),
    );
  }
}
