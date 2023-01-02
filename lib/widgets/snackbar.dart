import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/config/constants.dart';
import 'package:kingsfam/enums/bottom_nav_items.dart';
import 'package:kingsfam/helpers/firebase_notifs.dart';
import 'package:kingsfam/screens/nav/cubit/bottomnavbar_cubit.dart';

notifSnackBar({
  required RemoteMessage remoteMessage,
  required BuildContext context,
}) {
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: Theme.of(context).colorScheme.secondary,
    duration: Duration(seconds: 4),
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.only(
      bottom: 30,
      left: 10,
      right: 10,
    ),
    content: GestureDetector(
      onTap: () {
        handleMessage(remoteMessage, context);
        context
            .read<BottomnavbarCubit>()
            .updateSelectedItem(BottomNavItem.chats);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          remoteMessage.notification!.title!,
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
    ),
  ));
}

snackBar(
    {required String snackMessage,
    required BuildContext context,
    Color? bgColor,
    VoidCallback? callBack = null}) {
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: GestureDetector(
        onTap: callBack, child: Expanded(child: Text(snackMessage, style: Theme.of(context).textTheme.caption,))),
    backgroundColor: bgColor?? Colors.black,
    duration: Duration(seconds: 3),
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.only(bottom: 30, left: 10, right: 10),
  ));
}
