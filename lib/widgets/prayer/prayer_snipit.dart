import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kingsfam/config/constants.dart';

Widget prayerSnipit(String? prayer, int? passedColor) {
  if (prayer == null) return SizedBox.shrink();
  if (prayer.length > 70) {
    prayer = prayer.substring(0, 70);
  }
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      height: 70,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Color(hc.hexcolorCode("#141829")),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("PRAYER ~ "),
            Text(prayer, overflow: TextOverflow.ellipsis, style: GoogleFonts.aBeeZee(fontWeight: FontWeight.w700),),
            Container(width: double.infinity, height: 1.5, color: Color(passedColor!),)
          ],
        ),
      ),
    ),
  );
}