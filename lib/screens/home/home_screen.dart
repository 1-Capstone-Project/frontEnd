import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:gitmate/const/colors.dart';
import 'package:gitmate/screens/home/home_detail_screen.dart';
import 'package:gitmate/screens/info/info_detail_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> sliderImagePaths = [
    'assets/event/image1.jpeg',
    'assets/event/image2.jpeg',
    'assets/event/image3.jpeg',
    'assets/event/image4.jpeg',
    'assets/event/image5.jpeg',
  ];

  final List<String> imagePaths = [
    'assets/example/image1.jpeg',
    'assets/example/image2.jpeg',
    'assets/example/image3.jpeg',
    'assets/example/image4.jpeg',
    'assets/example/image5.jpeg',
  ];

  int _currentIndex = 0;
  List<dynamic> _companyInfo = [];
  bool _isLoading = true;
  String _errorMessage = '';
  List<Map<String, dynamic>> _events = [];
  bool _isEventsLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCompanyInfo();
    _fetchEvents();
  }

  Future<void> _fetchCompanyInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http
          .get(Uri.parse('http://127.0.0.1:8080/company_info?page=1&limit=10'));

      if (response.statusCode == 200) {
        final List<dynamic> fetchedData = json.decode(response.body);
        if (mounted) {
          setState(() {
            _companyInfo = fetchedData;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage =
                'Failed to load company info. Status code: ${response.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load company info. Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchEvents() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('events').get();

      if (mounted) {
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
          _isEventsLoading = false;
        });
      }
    } catch (e) {
      print('Exception: $e');
      if (mounted) {
        setState(() {
          _isEventsLoading = false;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          "GitMate",
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
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications,
              color: AppColors.backgroundColor,
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildImageSlider(),
          _buildEventSection("채용중인 기업"),
          _buildRecentEventsSection("최근 일정"),
        ],
      ),
    );
  }

  Widget _buildImageSlider() {
    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            // height: MediaQuery.of(context).size.height / 2.5,
            viewportFraction: 1.0,
            autoPlay: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: sliderImagePaths.map((path) {
            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(
                          imagePath: path,
                          title: 'Slider Image',
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(path),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        Positioned(
          bottom: 10.0,
          left: 0.0,
          right: 0.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: sliderImagePaths.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => setState(() => _currentIndex = entry.key),
                child: Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.grey)
                        .withOpacity(_currentIndex == entry.key ? 0.9 : 0.4),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEventSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: _buildEventContainers(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentEventsSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: _buildRecentEventContainers(),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildEventContainers() {
    if (_isLoading) {
      return [
        const Center(
            child: CircularProgressIndicator(
          color: Colors.transparent,
        )),
      ];
    } else if (_errorMessage.isNotEmpty) {
      return [
        Center(
          child: Text(_errorMessage),
        ),
      ];
    } else {
      return _companyInfo.map((company) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InfoDetailScreen(
                  company: company,
                ),
              ),
            );
          },
          child: Container(
            width: 150,
            height: 180,
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(3, 5), // changes position of shadow
                ),
              ],
              image: company['image_url'] != null
                  ? DecorationImage(
                      image: NetworkImage(company['image_url']),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    company['company_name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList();
    }
  }

  List<Widget> _buildRecentEventContainers() {
    if (_isEventsLoading) {
      return [
        const Center(
            child: CircularProgressIndicator(
          color: Colors.transparent,
        )),
      ];
    } else if (_events.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.only(left: 15),
          child: Center(
            child: Text('최근 일정이 아직 없습니다.'),
          ),
        ),
      ];
    } else {
      return _events.take(10).map((event) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailScreen(event: event),
              ),
            );
          },
          child: Container(
            width: 150,
            height: 180,
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(3, 5), // changes position of shadow
                ),
              ],
              image: event['image_urls'].isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(event['image_urls'][0]),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    event['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList();
    }
  }
}

class EventDetailScreen extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailScreen({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event['image_urls'] != null && event['image_urls'].isNotEmpty)
              CarouselSlider(
                options: CarouselOptions(
                  height: 400.0,
                  enableInfiniteScroll: false,
                  enlargeCenterPage: true,
                ),
                items: event['image_urls'].map<Widget>((imageUrl) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              spreadRadius: 1,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(imageUrl, fit: BoxFit.cover),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),
            Text(
              event['content'],
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              "시작 시간: ${event['start_time']}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "종료 시간: ${event['end_time']}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
