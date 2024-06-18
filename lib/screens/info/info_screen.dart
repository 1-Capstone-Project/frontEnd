import 'package:flutter/material.dart';
import 'package:gitmate/const/colors.dart';
import 'package:gitmate/screens/info/info_detail_screen.dart'; // 추가된 라인
import 'package:http/http.dart' as http;
import 'dart:convert';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  List<dynamic> _companyInfo = [];
  List<dynamic> _filteredCompanyInfo = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCompanyInfo();
    _searchController.addListener(_filterCompanyInfo);
  }

  Future<void> _fetchCompanyInfo() async {
    try {
      final response =
          await http.get(Uri.parse('http://127.0.0.1:8080/company_info'));

      if (response.statusCode == 200) {
        setState(() {
          _companyInfo = json.decode(response.body);
          _filteredCompanyInfo = _companyInfo;
          _isLoading = false;
          _errorMessage = '';
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Failed to load company info. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load company info. Error: $e';
      });
    }
  }

  void _filterCompanyInfo() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCompanyInfo = _companyInfo.where((company) {
        final companyName = company['company_name'].toString().toLowerCase();
        return companyName.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        scrolledUnderElevation: 0,
        title: const Text("취업"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: '회사 이름 검색',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          prefixIcon: const Icon(Icons.search),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '총 데이터: ${_filteredCompanyInfo.length}개',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: ListView.builder(
                          itemCount: _filteredCompanyInfo.length,
                          itemBuilder: (context, index) {
                            final company = _filteredCompanyInfo[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => InfoDetailScreen(
                                      company: company,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                color: AppColors.backgroundColor,
                                margin: const EdgeInsets.all(8.0),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (company['image_url'] != null &&
                                          company['image_url'].isNotEmpty)
                                        Center(
                                          child: Container(
                                            width: double.infinity,
                                            height: 180,
                                            child: Image.network(
                                              company['image_url'],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        company['company_name'],
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                          'Headquarters: ${company['headquarters_location']}'),
                                      Text('Industry: ${company['industry']}'),
                                      Text('Welfare: ${company['welfare']}'),
                                      Text(
                                          'Recruitment Method: ${company['recruitment_method']}'),
                                      Text(
                                          'Requirements: ${company['requirements']}'),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
