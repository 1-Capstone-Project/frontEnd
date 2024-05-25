import 'package:flutter/material.dart';
import 'package:gitmate/component/custom_text_form_field.dart';
import 'package:gitmate/screens/navigator.dart';
import 'package:gitmate/utils/colors.dart';
import 'package:gitmate/widget/logo_and_text.dart';

class SignScreen extends StatefulWidget {
  const SignScreen({super.key});

  @override
  State<SignScreen> createState() => _SignScreenState();
}

class _SignScreenState extends State<SignScreen> {
  String username = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const LogoAndText(),
              const SizedBox(height: 20.0),
              CustomTextFormField(
                hintText: '이메일을 입력해주세요.',
                onChanged: (String value) {
                  username = value;
                },
              ),
              const SizedBox(height: 15.0),
              CustomTextFormField(
                hintText: '비밀번호를 입력해주세요.',
                onChanged: (String value) {
                  password = value;
                },
                obscureText: true,
              ),
              const SizedBox(height: 15.0),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MainNavigator()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PRIMARY_COLOR,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('로그인'),
                ),
              ),
              const SizedBox(height: 15.0),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: Image.asset('assets/images/github_logo.png'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
