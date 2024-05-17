import 'package:flutter/material.dart';
import 'package:gitmate/screens/home/widget/home_info.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: const [
              SizedBox(height: 300),
              HomeInfo(),
              HomeInfo(),
              HomeInfo(),
              HomeInfo(),
            ],
          ),
          Container(
            height: 300,
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
