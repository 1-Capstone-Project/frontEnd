import 'package:flutter/material.dart';
import 'package:gitmate/screens/profile/component/profile_image.dart';
import 'package:gitmate/screens/profile/widget/profile_setting_button.dart';
import 'package:gitmate/utils/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ignore: unused_field
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final backgroundImage = 'assets/example/image1.jpeg';
  final profileImage = 'assets/example/image2.jpeg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      // endDrawer: const ProfileDrawer(),

      body: RefreshIndicator(
        color: PRIMARY_COLOR,
        onRefresh: () async {},
        child: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 200,
              child: Image.asset(
                backgroundImage,
                fit: BoxFit.cover,
              ),
            ),
            ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 150),
                Stack(
                  children: [
                    Container(
                      color: Colors.white,
                      margin: const EdgeInsets.only(top: 50),
                      height: MediaQuery.of(context).size.height,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Stack(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 60),
                            child: ProfileSettingButton(),
                          ),
                          ProfileImage(
                            image: [
                              Image.asset(
                                profileImage,
                                fit: BoxFit.cover,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
