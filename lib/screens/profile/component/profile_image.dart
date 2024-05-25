import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {
  final List<Widget> image;

  const ProfileImage({
    required this.image,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(5),
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: image[0],
          ),
        ),
        SizedBox(
          width: 110,
          height: 110,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 14,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(5),
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade500,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.edit,
                                size: 16, color: Colors.white),
                            padding: EdgeInsets.zero,
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
      ],
    );
  }
}
