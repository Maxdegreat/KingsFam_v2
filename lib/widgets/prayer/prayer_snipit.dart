import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kingsfam/config/constants.dart';

Widget prayerSnipit(String? prayer, int? passedColor, BuildContext context) {
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
        gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).colorScheme.primary
              ]),
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).colorScheme.secondary),
      child: Padding(
        padding: const EdgeInsets.all(5.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Prayer ~ ", style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey),),
            Text(prayer, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.caption,),
            Container(width: double.infinity, height: 1, color: Color(passedColor!),)
          ],
        ),
      ),
    ),
  );
}