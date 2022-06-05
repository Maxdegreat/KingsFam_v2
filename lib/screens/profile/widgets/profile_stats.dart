import 'package:flutter/material.dart';

class ProfileStats extends StatelessWidget {
  final int posts;
  final int followers;
  final int following;
  final String username;
  const ProfileStats({
    Key? key,
    required this.username,
    required this.posts,
    required this.followers,
    required this.following,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container( //FlexFit.loose fits for the flexible children (using Flexible rather than Expanded)
    
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
              
                      Text("$followers Followers", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(width: 10),
                      Text("$following Following", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))
                ],
              ),
            ),
          ],
        ));
  }
}

class _stats extends StatelessWidget {
  final int count;
  final String label;
  const _stats({
    Key? key,
    required this.count,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count.toString(),
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.white)),
        Text(label, style: TextStyle(color: Colors.white))
      ],
    );
  }
}
