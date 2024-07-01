import 'package:flutter/material.dart';
import 'package:gitmate/const/colors.dart';
import 'details/add_event_screen.dart';
import 'details/event_detail_screen.dart';
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
  List<Map<String, dynamic>> _filteredEvents = [];
  bool _isLoading = true;
  Map<String, Map<String, dynamic>> _userProfiles = {};
  TextEditingController _searchController = TextEditingController();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
    _searchController.addListener(_filterEvents);
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

      if (mounted) {
        // 여기에 mounted 체크를 추가합니다.
        setState(() {
          _events = events;
          _filteredEvents = events;
          _events.sort((a, b) => b['date'].compareTo(a['date']));
          _isLoading = false;
        });

        for (var event in events) {
          _fetchUserProfile(event['user_id']);
        }
      }
    } catch (e) {
      print('Exception: $e');
      if (mounted) {
        // 여기에도 mounted 체크를 추가합니다.
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterEvents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEvents = _events.where((event) {
        final title = event['title'].toString().toLowerCase();
        return title.contains(query);
      }).toList();
    });
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

      if (mounted) {
        // 여기에 mounted 체크를 추가합니다.
        setState(() {
          _userProfiles[userId] = userProfile;
        });
      }
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
      _filterEvents();
    });
  }

  Future<void> _deleteEvent(String eventId) async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .delete();
      setState(() {
        _events.removeWhere((event) => event['id'] == eventId);
        _filteredEvents.removeWhere((event) => event['id'] == eventId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('일정이 삭제되었습니다.')),
      );
    } catch (e) {
      print('Failed to delete event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('일정 삭제에 실패했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "일정",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leadingWidth: 50.0,
        leading: Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Image.asset(
            'assets/images/logo.png',
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEventScreen(onAddEvent: _addEvent),
            ),
          );
        },
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '일정 제목 검색',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryColor))
                : _filteredEvents.isEmpty
                    ? const Center(child: Text("일정이 없습니다."))
                    : ListView.builder(
                        itemCount: _filteredEvents.length,
                        itemBuilder: (context, index) {
                          final event = _filteredEvents[index];
                          final userProfile = _userProfiles[event['user_id']];

                          return Card(
                            color: AppColors.backgroundColor,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: InkWell(
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (event['image_urls'] != null &&
                                      event['image_urls'].isNotEmpty)
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(12)),
                                      child: CarouselSlider.builder(
                                        itemCount: event['image_urls'].length,
                                        itemBuilder:
                                            (context, index, realIndex) {
                                          return Stack(
                                            alignment: Alignment.bottomRight,
                                            children: [
                                              Image.network(
                                                event['image_urls'][index],
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.7),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    '${index + 1}/${event['image_urls'].length}',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                        options: CarouselOptions(
                                          height: 200,
                                          viewportFraction: 1,
                                          enlargeCenterPage: false,
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                event['title'],
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            PopupMenuButton<String>(
                                              color: AppColors.backgroundColor,
                                              icon: Icon(Icons.more_vert),
                                              onSelected: (value) {
                                                if (value == 'edit') {
                                                  // 수정 기능 구현 예정
                                                } else if (value == 'delete') {
                                                  _deleteEvent(event['id']);
                                                } else if (value == 'report') {
                                                  // 신고 기능 구현 예정
                                                }
                                              },
                                              itemBuilder:
                                                  (BuildContext context) {
                                                if (event['user_id'] ==
                                                    currentUserId) {
                                                  return [
                                                    const PopupMenuItem<String>(
                                                      value: 'edit',
                                                      child: Text('수정'),
                                                    ),
                                                    const PopupMenuItem<String>(
                                                      value: 'delete',
                                                      child: Text('삭제'),
                                                    ),
                                                  ];
                                                } else {
                                                  return [
                                                    const PopupMenuItem<String>(
                                                      value: 'report',
                                                      child: Text('신고'),
                                                    ),
                                                  ];
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          event['content'],
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600]),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "${DateFormat('yyyy.MM.dd').format(event['date'])} ${event['start_time'] ?? ''} - ${event['end_time'] ?? ''}",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
