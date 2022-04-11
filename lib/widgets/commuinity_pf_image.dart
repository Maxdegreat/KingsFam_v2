import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

// ignore: non_constant_identifier_names
Container commuinity_pf_img(String url, double height, double width) {
  return Container(
    height: height,
    width: width,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(50),
      image: DecorationImage(image: CachedNetworkImageProvider(url))
    ),
  );
}