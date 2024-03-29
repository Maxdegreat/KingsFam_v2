import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../config/constants.dart';


class ProfileImage extends StatelessWidget {
  final double radius;
  final String pfpUrl;
  final File? pfpImage; //if not null user wants to update image
  const ProfileImage({
    Key? key,
    required this.radius,
    required this.pfpUrl,
    this.pfpImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Color(hc.hexcolorCode('#141829')),
      backgroundImage: pfpImage != null
          ? FileImage(pfpImage!) as ImageProvider
          : pfpUrl.isNotEmpty
              ? CachedNetworkImageProvider(pfpUrl)
              : null,
      child: _noProfileIcon(),
    );
  }

  Icon? _noProfileIcon() {
    if (pfpImage == null && pfpUrl.isEmpty) {
      return Icon(Icons.account_circle, color: Color(hc.hexcolorCode('#141829')), size: radius * 1.5);
    }
    return null;
  }
}
