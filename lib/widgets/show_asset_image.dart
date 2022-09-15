import 'package:flutter/material.dart';

showAssetImage(double height, double width, double? padding, String path) {
  padding = padding != null ? padding : 0;
  return Padding(
    padding: EdgeInsets.all(padding),
    child: Container(
      height: height,
      width: width,
      decoration:
          BoxDecoration(image: DecorationImage(image: AssetImage(path))),
    ),
  );
}

showImageFromAssetsPNG(
    double height, double width, double? padding, String path) {
  padding = padding != null ? padding : 0;
  return Padding(
    padding: EdgeInsets.all(padding),
    child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
            image:
                DecorationImage(image: AssetImage("assets/coin/KFcoin.png")))),
  );
}