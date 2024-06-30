import 'package:flutter/material.dart';
import 'package:gitmate/const/colors.dart';
import 'package:gitmate/screens/info/details/info_detail_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final List<dynamic> _companyInfo = [];
  List<dynamic> _filteredCompanyInfo = [];
  bool _isLoading = false;
  bool _hasMoreData = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchCompanyInfo();
    _searchController.addListener(_filterCompanyInfo);
  }

  Future<void> _fetchCompanyInfo() async {
    if (!_hasMoreData || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'http://gitmate-backend.com:8080/company_info?page=$_currentPage&limit=20'));

      if (response.statusCode == 200) {
        final List<dynamic> fetchedData = json.decode(response.body);
        if (fetchedData.length < 20) {
          _hasMoreData = false;
        }
        if (mounted) {
          setState(() {
            _companyInfo.addAll(fetchedData);
            _filteredCompanyInfo = _companyInfo;
            if (fetchedData.isNotEmpty) {
              _currentPage++;
            }
          });
        }
      } else {
        _errorMessage =
            'Failed to load company info. Status code: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Failed to load company info. Error: $e';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
    _searchController.removeListener(_filterCompanyInfo);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "취업",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leadingWidth: 50.0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Image.asset(
            'assets/images/logo.png',
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading && _companyInfo.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor))
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
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.search,
                              color: AppColors.primaryColor),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12.0),
                        ),
                        cursorColor: AppColors.primaryColor,
                      ),
                    ),
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (scrollInfo.metrics.pixels ==
                                  scrollInfo.metrics.maxScrollExtent &&
                              !_isLoading &&
                              _hasMoreData) {
                            _fetchCompanyInfo();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          itemCount: _filteredCompanyInfo.length,
                          itemBuilder: (context, index) {
                            final company = _filteredCompanyInfo[index];
                            return Card(
                              color: AppColors.backgroundColor,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          InfoDetailScreen(company: company),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.network(
                                          company['image_url'],
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 16.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              company['company_name'],
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4.0),
                                            Text(
                                              company['headquarters_location'],
                                              style: TextStyle(
                                                  color: Colors.grey[600]),
                                            ),
                                            const SizedBox(height: 4.0),
                                            Text(
                                              company['industry'],
                                              style: TextStyle(
                                                  color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 4.0),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                        ),
                                        child: const Text(
                                          '채용중',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
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
