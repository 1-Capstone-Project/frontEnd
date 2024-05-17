import 'package:flutter/material.dart';
import 'package:gitmate/screens/profile/component/profile_bottomsheet.dart';

class ProfileSettingButton extends StatelessWidget {
  const ProfileSettingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: 100,
          height: 30,
          child: OutlinedButton(
            onPressed: () {
              // Scaffold.of(context).openEndDrawer();
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (BuildContext context) {
                  return const ProfileBottomSheet(); // use the bottom sheet widget
                },
              );
            },
            style: ButtonStyle(
              side: WidgetStateProperty.all(
                BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: const Text(
              '프로필설정',
              style: TextStyle(
                color: Colors.black,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
