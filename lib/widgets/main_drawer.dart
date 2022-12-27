import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kingsfam/config/constants.dart';
import 'package:kingsfam/models/church_model.dart';
import 'package:kingsfam/screens/chats/bloc/chatscreen_bloc.dart';
import 'package:kingsfam/widgets/roundContainerWithImgUrl.dart';
import 'package:kingsfam/widgets/widgets.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  @override
  Widget build(BuildContext context) {
    Widget start = Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "Communities",
          style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 25),
        ));

    List<Widget> drawerLst = context.read<ChatscreenBloc>().state.chs!.map((c) {
      setState(() {});
      if (c == null) return SizedBox.shrink();
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
          child: ListTile(
            contentPadding: EdgeInsets.only(left: 0),
            leading:
                ContainerWithURLImg(imgUrl: c.imageUrl, height: 70, width: 90),
            title: Text(c.name,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(fontSize: 24, fontStyle: FontStyle.italic)),
            onTap: () {
              log("attempting to move to the next cm");
              log(context.read<ChatscreenBloc>().state.selectedCh.toString());
              if (c != context.read<ChatscreenBloc>().state.selectedCh) {
                context.read<ChatscreenBloc>()
                  ..add(ChatScreenUpdateSelectedCm(cm: c));
                Navigator.of(context).pop();
              }
            },
          ));
    }).toList();

    drawerLst.insert(0, start);

    for (var c in context.read<ChatscreenBloc>().state.chs!) {
      log("in the barage idk");
      if (!context.read<ChatscreenBloc>().state.chs!.contains(c)) {
        if (c != start) {
          drawerLst.remove(c);
          setState(() {});
        }
      }
    }

    return SafeArea(
      child: Drawer(
        backgroundColor: Theme.of(context).drawerTheme.backgroundColor,
        width: MediaQuery.of(context).size.width - 45,
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          children: drawerLst,
        ),
      ),
    );
  }
}

// Widget MainDrawer(BuildContext context, ChatscreenBloc? chatScreenBloc) {

  

//   return SafeArea(
//     child: Drawer(

//   );
// }
