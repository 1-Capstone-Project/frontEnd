// import 'package:flutter/material.dart';
// import 'package:gitmate/const/colors.dart';
// import 'package:gitmate/screens/info/info_detail_screen.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class InfoScreen extends StatefulWidget {
//   const InfoScreen({super.key});

//   @override
//   State<InfoScreen> createState() => _InfoScreenState();
// }

// class _InfoScreenState extends State<InfoScreen> {
//   final List<dynamic> _companyInfo = [];
//   List<dynamic> _filteredCompanyInfo = [];
//   bool _isLoading = false;
//   bool _hasMoreData = true;
//   String _errorMessage = '';
//   final TextEditingController _searchController = TextEditingController();
//   int _currentPage = 1;

//   @override
//   void initState() {
//     super.initState();
//     _fetchCompanyInfo();
//     _searchController.addListener(_filterCompanyInfo);
//   }

//   Future<void> _fetchCompanyInfo() async {
//     if (!_hasMoreData || _isLoading) return;

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final response = await http.get(Uri.parse(
//           'http://gitmate-backend.com:8080/company_info?page=$_currentPage&limit=20'));

//       if (response.statusCode == 200) {
//         final List<dynamic> fetchedData = json.decode(response.body);
//         if (fetchedData.length < 20) {
//           _hasMoreData = false;
//         }
//         if (mounted) {
//           setState(() {
//             _companyInfo.addAll(fetchedData);
//             _filteredCompanyInfo = _companyInfo;
//             if (fetchedData.isNotEmpty) {
//               _currentPage++;
//             }
//           });
//         }
//       } else {
//         _errorMessage =
//             'Failed to load company info. Status code: ${response.statusCode}';
//       }
//     } catch (e) {
//       _errorMessage = 'Failed to load company info. Error: $e';
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   void _filterCompanyInfo() {
//     final query = _searchController.text.toLowerCase();
//     setState(() {
//       _filteredCompanyInfo = _companyInfo.where((company) {
//         final companyName = company['company_name'].toString().toLowerCase();
//         return companyName.contains(query);
//       }).toList();
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(_filterCompanyInfo);
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         centerTitle: false,
//         scrolledUnderElevation: 0,
//         backgroundColor: AppColors.primaryColor,
//         title: const Text(
//           "취업",
//           style: TextStyle(
//             color: AppColors.backgroundColor,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         leadingWidth: 50.0, // 리딩 위젯의 너비를 줄임
//         leading: Padding(
//           padding: EdgeInsets.only(left: 8.0), // 원하는 간격으로 설정
//           child: Image.asset(
//             'assets/images/logo.png',
//             color: AppColors.backgroundColor,
//           ),
//         ),
//       ),
//       body: _isLoading && _companyInfo.isEmpty
//           ? const Center(child: CircularProgressIndicator())
//           : _errorMessage.isNotEmpty
//               ? Center(child: Text(_errorMessage))
//               : Column(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: TextField(
//                         controller: _searchController,
//                         decoration: InputDecoration(
//                           hintText: '회사 이름 검색',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10.0),
//                             borderSide: BorderSide.none,
//                           ),
//                           filled: true,
//                           fillColor: Colors.grey[200],
//                           prefixIcon: const Icon(Icons.search),
//                         ),
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             '총 데이터: ${_filteredCompanyInfo.length}개',
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                         ),
//                       ],
//                     ),
//                     Expanded(
//                       child: NotificationListener<ScrollNotification>(
//                         onNotification: (ScrollNotification scrollInfo) {
//                           if (scrollInfo.metrics.pixels ==
//                                   scrollInfo.metrics.maxScrollExtent &&
//                               !_isLoading &&
//                               _hasMoreData) {
//                             _fetchCompanyInfo();
//                           }
//                           return false;
//                         },
//                         child: Scrollbar(
//                           thumbVisibility: true,
//                           child: ListView.builder(
//                             itemCount: _filteredCompanyInfo.length,
//                             itemBuilder: (context, index) {
//                               final company = _filteredCompanyInfo[index];
//                               return GestureDetector(
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => InfoDetailScreen(
//                                         company: company,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                                 child: ListTile(
//                                   contentPadding: const EdgeInsets.all(8.0),
//                                   title: Text(
//                                     company['company_name'],
//                                     style: const TextStyle(
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   subtitle: Row(
//                                     children: [
//                                       Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           const SizedBox(height: 8.0),
//                                           Text(
//                                               '${company['headquarters_location']}'),
//                                           Text('${company['industry']}'),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                         // child: Scrollbar(
//                         //   thumbVisibility: true,
//                         //   child: ListView.builder(
//                         //     itemCount: _filteredCompanyInfo.length,
//                         //     itemBuilder: (context, index) {
//                         //       final company = _filteredCompanyInfo[index];
//                         //       return GestureDetector(
//                         //         onTap: () {
//                         //           Navigator.push(
//                         //             context,
//                         //             MaterialPageRoute(
//                         //               builder: (context) => InfoDetailScreen(
//                         //                 company: company,
//                         //               ),
//                         //             ),
//                         //           );
//                         //         },
//                         //         child: Card(
//                         //           color: AppColors.backgroundColor,
//                         //           margin: const EdgeInsets.all(8.0),
//                         //           child: Padding(
//                         //             padding: const EdgeInsets.all(16.0),
//                         //             child: Column(
//                         //               crossAxisAlignment:
//                         //                   CrossAxisAlignment.start,
//                         //               children: [
//                         //                   Center(
//                         //                     child: Container(
//                         //                       width: double.infinity,
//                         //                       height: 180,
//                         // child: Image.network(
//                         //   company['image_url'],
//                         //   fit: BoxFit.cover,
//                         // ),
//                         //                     ),
//                         //                   ),
//                         //                 const SizedBox(height: 8.0),
//                         //                 // Text(
//                         //                 //   company['company_name'],
//                         //                 //   style: const TextStyle(
//                         //                 //       fontSize: 20,
//                         //                 //       fontWeight: FontWeight.bold),
//                         //                 // ),
//                         //                 // const SizedBox(height: 8.0),
//                         //                 // Text(
//                         //                 //     'Headquarters: ${company['headquarters_location']}'),
//                         //                 // Text(
//                         //                 //     'Industry: ${company['industry']}'),
//                         //                 // Text('Welfare: ${company['welfare']}'),
//                         //                 // Text(
//                         //                 //     'Recruitment Method: ${company['recruitment_method']}'),
//                         //                 // Text(
//                         //                 //     'Requirements: ${company['requirements']}'),
//                         //               ],
//                         //             ),
//                         //           ),
//                         //         ),
//                         //       );
//                         //     },
//                         //   ),
//                         // ),
//                       ),
//                     ),
//                   ],
//                 ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:gitmate/const/colors.dart';
import 'package:gitmate/screens/info/info_detail_screen.dart';
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
          'http://127.0.0.1:8080/company_info?page=$_currentPage&limit=20'));

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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "취업",
          style: TextStyle(
            color: AppColors.backgroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leadingWidth: 50.0, // 리딩 위젯의 너비를 줄임
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0), // 원하는 간격으로 설정
          child: Image.asset(
            'assets/images/logo.png',
            color: AppColors.backgroundColor,
          ),
        ),
      ),
      body: _isLoading && _companyInfo.isEmpty
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
                    const Divider(
                      color: Colors.blue,
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
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(8.0),
                                  title: Text(
                                    company['company_name'],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Stack(
                                    children: [
                                      Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 8.0),
                                              Text(
                                                  '${company['headquarters_location']}'),
                                              Text('${company['industry']}'),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                width: 80,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 0.5,
                                                      color: AppColors
                                                          .primaryColor),
                                                ),
                                                child: Image.network(
                                                  company['image_url'],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                width: 80,
                                                height: 20,
                                                color: AppColors.primaryColor,
                                                child: const Center(
                                                  child: Text(
                                                    '채용중',
                                                    style: TextStyle(
                                                      color: AppColors
                                                          .backgroundColor,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
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
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
