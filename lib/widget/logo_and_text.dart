import 'package:flutter/material.dart';
import 'package:gitmate/utils/colors.dart';

class LogoAndText extends StatelessWidget {
  const LogoAndText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo.png',
          color: PRIMARY_COLOR,
          width: MediaQuery.of(context).size.width / 5,
        ),
        const Text(
          'GitMate',
          style: TextStyle(
            color: PRIMARY_COLOR,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
