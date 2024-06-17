import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:gitmate/const/colors.dart';
import 'detail_screen.dart';

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

  Future<void> _refresh() async {
    // 새로고침 로직 추가
    await Future.delayed(Duration(seconds: 2)); // 2초 동안 대기
    // 여기에서 데이터를 새로 불러오거나 갱신할 수 있습니다.
    setState(() {
      // 데이터 갱신 로직 추가
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0.0, // 기본 타이틀과 리딩 간의 간격을 줄임
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0), // 원하는 간격으로 설정
          child: Text(
            "GitMate",
            style: TextStyle(
              color: AppColors.backgroundColor,
              fontWeight: FontWeight.bold,
            ),
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
      body: RefreshIndicator(
        color: AppColors.primaryColor,
        onRefresh: _refresh,
        child: ListView(
          children: [
            _buildImageSlider(),
            _buildEventSection("최근 이벤트"),
            _buildEventSection("마감임박"),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSlider() {
    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height / 2.5,
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
                    width: MediaQuery.of(context).size.width,
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
          child: Row(
            children: _buildEventContainers(),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildEventContainers() {
    return sliderImagePaths.map((path) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(
                imagePath: path,
                title: 'Event Image',
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
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: AssetImage(path),
              fit: BoxFit.fill,
            ),
          ),
        ),
      );
    }).toList();
  }
}
