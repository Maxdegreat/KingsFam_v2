import 'package:flutter/material.dart';
import 'package:kingsfam/screens/profile/widgets/widgets.dart';

class ProfileStats extends StatelessWidget {
  final bool isCurrentUserr;
  final bool isFollowing;
  final int posts;
  final int followers;
  final int following;
  const ProfileStats({
    Key? key,
    required this.isCurrentUserr,
    required this.isFollowing,
    required this.posts,
    required this.followers,
    required this.following,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible( //FlexFit.loose fits for the flexible children (using Flexible rather than Expanded)
    fit: FlexFit.loose,
        child: Padding(
      padding: const EdgeInsets.only(right: 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _stats(count: posts, label: 'posts'),
              _stats(count: following, label: 'following'),
              _stats(count: followers, label: 'followers')
            ],
          ),
          const SizedBox(height: 10.0),
          Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: ProfileButton(
              isCurrentUserr: isCurrentUserr,
              isFollowing: isFollowing
            ),

          )

        ],
      ),
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
