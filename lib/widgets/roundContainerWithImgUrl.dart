

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Container ContainerWithURLImg({required String? imgUrl, required double height, required double width, required Color? pc} ) {
    return Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: pc,
              border: pc != null ? Border.all(color: pc, width: height < 35 ? .3 : 4) : null,
               borderRadius: BorderRadius.circular(7),
               image: imgUrl != null ? DecorationImage(
                    image: CachedNetworkImageProvider(imgUrl),
                    fit: BoxFit.cover) : null )
            );
  }