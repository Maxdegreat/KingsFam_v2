import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../extensions/hexcolor.dart';
// background color: Color(hexcolor.hexcolorCode('#20263c'))
// scondary color: Color(hc.hexcolorCode('#141829'))
class ThemeInfo {

  ThemeData themeClubHouseLight() {
    HexColor hexcolor = HexColor();
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.blue,
      appBarTheme: AppBarTheme(
        toolbarHeight: 45,
        textTheme: TextTheme(bodyText1: TextStyle(color: Colors.black, fontSize: 18),),
        color: Colors.white,
        elevation: 1,
      ),
      //colorScheme: ColorScheme.light(),
      iconTheme: IconThemeData(color: Colors.black),
      drawerTheme: DrawerThemeData(backgroundColor: Colors.white),
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: Color.fromARGB(255, 207, 207, 207),
        primary: Colors.white24,
        background: Colors.grey),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      ),
      cardColor: Color.fromARGB(225, 207, 207, 207),
      primaryColorDark: Colors.grey[700],
      textTheme: TextTheme(
            bodyText1: TextStyle(color: Colors.black, fontSize: 18),//GoogleFonts.acme(color: Colors.white, fontSize: 18),
            bodyText2: TextStyle(color: Colors.white, fontSize: 18),
            caption: TextStyle(color: Colors.grey[800], fontSize: 14),
            subtitle1: GoogleFonts.aBeeZee(color: Colors.black),
            headline1: TextStyle(
                fontSize: 25.0,
                color: Colors.black,
                fontWeight: FontWeight.bold),
            headline2: TextStyle(
                fontSize: 23.0,
                color: Colors.black,
                fontWeight: FontWeight.bold),
            headline3: GoogleFonts.abhayaLibre(
              fontSize: 35,
              color: Colors.amber,
              fontWeight: FontWeight.bold
            ),
          ), 
    );
  }

  ThemeData themeClubHouseDark() {
    HexColor hexcolor = HexColor(); 
    return ThemeData(

        brightness: Brightness.dark,
        appBarTheme: AppBarTheme( 
          // thats it! but what looks better. the app bar or screen body?
          toolbarHeight: 45,
          color: Color(hexcolor.hexcolorCode('#20263c')),// whats the hex val?
          // Color.fromARGB(255, 32, 58, 79), to use hex i have to do some extra stuff. its too much
          elevation: 0,
        ),
        iconTheme: IconThemeData(color: Colors.white),
        drawerTheme: DrawerThemeData(backgroundColor: Colors.white),
        scaffoldBackgroundColor: Color(hexcolor.hexcolorCode('#20263c')),
        // Color.fromARGB(255, 32, 58, 79),
        bottomSheetTheme: BottomSheetThemeData(backgroundColor: Color(hexcolor.hexcolorCode("#141829"))),
        cardColor: Color(hexcolor.hexcolorCode('#141829')),
        primaryColorDark: Colors.white,
        splashColor: Color.fromARGB(255, 69, 18, 18),
        textTheme: TextTheme(
            bodyText1: TextStyle(color: Colors.white, fontSize: 18),//GoogleFonts.acme(color: Colors.white, fontSize: 18),
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
