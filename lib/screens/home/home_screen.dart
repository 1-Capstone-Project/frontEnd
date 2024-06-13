import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> imagePaths = [
    'assets/example/image1.jpeg',
    'assets/example/image2.jpeg',
    'assets/example/image3.jpeg',
    'assets/example/image4.jpeg',
    'assets/example/image5.jpeg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text("홈"),
      ),
      body: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2.5,
                color: Colors.blue,
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "최근 이벤트",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _buildEventContainers(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildEventContainers() {
    List<Widget> containers = [];
    for (int i = 0; i < imagePaths.length; i++) {
      containers.add(
        Container(
          width: 150,
          height: 180,
          margin: EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: AssetImage(imagePaths[i]),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }
    return containers;
  }
}
