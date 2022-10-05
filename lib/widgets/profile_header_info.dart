import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kingsfam/extensions/date_time_extension.dart';
import 'package:kingsfam/widgets/widgets.dart';

class ProfileHeaderInfo extends StatelessWidget {
  final String? imgUrl;
  final String username;
  final Timestamp? timestamp;
  const ProfileHeaderInfo(
      {Key? key, required this.username, required this.imgUrl, this.timestamp})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return timestamp == null ? Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileImage(radius: 25, pfpUrl: imgUrl ?? ""),
        const SizedBox(width: 10),
        Text(username)
      ],
    ) : Row(
       mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ProfileImage(radius: 25, pfpUrl: imgUrl ?? ""),
        const SizedBox(width: 10),
        Text(username), Text(" ~ " +timestamp!.timeAgo(),)
        
      ],
    );
  }
}
