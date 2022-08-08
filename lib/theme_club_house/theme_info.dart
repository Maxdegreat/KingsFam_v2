import 'package:flutter/material.dart';

class ThemeInfo {
  ThemeData themeClubHouseDark() {
    return ThemeData(
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(color: Colors.black),
        scaffoldBackgroundColor: Colors.black,
        primaryColorDark: Colors.red[300],
        textTheme: TextTheme(
            bodyText1: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
            bodyText2: TextStyle(fontSize: 15, color: Colors.grey[400]),
            headline1: TextStyle(
                fontSize: 25.0,
                color: Colors.red[400],
                fontWeight: FontWeight.bold),
            headline2: TextStyle(
                fontSize: 23.0,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        accentColor: Colors.white);
  }
}
