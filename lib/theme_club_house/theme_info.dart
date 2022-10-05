import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../extensions/hexcolor.dart';
// background color: Color(hexcolor.hexcolorCode('#20263c'))
// scondary color: Color(hc.hexcolorCode('#141829'))
class ThemeInfo {
  ThemeData themeClubHouseDark() {
    HexColor hexcolor = HexColor(); // 1 sec
    return ThemeData(
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme( // thats it! but what looks better. the app bar or screen body?
          color: Color(hexcolor.hexcolorCode('#20263c')),// whats the hex val?
          // Color.fromARGB(255, 32, 58, 79), to use hex i have to do some extra stuff. its too much
          elevation: 0,
        ),
        scaffoldBackgroundColor: Color(hexcolor.hexcolorCode('#20263c')),
        // Color.fromARGB(255, 32, 58, 79),
        primaryColorDark: Colors.white,
        textTheme: TextTheme(
            bodyText1: GoogleFonts.acme(color: Colors.white, fontSize: 18),
            bodyText2: GoogleFonts.aBeeZee(color: Colors.white, fontSize: 17),
            subtitle1: GoogleFonts.aBeeZee(color: Colors.white),
            headline1: TextStyle(
                fontSize: 25.0,
                color: Colors.white,
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
