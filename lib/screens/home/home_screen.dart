import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 300,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.elliptical(200, 60),
                    bottomRight: Radius.elliptical(200, 60),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
