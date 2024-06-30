import 'package:flutter/material.dart';
import 'package:gitmate/const/colors.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';

class EventDetailScreen extends StatefulWidget {
  final Map<String, dynamic> event;
  final Map<String, dynamic> userProfile;

  const EventDetailScreen({
    Key? key,
    required this.event,
    required this.userProfile,
  }) : super(key: key);

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "일정 정보",
          style: TextStyle(
            color: Colors.white,
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
            _buildImageSlider(),
            _buildEventDetails(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSlider() {
    if (widget.event['image_urls'] == null ||
        widget.event['image_urls'].isEmpty) {
      return Container(
        height: 250,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenImageGallery(
              imageUrls: widget.event['image_urls'],
              initialIndex: _currentImageIndex,
            ),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 250.0,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
            ),
            items: widget.event['image_urls'].map<Widget>((imageUrl) {
              return Image.network(imageUrl,
                  fit: BoxFit.cover, width: double.infinity);
            }).toList(),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentImageIndex + 1} / ${widget.event['image_urls'].length}',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserInfo(),
          const SizedBox(height: 16),
          _buildEventInfo(context),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: widget.userProfile['profile_image'] != null
              ? NetworkImage(widget.userProfile['profile_image'])
              : null,
          radius: 25,
          child: widget.userProfile['profile_image'] == null
              ? const Icon(Icons.person, size: 25, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 12),
        Text(
          widget.userProfile['nickname'] ?? 'Unknown User',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEventInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.event['title'],
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.event['content'],
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        _buildDateTimeInfo(context),
      ],
    );
  }

  Widget _buildDateTimeInfo(BuildContext context) {
    final dateFormatter = DateFormat('yyyy년 MM월 dd일');
    final timeFormatter = DateFormat('HH:mm');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              Text(
                dateFormatter.format(widget.event['date']),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.event['start_time'] != null &&
              widget.event['end_time'] != null) ...[
            Row(
              children: [
                const Icon(Icons.access_time, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                Text(
                  "${widget.event['start_time']} - ${widget.event['end_time']}",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ] else ...[
            const Row(
              children: [
                Icon(Icons.access_time, color: AppColors.primaryColor),
                SizedBox(width: 8),
                Text(
                  "하루종일",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class FullScreenImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImageGallery({
    Key? key,
    required this.imageUrls,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _FullScreenImageGalleryState createState() => _FullScreenImageGalleryState();
}

class _FullScreenImageGalleryState extends State<FullScreenImageGallery> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                child: Image.network(
                  widget.imageUrls[index],
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Text(
              '${_currentIndex + 1} / ${widget.imageUrls.length}',
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
