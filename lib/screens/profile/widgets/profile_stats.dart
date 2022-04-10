import 'package:flutter/material.dart';
import 'package:kingsfam/screens/profile/widgets/widgets.dart';

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
    return Flexible( //FlexFit.loose fits for the flexible children (using Flexible rather than Expanded)
    fit: FlexFit.loose,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(username, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 5),
                      Text("15 Commuinitys", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("$followers Followers", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 5),
                      Text("$following Following", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))
                    ],
                  )
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
