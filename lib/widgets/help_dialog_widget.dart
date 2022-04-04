import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kingsfam/extensions/hexcolor.dart';
import 'package:rive/rive.dart';

Future<void> helpDialog(BuildContext context) async {
  return showDialog(context: context, builder: (context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900] ,
      content: howToBox(),
    );
  }
);
}

Widget howToBox() {
  int buildDotLen = 4;
  int currentIndex = 0;
  return StatefulBuilder(
    builder: (BuildContext context, setState) {
      return Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: Colors.grey[900]),
        height: 400,
        width: 450,
        child: PageView.builder(
          itemCount: buildDotLen ,
          onPageChanged: (int index) {setState(() {currentIndex = index;}); },
          itemBuilder: (_, i) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 35),
              child: _contents(currentIndex, buildDotLen)[i],
            );
          }
        ),
      );
    },
  );
}


List<Widget> _contents(int currIdx, int buildDotLen) {
  HexColor hexcolor = HexColor();
  return   [
    // ---------------------------------------------------------------- THIS IS DOT  1 --- WHAT IS KF
    Column(
      children: [
        Text(
          " Hey Fam, Find A Commuinity or ... Create One! \n"
          " Talk About Whatever But Keep Jesus At the Center! \n"
          " Yeherdd! ",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),


        SizedBox(height: 35),

        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(buildDotLen, (index) => buildDot(index, currIdx, hexcolor) ),
          ),
        ),


        SizedBox(height: 30),


        ElevatedButton(
          onPressed: () {}, 
          child: Text("Next"),
          style: ElevatedButton.styleFrom(primary: Color(hexcolor.hexcolorCode('#FFC050'))),
        )
      ],
    ),

    // --------------------------------> child 2 ------------------------------- ---------- THIS IS DOT 2 ---- MAIN FUNCTIONALITY OF KF HOW TO
    Column(
      children: [
        Text(
          " Tap The Bottom Left Search To Join A Commuinity! \n", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ), 

        Container(height: 35, width: 35, child: RiveAnimation.asset('assets/icons/search_icon.riv')),

        SizedBox(height: 35),


        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(buildDotLen, (index) => buildDot(index, currIdx, hexcolor) ),
          ),
        ),


        SizedBox(height: 30),


        ElevatedButton(
          onPressed: () {}, 
          child: Text("Next"),
          style: ElevatedButton.styleFrom(primary: Color(hexcolor.hexcolorCode('#FFC050'))),
        )
      ],
    ),
    

    // ----------------------------------------------> child 3 ------------------------------------------- how to make a commuinity or chat


    Column(
      children: [
        Text(
          " Or In The Top Right Click The Add To Create A Commuinity! \n", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ), 

        Container(height: 35, width: 35, child: RiveAnimation.asset('assets/icons/add_icon.riv')),

        SizedBox(height: 35),


        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(buildDotLen, (index) => buildDot(index, currIdx, hexcolor) ),
          ),
        ),


        SizedBox(height: 30),


        ElevatedButton(
          onPressed: () {}, 
          child: Text("Next"),
          style: ElevatedButton.styleFrom(primary: Color(hexcolor.hexcolorCode('#FFC050'))),
        )
      ],
    ),
    
    // ----------------------------------------------> child 4 ------------------------------------------- THIS IS DOT 3 JUMP IN (STILL IN BATA MODE THO)
    Column(
      children: [
        Text(
          " Great! KF Has more Fetures And More To Come "
          "Right Now We Are Still In Bata Mode "
          " To Help Or Be Hired Email Maximusagub@gmail.com ",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 35),


        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(buildDotLen, (index) => buildDot(index, currIdx, hexcolor) ),
          ),
        ),

        SizedBox(height: 30),

        ElevatedButton(
          onPressed: () {}, 
          child: Text("Lets Go!"),
          style: ElevatedButton.styleFrom(primary: Color(hexcolor.hexcolorCode('#FFC050'))),
        )
      ],
    )
  ];
}

Container buildDot(int index, int currIdx, HexColor hexcolor) {
  return Container(
    height: 10, width: currIdx == index ? 18 : 10, margin: EdgeInsets.only(right: 5), decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: Color(hexcolor.hexcolorCode('#FFC050'))),
  );
}