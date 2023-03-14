

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Container ContainerWithURLImg({required String imgUrl, required double height, required double width, required Color? pc}) {
    return Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              border: pc != null ? Border.all(color: pc, width: 4) : null,
               borderRadius: BorderRadius.circular(7),
               image: DecorationImage(
                    image: CachedNetworkImageProvider(imgUrl),
                    fit: BoxFit.cover))
            );
  }