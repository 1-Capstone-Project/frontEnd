import 'package:flutter/material.dart';
import 'package:gitmate/screens/calendar/calendar_screen.dart';
import 'package:gitmate/screens/community/community_screen.dart';
import 'package:gitmate/screens/home/home_screen.dart';
import 'package:gitmate/screens/info/info_screen.dart';
import 'package:gitmate/screens/profile/profile_screen.dart';
import 'package:gitmate/utils/colors.dart';
import 'package:motion_tab_bar/motiontabbar.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  final List<Widget> _navIndex = const [
    HomeScreen(),
    CommunityScreen(),
    InfoScreen(),
    CalendarScreen(),
    ProfileScreen(),
  ];

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _navIndex.elementAt(_selectedIndex),
      bottomNavigationBar: MotionTabBar(
        labels: const ["홈", "커뮤니티", "취업", "일정", "프로필"],
        initialSelectedTab: "홈",
        tabSize: 40,
        tabIconColor: Colors.grey,
        tabSelectedColor: PRIMARY_COLOR,
        onTabItemSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        icons: const [
          Icons.home_filled,
          Icons.chat,
          Icons.my_library_books,
          Icons.calendar_month_sharp,
          Icons.person,
        ],
        textStyle: const TextStyle(color: PRIMARY_COLOR),
      ),
    );
  }
}
