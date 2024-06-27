import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:gitmate/const/colors.dart';
import 'package:gitmate/screens/home/home_detail_screen.dart';
import 'package:gitmate/screens/info/info_detail_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    _fetchCompanyInfo();
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
        setState(() {
          _companyInfo = fetchedData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to load company info. Status code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load company info. Error: $e';
        _isLoading = false;
      });
    }
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

  List<Widget> _buildEventContainers() {
    if (_isLoading) {
      return [
        const Center(
            child: CircularProgressIndicator(
          color: AppColors.primaryColor,
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
              color: Colors.blue,
              // border: Border.all(color: AppColors.primaryColor, width: 0.5),
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
}
