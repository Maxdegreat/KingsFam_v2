import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/extensions/hexcolor.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/church/church_repository.dart';
import 'package:kingsfam/screens/chat_room/chat_room.dart';
import 'package:kingsfam/widgets/widgets.dart';
import 'package:rive/rive.dart';

Future<dynamic> leaveCommuinity(
      {required Church commuinity, required BuildContext context}) {
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
                          currId: context.read<AuthBloc>().state.user!.uid);
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
            child: RiveAnimation.asset('assets/crown/KFCrown.riv')),
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
    return Container(
      height: 20,
      decoration: BoxDecoration(
          color: Colors.grey[800], borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChatImage(chatUrl: chat!.imageUrl),
            SizedBox(height: 5),
            Center(
              child: Text(
                chat.name,
                style: Theme.of(context!).textTheme.bodyText1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 15),
            Center(
                child:
                    Text('${chat.memberInfo[chat.recentSender]['username']}')),
            Center(
                child: //Text("${chat.date.timeAgo()}"),
                    Text("chats screen"))
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> chats_view(String userId) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(Paths.chats)
            .where('memberIds', arrayContains: userId)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot1) {
          if (!snapshot1.hasData) {
            return Center(child: Text('waiting for simpels img'));
          } else if (snapshot1.data!.docs.length <= 0) {
            return Center(child: Text('Join some chats!'));
          } else {
            return Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Expanded(
                      flex: 1,
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisSpacing: 20.0,
                          crossAxisSpacing: 20.0,
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                        ),
                        itemBuilder: (context, index) {
                          Chat chat = Chat.fromDoc(snapshot1.data!.docs[index]);
                          return GestureDetector(
                            onTap: () => Navigator.of(context).pushNamed(
                                ChatRoom.routeName,
                                arguments: ChatRoomArgs(chat: chat)),
                            child: buildChat(
                                chat: chat, context: context, userId: userId),
                          );
                        },
                        itemCount: snapshot1.data!.docs.length,
                      ),
                    )
                  ],
                ));
          }
        });
  }