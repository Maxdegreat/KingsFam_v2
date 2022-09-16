import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget prayerSnipit(String prayer, int? passedColor) {
  if (prayer.length > 70) {
    prayer = prayer.substring(0, 70);
  }
  return Container(
    height: 50,
    width: double.infinity,
    child: Column(
      children: [
        Text("PRAYER ~ "),
        Text(prayer, overflow: TextOverflow.ellipsis, style: GoogleFonts.aBeeZee(fontWeight: FontWeight.w700),),
        Container(width: double.infinity, height: 5, color: Color(passedColor!),)
      ],
    ),
    color: Colors.transparent
  );
}