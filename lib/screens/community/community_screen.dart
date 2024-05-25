import 'package:flutter/material.dart';
import 'package:gitmate/utils/colors.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10.0),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: BACKGROUND_COLOR,
          child: const Icon(Icons.edit),
        ),
      ),
    );
  }
}
