import 'package:flutter/material.dart';

class HomeInfo extends StatelessWidget {
  const HomeInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Container(
            width: 300,
            height: 200,
            color: Colors.blue,
          ),
          Container(
            width: 300,
            height: 200,
            color: Colors.blue,
          ),
          Container(
            width: 300,
            height: 200,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}
