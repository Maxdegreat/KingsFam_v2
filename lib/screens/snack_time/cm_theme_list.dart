import 'package:flutter/material.dart';
import 'package:kingsfam/extensions/hexcolor.dart';

List<String> cmSvgThemes = [      // main colors
  "assets/cm_backgrounds/1.svg",  // dark blue
  "assets/cm_backgrounds/2.svg",  // 
  "assets/cm_backgrounds/3.svg",
  "assets/cm_backgrounds/4.svg",
  "assets/cm_backgrounds/5.svg",
  "assets/cm_backgrounds/6.svg",
  "assets/cm_backgrounds/7.svg"

];

HexColor hexColor = HexColor();

Map<String, dynamic> cmSvgColorThemes = {
  "1.svg" : {
    "p" : Color(hexColor.hexcolorCode("#cb9478")),
    "s" : Color(hexColor.hexcolorCode("colorHexCode"))}
};