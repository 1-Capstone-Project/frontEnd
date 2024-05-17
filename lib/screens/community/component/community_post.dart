import 'package:flutter/material.dart';

class CommunityPost extends StatelessWidget {
  final List<Widget> images;
  final List<String> names;

  const CommunityPost({
    required this.images,
    required this.names,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20.0, bottom: 10.0),
      width: MediaQuery.of(context).size.width / 1.05,
      decoration: BoxDecoration(
        color: Colors.white,
        // color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.7),
            spreadRadius: 0,
            blurRadius: 5.0,
            offset: const Offset(0, 10), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: images[0],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      children: [
                        Text(
                          names[0],
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                  icon: const Icon(
                    Icons.bookmark_border,
                    size: 30,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 400,
            child: images[1],
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {},
                          icon: const Icon(
                            Icons.favorite_border,
                            size: 30,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {},
                          icon: const Icon(
                            Icons.chat_outlined,
                            size: 30,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.more_horiz,
                        size: 30,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Divider(
                  color: Colors.grey.shade800,
                  thickness: 1.0,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 40),
                  child: Row(
                    children: [
                      Text(names[1]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
