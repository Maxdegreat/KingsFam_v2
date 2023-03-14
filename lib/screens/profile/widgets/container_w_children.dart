import 'package:flutter/widgets.dart';

containerWChildren(List<Widget> children, Color borderColor, Color bgColor, double? width) => 
  Container(
    width: width,
    decoration: BoxDecoration(
      color: bgColor,
      border: Border.all(color: borderColor),
      borderRadius: BorderRadius.circular(7),
    ),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    ),
  );