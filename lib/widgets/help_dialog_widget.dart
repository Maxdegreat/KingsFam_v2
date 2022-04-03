import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kingsfam/extensions/hexcolor.dart';

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
  int currentIndex = 0;
  return StatefulBuilder(
    builder: (BuildContext context, setState) {
      return Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: Colors.grey[900]),
        height: 400,
        width: 450,
        child: PageView.builder(
          itemCount: 3,
          onPageChanged: (int index) {setState(() {currentIndex = index;}); },
          itemBuilder: (_, i) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 35),
              child: _contents(currentIndex)[i],
            );
          }
        ),
      );
    },
  );
}

class onboardingContent {
  final File image;
  final String text;

  onboardingContent(this.image, this.text);
}

List<Widget> _contents(int currIdx) {
  HexColor hexcolor = HexColor();
  return   [
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
            children: List.generate(3, (index) => buildDot(index, currIdx, hexcolor) ),
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

    // --------------------------------> child 2
    Column(
      children: [
        Text(
          " Hey Fam, Find A Commuinity You Want To Join! "
          " Talk About Whatever But Keep Jesus At the Center! \n"
          " Yeherdd! ",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 35),


        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) => buildDot(index, currIdx, hexcolor) ),
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
    // ----------------------------------------------> child 3
    Column(
      children: [
        Text(
          " Hey Fam, Find A Commuinity You Want To Join! "
          " Talk About Whatever But Keep Jesus At the Center! \n"
          " Yeherdd! ",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 35),


        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) => buildDot(index, currIdx, hexcolor) ),
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