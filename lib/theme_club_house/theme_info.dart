import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeInfo {
  ThemeData themeClubHouseDark() {
    return ThemeData(
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(color: Colors.black),
        scaffoldBackgroundColor: Colors.black,
        primaryColorDark: Colors.red[300],
        textTheme: TextTheme(
            bodyText1: GoogleFonts.acme(color: Colors.white, fontSize: 18),
            bodyText2: GoogleFonts.aBeeZee(color: Colors.white, fontSize: 17),
            subtitle1: GoogleFonts.aBeeZee(color: Colors.white),
            headline1: TextStyle(
                fontSize: 25.0,
                color: Colors.red[400],
                fontWeight: FontWeight.bold),
            headline2: TextStyle(
                fontSize: 23.0,
                color: Colors.white,
                fontWeight: FontWeight.bold),
            headline3: GoogleFonts.abhayaLibre(
              fontSize: 35,
              color: Colors.amber,
              fontWeight: FontWeight.bold
            )
          ),
        accentColor: Colors.white);
  }
}
