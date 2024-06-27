import 'package:flutter/material.dart';
import 'package:gitmate/const/colors.dart';
import 'package:carousel_slider/carousel_slider.dart';

class EventDetailScreen extends StatelessWidget {
  final Map<String, dynamic> event;
  final Map<String, dynamic> userProfile;

  const EventDetailScreen({
    Key? key,
    required this.event,
    required this.userProfile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "일정 정보",
          style: TextStyle(
            color: AppColors.backgroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (userProfile['profile_image'] != null)
                Center(
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(userProfile['profile_image']),
                    radius: 50,
                  ),
                ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  userProfile['nickname'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (event['image_urls'] != null)
                CarouselSlider(
                  options: CarouselOptions(
                    height: 200.0,
                    enableInfiniteScroll: false,
                    enlargeCenterPage: true,
                  ),
                  items: event['image_urls'].map<Widget>((imageUrl) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 1.0),
                          child: Image.network(imageUrl, fit: BoxFit.cover),
                        );
                      },
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),
              Text(
                event['title'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                event['content'],
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "날짜: ${event['date'].year}-${event['date'].month.toString().padLeft(2, '0')}-${event['date'].day.toString().padLeft(2, '0')}",
                style: const TextStyle(fontSize: 16),
              ),
              if (event['start_time'] != null && event['end_time'] != null) ...[
                Text("Start Time: ${event['start_time']}"),
                Text("End Time: ${event['end_time']}"),
              ] else if (event['start_time'] == null &&
                  event['end_time'] == null) ...[
                const Text("하루종일"),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
