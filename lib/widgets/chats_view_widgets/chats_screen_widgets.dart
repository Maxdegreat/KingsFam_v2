import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/extensions/hexcolor.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/church/church_repository.dart';
import 'package:kingsfam/widgets/widgets.dart';
import 'package:kingsfam/extensions/extensions.dart';

Future<dynamic> leaveCommuinity(
    {required Church commuinity, required BuildContext context, required userId}) {
  return showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text("Leave ${commuinity.name}???"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("NOOO", style: TextStyle(color: Colors.white))),
              TextButton(
                  onPressed: () async {
                    //to get out of a commuinity you will have to update the commuinity orrr delete certian criteria
                    await context.read<ChurchRepository>().leaveCommuinity(
                        commuinity: commuinity,
                        leavingUserId: context.read<AuthBloc>().state.user!.uid);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Did I Stutter???",
                    style: TextStyle(color: Colors.red),
                  ))
            ],
          ));
}

Widget KFStarAmination(BuildContext context) {
  // instance of hexcolor class
  HexColor hexcolor = HexColor();
  return Column(
    children: [
      Container(
          height: 400,
          width: 400,
          child: Text("...")),
      Center(
          child: Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: Color(hexcolor.hexcolorCode('#FFC050'))),
          onPressed: () => helpDialog(context),
          child: Text("Hey Fam, Need Help?"),
        ),
      )),
    ],
  );
}

Widget buildChat({BuildContext? context, Chat? chat, String? userId}) {
  
  if (chat == null) return SizedBox.shrink();
  bool unread = chat.readStatus[context!.read<AuthBloc>().state.user!.uid] == false;
  Timestamp chatTimestamp = chat.recentMessage['timestamp'];
  var chatTimestampStr = chatTimestamp.timeAgo();
  return Container(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 10),
        ProfileImage(
            radius: 37, pfpUrl: chat.imageUrl != null ? chat.imageUrl! : ''),
        SizedBox(
          height: 7,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            !unread ? SizedBox.shrink() :
            CircleAvatar(
              radius: 3,
              backgroundColor: unread ? Colors.amber : Colors.transparent,
            ), SizedBox(width: 3),
            Text(
              chat.chatName,
              style: Theme.of(context).textTheme.bodyText1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        SizedBox(
          height: 3,
        ),
        // Text(
        //     '${chat.recentMessage['recentSender']} => ${chat.recentMessage['recentMessage']}'),
        // SizedBox(
        //   height: 3,
        //),
        Text(chatTimestampStr)
      ],
    ),
  );
}
    // Container(
    //   height: 20,
    //   decoration: BoxDecoration(
    //       color: Colors.grey[800], borderRadius: BorderRadius.circular(10)),
    //   child: Padding(
    //     padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
    //     child: Column(
    //       mainAxisSize: MainAxisSize.max,
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         chat!.imageUrl != null ? ChatImage(chatUrl: chat.imageUrl!) : Icon(Icons.cabin),
    //         SizedBox(height: 5),
    //         Center(
    //           child: Text(
    //             chat.chatName,
    //             style: Theme.of(context!).textTheme.bodyText1,
    //             overflow: TextOverflow.ellipsis,
    //           ),
    //         ),
    //         SizedBox(height: 15),
    //         Center(
    //             child:
    //                 Text('${chat.recentMessage['recentSenderUsername']}')),
    //         Center(
    //             child: //Text("${chat.date.timeAgo()}"),
    //                 Text("chats screen"))
    //       ],
    //     ),
    //   ),
    // );
  