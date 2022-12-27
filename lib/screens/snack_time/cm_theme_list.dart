import 'package:flutter/material.dart';
import 'package:kingsfam/extensions/hexcolor.dart';
import 'package:kingsfam/screens/screens.dart';

List<String> cmSvgThemes = [      
  "assets/cm_backgrounds/1.svg",  //  boba
  "assets/cm_backgrounds/2.svg",  // Jesus in the clouds
  "assets/cm_backgrounds/3.svg",  // black anime girl
  "assets/cm_backgrounds/4.svg",
  "assets/cm_backgrounds/5.svg",
  "assets/cm_backgrounds/6.svg",
  "assets/cm_backgrounds/7.svg"
];

List<String> cmSvgThemeTitles = [      
  "Coffie Boba",  //  boba
  "Why We Live (look closer)",  // Jesus in the clouds
  "Brown Skin Girl",  // black anime girl
  "Flipin Through Scripts",
  "Kitty Gamers",
  "Tacos To The Moon",
  "Pink Skys"
];


HexColor hexColor = HexColor();

Map<String, dynamic> cmSvgColorThemes = {
  "assets/cm_backgrounds/1.svg" : {
    "p" : Color(hexColor.hexcolorCode("#a7534c")),
    "s" : Color(hexColor.hexcolorCode("#000000")),
    "b" : Color(hexColor.hexcolorCode("#cb9478"))
  },
  "assets/cm_backgrounds/2.svg" : { 
    "p" : Color(hexColor.hexcolorCode("#8d3d75")),
    "b" : Color(hexcolor.hexcolorCode("#5f387f")),
    "d" : Color(hexColor.hexcolorCode("#455aae"))
  },
  "assets/cm_backgrounds/3.svg" : {
    "p" : Color(hexColor.hexcolorCode("#6B302C")), // using for boost banner
    "b" : Color(hexColor.hexcolorCode("#AD524B")),
    "d" : Color(hexColor.hexcolorCode("#7e433f"))
  },
  "assets/cm_backgrounds/4.svg" : {
    "p" : Color(hexColor.hexcolorCode("#E8874B")),
    "b" : Color(hexcolor.hexcolorCode("#EF6109")),
    "d" : Color(hexColor.hexcolorCode("#FF914D"))
  },
  "assets/cm_backgrounds/5.svg" : {
    "p" : Color(hexColor.hexcolorCode("#FF66C4")),
    "b" : Color(hexcolor.hexcolorCode("#D9D9D9")),
    "d" : Color(hexColor.hexcolorCode("#040203"))
  },
  "assets/cm_backgrounds/6.svg" : {
    "p" : Color(hexColor.hexcolorCode("#DB4B3D")),
    "b" : Color(hexcolor.hexcolorCode("#525248")),
    "d" : Color(hexColor.hexcolorCode("#000000"))
  },
    "assets/cm_backgrounds/7.svg" : {
    "p" : Color(hexColor.hexcolorCode("#D88BE3")),
    "b" : Color(hexcolor.hexcolorCode("#8B5DA4")),
    "d" : Color(hexColor.hexcolorCode("#EE87EF"))
  },

}; 