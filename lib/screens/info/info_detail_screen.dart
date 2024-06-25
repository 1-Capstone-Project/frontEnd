import 'package:flutter/material.dart';
import 'package:gitmate/const/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoDetailScreen extends StatelessWidget {
  final Map<String, dynamic> company;

  const InfoDetailScreen({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        centerTitle: false,
        title: Text(
          company['company_name'],
          style: const TextStyle(
            color: AppColors.backgroundColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          color: AppColors.backgroundColor, // 뒤로가기 버튼 색상
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (company['image_url'] != null)
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 4,
                child: Image.network(
                  company['image_url'],
                  fit: BoxFit.cover,
                ),
              ),
            Container(
              margin: EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        company['company_name'],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('${company['headquarters_location']}' +
                          '·' +
                          '${company['industry']}' +
                          '·' +
                          '${company['recruitment_method']}'),
                    ],
                  ),
                ],
              ),
            ),
            // 회사 정보 버튼 추가
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final url = Uri.parse(company['website']);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
                child: const Text('Visit Website'),
              ),
            ),
            // 나머지 회사 정보 표시 (주석을 해제해서 필요 시 사용)
            // Text(
            //   company['company_name'],
            //   style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(height: 16.0),
            // Text('Headquarters: ${company['headquarters_location']}'),
            // const SizedBox(height: 8.0),
            // Text('Industry: ${company['industry']}'),
            // const SizedBox(height: 8.0),
            // Text('Welfare: ${company['welfare']}'),
            // const SizedBox(height: 8.0),
            // Text('Recruitment Method: ${company['recruitment_method']}'),
            // const SizedBox(height: 8.0),
            // Text('Requirements: ${company['requirements']}'),
          ],
        ),
      ),
    );
  }
}
