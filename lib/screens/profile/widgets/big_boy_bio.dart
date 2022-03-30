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
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: bio != null
              ? Text(
                  bio!,
                  style: TextStyle(color: Colors.white),
                )
              : SizedBox.shrink(),
        )
      ],
    );
  }
}
