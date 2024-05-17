import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 3,
        title: Text('정보'),
      ),
      body: ListView(
        children: [
          Container(
            height: 1000,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}
