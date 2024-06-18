import 'package:flutter/material.dart';

class InfoDetailScreen extends StatelessWidget {
  final Map<String, dynamic> company;

  const InfoDetailScreen({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(company['company_name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (company['image_url'] != null)
                Center(
                  child: Image.network(company['image_url']),
                ),
              const SizedBox(height: 16.0),
              Text(
                company['company_name'],
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              Text('Headquarters: ${company['headquarters_location']}'),
              const SizedBox(height: 8.0),
              Text('Industry: ${company['industry']}'),
              const SizedBox(height: 8.0),
              Text('Welfare: ${company['welfare']}'),
              const SizedBox(height: 8.0),
              Text('Recruitment Method: ${company['recruitment_method']}'),
              const SizedBox(height: 8.0),
              Text('Requirements: ${company['requirements']}'),
            ],
          ),
        ),
      ),
    );
  }
}
