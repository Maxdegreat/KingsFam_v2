import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../extensions/hexcolor.dart';
// background color: Color(hexcolor.hexcolorCode('#20263c'))
// scondary color: Color(hc.hexcolorCode('#141829'))
class ThemeInfo {
  
  ThemeData themeClubHouseLight() {
    HexColor hexcolor = HexColor();
    return ThemeData(
      // cursorColor: Colors.black,
      brightness: Brightness.light,
      primaryColor: Colors.purple,
      appBarTheme: AppBarTheme(
        toolbarHeight: 45,
        textTheme: TextTheme(bodyText1: TextStyle(color: Colors.black, fontSize: 18),),
        color: Colors.white70,
        elevation: 1,
      ),
      //colorScheme: ColorScheme.light(),
      iconTheme: IconThemeData(color: Colors.black),
      drawerTheme: DrawerThemeData(backgroundColor: Colors.white),
      scaffoldBackgroundColor: Colors.grey[200],
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: Colors.white,
        primary: Colors.amber,
        onPrimary: Colors.grey,
        inversePrimary: Colors.black,
        outline: Colors.grey[800]
        ),
        canvasColor: Colors.white,
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.white70,
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
    // https://m2.material.io/design/color/dark-theme.html#anatomy
    HexColor hexcolor = HexColor(); 
    return ThemeData(
      
        // cursorColor: Colors.white,
        brightness: Brightness.dark,
        primaryColor: Colors.purple,
        appBarTheme: AppBarTheme( 
          // thats it! but what looks better. the app bar or screen body?
          toolbarHeight: 45,
          color: Colors.grey[900],// whats the hex val?
          elevation: 1,
        ),
        iconTheme: IconThemeData(color: Colors.white),
        drawerTheme: DrawerThemeData(backgroundColor: Color(hexcolor.hexcolorCode('#121212'))),
        scaffoldBackgroundColor: Color(hexcolor.hexcolorCode('#121212')),
        canvasColor:  Color(hexcolor.hexcolorCode("#141829")),
        bottomSheetTheme: BottomSheetThemeData(backgroundColor: Color(hexcolor.hexcolorCode('#121212'))),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          brightness: Brightness.dark,
          secondary: Colors.grey[900],
          primary: Colors.amber,
          inversePrimary: Colors.grey[400],
          onPrimary: Colors.black,
          outline: Colors.white30
        ),
        cardColor: Colors.grey[900],
        primaryColorDark: Colors.white,
        splashColor: Color.fromARGB(255, 13, 15, 63),
        textTheme: TextTheme(
            bodyText1: TextStyle(color: Colors.white, fontSize: 18),//GoogleFonts.acme(color: Colors.white, fontSize: 18),
            bodyText2: TextStyle(color: Color.fromARGB(255, 194, 194, 194), fontSize: 18),
            caption: TextStyle(color: Color.fromARGB(255, 194, 194, 194), fontSize: 14),
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
