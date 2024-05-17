import 'package:flutter/material.dart';
import 'package:gitmate/screens/community/component/community_post.dart';
import 'package:gitmate/utils/colors.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  // 새로 고침 작업을 수행하는 메서드
  Future<void> _refresh() async {
    // 새로 고침 작업을 여기에 구현하세요
    // 예를 들어, 데이터를 다시 불러오는 작업을 수행할 수 있습니다.
    await Future.delayed(Duration(seconds: 1)); // 임시로 1초 후에 완료되었다고 가정
    setState(() {
      // 상태를 업데이트하여 화면을 다시 그립니다.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: BACKGROUND_COLOR,
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: Text('커뮤니티'),
      ),
      body: RefreshIndicator(
        color: PRIMARY_COLOR,
        backgroundColor: Colors.white,
        onRefresh: _refresh,
        child: SingleChildScrollView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  CommunityPost(
                    images: [
                      Image.asset('assets/example/image2.jpeg',
                          fit: BoxFit.cover),
                      Image.asset('assets/example/image1.jpeg',
                          fit: BoxFit.cover),
                    ],
                    names: ['jinhyeon-dev', '날이 좋네요'],
                  ),
                  SizedBox(height: 10),
                  CommunityPost(
                    images: [
                      Image.asset('assets/example/image2.jpeg',
                          fit: BoxFit.cover),
                      Image.asset('assets/example/image1.jpeg',
                          fit: BoxFit.cover),
                    ],
                    names: ['jinhyeon-dev', '날이 좋네요'],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
