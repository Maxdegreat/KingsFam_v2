import 'package:flutter/material.dart';

class BigBoyBio extends StatelessWidget {
  final String username;
  final String? bio;
  const BigBoyBio({
    Key? key,
    required this.username,
    required this.bio,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        bio != null
            ? Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                  bio!,
                  style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500),
                ),
            )
            : SizedBox.shrink()
      ],
    );
  }
}
