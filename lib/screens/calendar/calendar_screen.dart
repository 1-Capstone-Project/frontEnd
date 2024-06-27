import 'package:flutter/material.dart';
import 'package:gitmate/const/colors.dart';
import 'add_event_screen.dart';
import 'edit_event_screen.dart'; // 추가
import 'event_detail_screen.dart';
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
  bool _isLoading = true;
  Map<String, Map<String, dynamic>> _userProfiles = {};

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('events').get();

      final events = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'date': DateFormat('yyyy-MM-dd').parse(doc['schedule_date']),
          'title': doc['title'],
          'content': doc['description'],
          'start_time': doc['start_time'],
          'end_time': doc['end_time'],
          'image_urls': List<String>.from(doc['image_urls']),
          'user_id': doc['user_id'],
        };
      }).toList();

      setState(() {
        _events = events;
        _events.sort((a, b) => b['date'].compareTo(a['date']));
        _isLoading = false;
      });

      // 사용자 프로필 데이터를 비동기적으로 가져옴
      for (var event in events) {
        _fetchUserProfile(event['user_id']);
      }
    } catch (e) {
      print('Exception: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserProfile(String userId) async {
    if (!_userProfiles.containsKey(userId)) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final userProfile = userDoc.exists
          ? {
              'nickname': userDoc['nickname'],
              'profile_image': userDoc['imageUrl'],
            }
          : {
              'nickname': 'Unknown',
              'profile_image': null,
            };

      setState(() {
        _userProfiles[userId] = userProfile;
      });
    }
  }

  void _addEvent(DateTime date, String title, String content, String startTime,
      String endTime, List<String> imageUrls) {
    setState(() {
      _events.insert(0, {
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

  void _editEvent(String eventId, Map<String, dynamic> updatedEvent) {
    setState(() {
      final index = _events.indexWhere((event) => event['id'] == eventId);
      if (index != -1) {
        _events[index] = updatedEvent;
      }
    });
  }

  void _deleteEvent(String eventId) async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .delete();
      setState(() {
        _events.removeWhere((event) => event['id'] == eventId);
      });
    } catch (e) {
      print('Failed to delete event: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
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
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ))
          : _events.isEmpty
              ? Center(
                  child: Text("아직 일정이 없습니다."),
                )
              : ListView.builder(
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final event = _events[index];
                    final userProfile = _userProfiles[event['user_id']];

                    return Card(
                      color: AppColors.backgroundColor,
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventDetailScreen(
                                event: event,
                                userProfile: userProfile ?? {},
                              ),
                            ),
                          );
                        },
                        title: Text(event['title']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event['content']),
                            if (userProfile != null &&
                                userProfile['profile_image'] != null)
                              CircleAvatar(
                                backgroundImage:
                                    NetworkImage(userProfile['profile_image']),
                                radius: 20,
                              ),
                            if (userProfile != null)
                              Text(userProfile['nickname']),
                            if (event['image_urls'] != null)
                              CarouselSlider(
                                options: CarouselOptions(
                                  height: 300.0, // 이미지 높이 조정
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
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              spreadRadius: 1,
                                              blurRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: Image.network(imageUrl,
                                              fit: BoxFit.cover),
                                        ),
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
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete') {
                              _deleteEvent(event['id']);
                            } else if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditEventScreen(
                                    event: event,
                                    onEditEvent: _editEvent,
                                  ),
                                ),
                              );
                            } else if (value == 'report') {
                              // 신고 기능 추가
                              print('Report event: ${event['id']}');
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return <PopupMenuEntry<String>>[
                              if (event['user_id'] == currentUser!.uid) ...[
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Text('수정'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('삭제'),
                                ),
                              ] else
                                const PopupMenuItem<String>(
                                  value: 'report',
                                  child: Text('신고'),
                                ),
                            ];
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
