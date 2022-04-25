import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BannerImage extends StatelessWidget {
  final String? bannerImageUrl;
  final File? bannerImage; //comes form phone gallery
  final bool isOpasaty;
  final int? passedColor;
  final double? passedheight;

  const BannerImage({this.bannerImageUrl, this.passedheight,  this.bannerImage, required this.isOpasaty, this.passedColor});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Column(
        children: [
          Container(
            width: double.infinity,
            height: passedheight != null ? passedheight :  MediaQuery.of(context).size.height / 8,
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
          passedColor != null ? Container(height: 1, width: double.infinity, color: Color(passedColor!),) : SizedBox.shrink(),
          
        ],
      ),
      Container(
        color: isOpasaty ? Colors.black45 : Colors.transparent,
      )
    ]);
  }
}
