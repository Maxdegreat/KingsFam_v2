
import 'package:flutter/material.dart';
import 'package:kingsfam/models/church_model.dart';
import 'package:kingsfam/screens/chats/bloc/chatscreen_bloc.dart';
import 'package:kingsfam/widgets/widgets.dart';

Widget MainDrawer(List<Church?>? cmStream, BuildContext ctx) {

  List<Widget> initDL = [Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text("Communities", style: Theme.of(ctx).textTheme.bodyText1!.copyWith(fontSize: 25),
  ))];

  List<Widget> drawerLst = cmStream == null ? [] : cmStream.map((c) {
                if (c == null) return SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.only(left: 0),
                    leading: ProfileImage(radius: 45, pfpUrl: c.imageUrl),
                    title: Text(c.name, style: Theme.of(ctx).textTheme.bodyText1!.copyWith(fontSize: 24)),
                    onTap: () {
                      // ctx.read<ChatscreenBloc>().
                    },
                  
                  )
                );
              }).toList();
  
  List<Widget> lst = List.from(initDL)..addAll(drawerLst); 

  return SafeArea(
    child: Drawer(
      width: MediaQuery.of(ctx).size.width - 45,
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        children: lst,
      ),
    ),
  );
}
