

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Container ContainerWithURLImg({required String imgUrl, required double height, required double width, }) {
    return Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
               borderRadius: BorderRadius.circular(7),
               image: DecorationImage(
                    image: CachedNetworkImageProvider(imgUrl),
                    fit: BoxFit.cover))
            );
  }