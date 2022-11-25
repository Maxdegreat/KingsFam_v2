import 'package:flutter/material.dart';
import 'package:kingsfam/extensions/hexcolor.dart';
import 'package:rive/rive.dart';

import '../config/constants.dart';

Future<void> helpDialog(BuildContext context) async {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          content: howToBox(),
        );
      });
}

Widget howToBox() {
  int buildDotLen = 4;
  int currentIndex = 0;
  return StatefulBuilder(
    builder: (BuildContext context, setState) {
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25), color: Colors.grey[900]),
        height: MediaQuery.of(context).size.height / 2.5,
        width: 450,
        child: PageView.builder(
            itemCount: buildDotLen,
            onPageChanged: (int index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (_, i) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 35),
                child: _contents(currentIndex, buildDotLen)[i],
              );
            }),
      );
    },
  );
}

List<Widget> _contents(int currIdx, int buildDotLen) {
  HexColor hexcolor = HexColor();
  return [
    // ---------------------------------------------------------------- THIS IS DOT  1 --- WHAT IS KF
    Column(
      children: [
        Text(
          " Chat with the bros and sis in Christ \n"
          " Create polls, ask questions, share post, \n"
          " make events and control your community with roles!",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 25),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                buildDotLen, (index) => buildDot(index, currIdx, hexcolor)),
          ),
        ),
        SizedBox(height: 15),
       Text("Swipe -->", style: TextStyle(color: Color(hexcolor.hexcolorCode('#FFC050'))),)
      ],
    ),

    // --------------------------------> child 2 ------------------------------- ---------- THIS IS DOT 2 ---- MAIN FUNCTIONALITY OF KF HOW TO
    Column(
      children: [
        Text(
          " Tap The Bottom Left Search To Join A Community! \n",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Container(
            height: 35,
            width: 35,
            child: RiveAnimation.asset('assets/icons/search_icon.riv')),
        SizedBox(height: 25),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                buildDotLen, (index) => buildDot(index, currIdx, hexcolor)),
          ),
        ),
        SizedBox(height: 15),
        Text("Swipe -->", style: TextStyle(color: Color(hexcolor.hexcolorCode('#FFC050'))),)
      ],
    ),

    // ----------------------------------------------> child 3 ------------------------------------------- how to make a Community or chat

    Column(
      children: [
        Text(
          " Or Tap The Bottom Center Add To Create A Community! \n",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Container(
            height: 35,
            width: 35,
            child: RiveAnimation.asset('assets/icons/add_icon.riv')),
        SizedBox(height: 25),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                buildDotLen, (index) => buildDot(index, currIdx, hexcolor)),
          ),
        ),
        SizedBox(height: 15),
        Text("Swipe -->", style: TextStyle(color: Color(hexcolor.hexcolorCode('#FFC050'))),)
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
        SizedBox(height: 25),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                buildDotLen, (index) => buildDot(index, currIdx, hexcolor)),
          ),
        ),
        SizedBox(height: 15),
        Text("You Are Loved :)", style: TextStyle(color: Color(hexcolor.hexcolorCode('#FFC050'))),)
      ],
    )
  ];
}

Container buildDot(int index, int currIdx, HexColor hexcolor) {
  return Container(
    height: 10,
    width: currIdx == index ? 18 : 10,
    margin: EdgeInsets.only(right: 5),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Color(hexcolor.hexcolorCode('#FFC050'))),
  );
}
