import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/extensions/hexcolor.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/extensions/extensions.dart';
import 'package:kingsfam/screens/commuinity/screens/kings%20cord/cubit/kingscord_cubit.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/widgets/widgets.dart';
import 'package:bloc/bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageLines extends StatelessWidget {
  //class data
  final String? previousSenderAsUid;
  final Message message;
  final String kcId;
  final String cmId;
  final BuildContext inhearatedCtx;

  MessageLines({required this.message, required this.cmId, required this.kcId, this.previousSenderAsUid, required  this.inhearatedCtx});

  showLinkPicker(List<String> links, BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            child: Column(
              children: links
                  .map((e) => ListTile(
                        leading: Text(
                          e,
                          style: TextStyle(fontSize: 17, color: Colors.white),
                        ),
                        onTap: () async => await launch(e),
                      ))
                  .toList(),
            ),
          );
        });
  }

  uploadReaction(String reaction, String msgId, Map<String, int> reactions) {
    int? incrementedReaction = reactions[reaction];
    if (incrementedReaction == null) {
      incrementedReaction = 1;
    } else {
      incrementedReaction += 1;
    }
    reactions[reaction] = incrementedReaction;
    FirebaseFirestore.instance
        .collection(Paths.church)
        .doc(cmId)
        .collection(Paths.kingsCord)
        .doc(kcId)
        .collection(Paths.messages)
        .doc(msgId)
        .update({'reactions': reactions});
  }

  Container reactionContainer({required String reaction, required int num}) {
    return Container(
      height: 30,
      child: Center(
          child: RichText(
        text: TextSpan(
            text: reaction,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                  text: '\t$num',
                  style: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.bold))
            ]),
      )),
      decoration: BoxDecoration(
          color: Colors.white24,
          border: Border.all(color: Colors.red[800]!, width: 2),
          borderRadius: BorderRadius.circular(5)),
    );
  }

  _showReactionBarUi({required Map<String, int>? messageReactions}) {
    return message.reactions == {} || messageReactions == {'': 0}
        ? SizedBox.shrink()
        : Container(
            height: 30,
            child: Row(
                children: messageReactions!.keys.map((e) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 7.0),
                child:
                    reactionContainer(reaction: e, num: message.reactions![e]!),
              );
            }).toList()),
          );
  }

  _showReactionsBar(String messageId, Map<String, int>? messageReactions,
      BuildContext context) {
    if (messageReactions == null) {
      messageReactions = {};
    }

    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                          onTap: () {
                            uploadReaction('💖', messageId, messageReactions!);
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            '💖',
                            style: TextStyle(fontSize: 27),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                          onTap: () {
                            uploadReaction('😁', messageId, messageReactions!);
                            Navigator.of(context).pop();
                          },
                          child: Text('😁', style: TextStyle(fontSize: 27))),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                          onTap: () {
                            uploadReaction('😭', messageId, messageReactions!);
                            Navigator.of(context).pop();
                          },
                          child: Text('😭', style: TextStyle(fontSize: 27))),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                          onTap: () {
                            uploadReaction('👀', messageId, messageReactions!);
                            Navigator.of(context).pop();
                          },
                          child: Text('👀', style: TextStyle(fontSize: 27))),
                    ),
                  ],
                ),
                SizedBox(height: 7),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    //  GestureDetector(
                    //    onTap: () {
                    //     // tell ui that this is a replyed message
                    //       log("the inhearatedCtx is not null");
                    //       inhearatedCtx.read<KingscordCubit>().onReplyMessage(replyingToMessage: message,);
                    //       Navigator.of(context).pop();
                    //     // add the og msg sender id in data / payload on onbackend
                        
                    //     // send a notification to to og sender onbackend

                    //    },
                    //    child: Container(
                    //      child: Text("Reply", style: Theme.of(context).textTheme.bodyMedium),
                    //    ),
                    //  ),
                    //  SizedBox(width: 5,),
                      GestureDetector(
                        onTap: () {
                          if (message.sender!.id == context.read<AuthBloc>().state.user!.uid) {
                            if (message.text != null && message.text == "(code:unsent 10987345)") {
                              snackBar(snackMessage: "You can\'t del this fam", context: context, bgColor: Colors.red[400]!);
                            } else {
                              Message messageForDel = message.copyWith(text: "(code:unsent 10987345)", imageUrl: null, mentionedIds: null, thumbnailUrl: null, videoUrl: null,);
                          FirebaseFirestore.instance.collection(Paths.church).doc(this.cmId).collection(Paths.kingsCord).doc(this.kcId).collection(Paths.messages).doc(this.message.id).update(messageForDel.ToDoc(senderId: message.sender!.id));
                            }
                        } else
                          snackBar(snackMessage: "hmm, can't del a message that is not yours fam", context: context, bgColor: Colors.red[400]!);
                        },
                        child: Container(
                          child: Text("Unsend", style: Theme.of(context).textTheme.bodyMedium),
                        ),
                      ),
                  ],
                ),
                
              ],
            ),
          );
        });
  }

   _showReplyBarUi(String? reply) {
    return reply != null ? Container(
      height: 25,
      width: double.infinity,
      child: Text(reply, style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15)),
      decoration: BoxDecoration(
        color: Color.fromARGB(120, 255, 145, 0)
      ),
    ) : SizedBox.shrink();
  }
  // if i send the message.
  _buildText(BuildContext context) {
    if (message.reactions == {}) {
      message.reactions![''] = 0;
    }
    List<String> links = [];
    var msgAsList = message.text!.split(' ').forEach((element) {
      if (element.startsWith('https://') || element.startsWith('Https://')) {
        links.add(element);
      } 
    });

    if (message.text == "(code:unsent 10987345)") {
        return Text("deleted", style: TextStyle(
                    color: Colors.grey,
                    fontSize: 17.0,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w800, ));
      }

    return GestureDetector(
      onTap: () {
        if (links.isNotEmpty) {
          return showLinkPicker(links, context);
        }
      },
      onLongPress: () =>
          _showReactionsBar(message.id!, message.reactions!, context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _showReplyBarUi(message.replyed),
          Padding(
            padding: const EdgeInsets.only(left: 7),
            child: Text(message.text!,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17.0,
                    fontWeight: FontWeight.w800)),
          ),
          _showReactionBarUi(messageReactions: message.reactions)
        ],
      ),
    );

    //lineGen.parsedStringToFormatedForMessageGenerator(fuleAsString: message.text);
    //  return Padding(
    //  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
    //  child: RichText(
    //  textAlign: TextAlign.start,
    //  text: TextSpan(
    //  children: lineGen.children
    //  )));
  }

  //for an image
  _buildImage(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onLongPress: () =>
              _showReactionsBar(message.id!, message.reactions, context),
          onTap: () => Navigator.of(context).pushNamed(UrlViewScreen.routeName,
              arguments: UrlViewArgs(
                  urlImg: message.imageUrl!,
                  heroTag: 'Message/${message.imageUrl}/')),
          child: Container(
            height: size.height * 0.2,
            width: size.width * 0.6,
            decoration: BoxDecoration(
                border: Border.all(
                    width: 2.0,
                    color: const Color(
                        0xFFFFFFFF)), // Color(hexcolor.hexcolorCode(message.sender!.colorPref))
                borderRadius: BorderRadius.circular(20.0),
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(message.imageUrl!))),
          ),
        ),
        _showReactionBarUi(messageReactions: message.reactions)
      ],
    );
  }

  _buildVideo(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                onLongPress: () =>
                    _showReactionsBar(message.id!, message.reactions, context),
                onTap: () => Navigator.of(context).pushNamed(
                    UrlViewScreen.routeName,
                    arguments: UrlViewArgs(
                        urlVid: message.videoUrl!,
                        urlImg: message.thumbnailUrl!,
                        heroTag:
                            'Message/${message.videoUrl}/${message.thumbnailUrl}')),
                child: Container(
                  child: Icon(
                    Icons.play_arrow,
                    size: 35,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
            ],
          ),
          height: size.height * 0.2,
          width: size.width * 0.6,
          decoration: BoxDecoration(
              border: Border.all(
                  width: 2.0,
                  color: const Color(
                      0xFFFFFFFF)), // Color(hexcolor.hexcolorCode(message.sender!.colorPref))
              borderRadius: BorderRadius.circular(20.0),
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(message.thumbnailUrl!))),
        ),
        _showReactionBarUi(messageReactions: message.reactions)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // final bool isMe =
    //     context.read<AuthBloc>().state.user!.uid == message.senderId;

    // this is for the hex color
    HexColor hexcolor = HexColor();
    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // a row displaying imageurl of member and name
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                //FancyListTile(username: '${kingsCordMemInfo.memberInfo[message.senderId]['username']}', imageUrl: '${kingsCordMemInfo.memberInfo[message.senderId]['profileImageUrl']}', onTap: null, isBtn: false, BR: 18, height: 18, width: 18),
                previousSenderAsUid == message.sender!.id ? SizedBox.shrink() :kingsCordAvtar(context),
                SizedBox(
                  width: 5.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.sender!.username,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: message.sender!.colorPref == ""
                              ? Colors.red
                              : Color(hexcolor
                                  .hexcolorCode(message.sender!.colorPref))),
                    ),
                    Text(
                      '${message.date.timeAgo()}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    )
                  ],
                )
              ],
            ),
            SizedBox(height: 5.0),
            Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                child: message.text != null
                    ? _buildText(context)
                    : message.videoUrl != null && message.thumbnailUrl != null
                        ? _buildVideo(context)
                        : _buildImage(context)),
          ],
        ));
  }

  Widget kingsCordAvtar(BuildContext context) {
    HexColor hexcolor = HexColor();
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height / 18.5,
      width: size.width / 8,
      child: message.sender!.profileImageUrl != "null"
          ? kingsCordProfileImg()
          : kingsCordProfileIcon(),
      decoration: BoxDecoration(
         border: Border.all(
             width: 2,
             color: message.sender!.colorPref == ""
                 ? Colors.red
                 : Color(hexcolor.hexcolorCode(message.sender!.colorPref))),
          color: message.sender!.colorPref == ""
              ? Colors.red
              : Color(hexcolor.hexcolorCode(message.sender!.colorPref)),
         shape: BoxShape.circle),
    );
  }

  Widget? kingsCordProfileImg() => CircleAvatar(
      backgroundColor: Colors.grey[400],
      backgroundImage:
          CachedNetworkImageProvider(message.sender!.profileImageUrl),radius: 8,);
  Widget? kingsCordProfileIcon() =>
      Container(child: Icon(Icons.account_circle));
}
