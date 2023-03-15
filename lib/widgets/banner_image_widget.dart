import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../config/constants.dart';

class BannerImage extends StatelessWidget {
  final String? bannerImageUrl;
  final File? bannerImage; //comes form phone gallery
  final bool isOpasaty;
  final double? passedheight;

  const BannerImage({this.bannerImageUrl, this.passedheight,  this.bannerImage, required this.isOpasaty});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: passedheight != null ? passedheight :  MediaQuery.of(context).size.height / 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Theme.of(context).colorScheme.secondary,
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
            
          ],
        ),
      ),
      Container(
        color: isOpasaty ? Colors.black45 : Colors.transparent,
      )
    ]);
  }
}
