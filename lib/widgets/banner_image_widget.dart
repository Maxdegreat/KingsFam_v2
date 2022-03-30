import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BannerImage extends StatelessWidget {
  final String? bannerImageUrl;
  final File? bannerImage; //comes form phone gallery
  final bool isOpasaty;

  const BannerImage({this.bannerImageUrl, this.bannerImage, required this.isOpasaty});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height / 8,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          image: bannerImage != null
              ? DecorationImage(
                  image: FileImage(bannerImage!), fit: BoxFit.fitWidth)
              : bannerImageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(bannerImageUrl!),
                      fit: BoxFit.fitWidth)
                  : null,
        ),
      ),
      Container(
        color: isOpasaty ? Colors.black45 : Colors.transparent,
      )
    ]);
  }
}
