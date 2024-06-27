import 'package:flutter/material.dart';
import 'package:gitmate/const/colors.dart';
import 'add_event_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
      final snapshot =
          await FirebaseFirestore.instance.collection('events').get();

      setState(() {
        _events = snapshot.docs.map((doc) {
          return {
            'date': DateFormat('yyyy-MM-dd').parse(doc['schedule_date']),
            'title': doc['title'],
            'content': doc['description'],
            'start_time': doc['start_time'],
            'end_time': doc['end_time'],
            'image_urls': List<String>.from(doc['image_urls']),
            'user_id': doc['user_id'],
          };
        }).toList();
      });
    } catch (e) {
      print('Exception: $e');
    }
  }

  Future<Map<String, dynamic>> _fetchUserProfile(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.exists
        ? {
            'nickname': userDoc['nickname'],
            'profile_image': userDoc['imageUrl'],
          }
        : {
            'nickname': 'Unknown',
            'profile_image': null,
          };
  }

  void _addEvent(DateTime date, String title, String content, String startTime,
      String endTime, List<String> imageUrls) {
    setState(() {
      _events.add({
        'date': date,
        'title': title,
        'content': content,
        'start_time': startTime,
        'end_time': endTime,
        'image_urls': imageUrls,
        'user_id': FirebaseAuth.instance.currentUser!.uid,
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
                return FutureBuilder<Map<String, dynamic>>(
                  future: _fetchUserProfile(event['user_id']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final userProfile = snapshot.data!;
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(event['title']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event['content']),
                            if (userProfile['profile_image'] != null)
                              CircleAvatar(
                                backgroundImage:
                                    NetworkImage(userProfile['profile_image']),
                                radius: 20,
                              ),
                            Text(userProfile['nickname']),
                            if (event['image_urls'] != null)
                              CarouselSlider(
                                options: CarouselOptions(
                                  height: 200.0,
                                  enableInfiniteScroll: false,
                                  enlargeCenterPage: true,
                                ),
                                items:
                                    event['image_urls'].map<Widget>((imageUrl) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        child: Image.network(imageUrl,
                                            fit: BoxFit.cover),
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
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
                );
              },
            ),
    );
  }
}
