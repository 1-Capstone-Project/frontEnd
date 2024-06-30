import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:gitmate/const/colors.dart';
import 'package:gitmate/screens/home/details/home_detail_screen.dart';
import 'package:gitmate/screens/info/details/info_detail_screen.dart';
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
      final response = await http.get(Uri.parse(
          'http://gitmate-backend.com:8080/company_info?page=1&limit=10'));

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "GitMate",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Image.asset(
            'assets/images/logo.png',
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications, color: Colors.white),
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildImageSlider(),
          _buildSection("채용중인 기업", _buildEventContainers()),
          _buildSection("최근 일정", _buildRecentEventContainers()),
        ],
      ),
    );
  }

  Widget _buildImageSlider() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          CarouselSlider(
            options: CarouselOptions(
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
                          fit: BoxFit.cover,
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
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == entry.key
                        ? AppColors.primaryColor
                        : Colors.white.withOpacity(0.4),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: content),
        ),
      ],
    );
  }

  List<Widget> _buildEventContainers() {
    if (_isLoading) {
      return [const Center(child: CircularProgressIndicator())];
    } else if (_errorMessage.isNotEmpty) {
      return [Center(child: Text(_errorMessage))];
    } else {
      return _companyInfo.map((company) {
        return _buildEventItem(
          title: company['company_name'],
          imageUrl: company['image_url'],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InfoDetailScreen(company: company),
              ),
            );
          },
        );
      }).toList();
    }
  }

  List<Widget> _buildRecentEventContainers() {
    if (_isEventsLoading) {
      return [const Center(child: CircularProgressIndicator())];
    } else if (_events.isEmpty) {
      return [const Center(child: Text('최근 일정이 아직 없습니다.'))];
    } else {
      return _events.take(10).map((event) {
        return _buildEventItem(
          title: event['title'],
          imageUrl:
              event['image_urls'].isNotEmpty ? event['image_urls'][0] : null,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailScreen(event: event),
              ),
            );
          },
        );
      }).toList();
    }
  }

  Widget _buildEventItem(
      {required String title, String? imageUrl, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 200,
        margin: const EdgeInsets.only(left: 16.0, bottom: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 120,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventDetailScreen extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event['title']),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event['image_urls'] != null && event['image_urls'].isNotEmpty)
              CarouselSlider(
                options: CarouselOptions(
                  height: 300.0,
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                ),
                items: event['image_urls'].map<Widget>((imageUrl) {
                  return Image.network(imageUrl,
                      fit: BoxFit.cover, width: double.infinity);
                }).toList(),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'],
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "일정: ${DateFormat('yyyy년 MM월 dd일').format(event['date'])}",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "시간: ${event['start_time']} - ${event['end_time']}",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    event['content'],
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
