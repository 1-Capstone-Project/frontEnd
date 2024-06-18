import 'package:flutter/material.dart';
import 'package:gitmate/const/colors.dart';

class DetailScreen extends StatelessWidget {
  final String imagePath;
  final String title;

  const DetailScreen({super.key, required this.imagePath, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          "일정 정보",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        children: [
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.fill,
                ),
              ),
            ],
          ),
        ],
      ),
      // body: Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Image.asset(imagePath),
      //       SizedBox(height: 20),
      //       Text(
      //         title,
      //         style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      //       ),
      //       // 여기에 이미지에 대한 추가 정보를 추가할 수 있습니다.
      //     ],
      //   ),
      // ),
    );
  }
}
