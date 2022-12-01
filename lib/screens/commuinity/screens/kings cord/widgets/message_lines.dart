import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/extensions/hexcolor.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/extensions/extensions.dart';
import 'package:kingsfam/screens/commuinity/screens/kings%20cord/cubit/kingscord_cubit.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/widgets/link_preview_container.dart';
import 'package:kingsfam/widgets/widgets.dart';
import 'package:bloc/bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageLines extends StatefulWidget {
  //class data
  final String? previousSenderAsUid;
  final Message message;
  final String kcId;
  final String cmId;
  final BuildContext inhearatedCtx;

  MessageLines(
      {required this.message,
      required this.cmId,
      required this.kcId,
      this.previousSenderAsUid,
      required this.inhearatedCtx});

  @override
  State<MessageLines> createState() => _MessageLinesState();
}

class _MessageLinesState extends State<MessageLines> {
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
        .doc(widget.cmId)
        .collection(Paths.kingsCord)
        .doc(widget.kcId)
        .collection(Paths.messages)
        .doc(msgId)
        .update({'reactions': reactions});
  }

  Container reactionContainer({required String reaction, required int num}) {
    return Container(
       height: MediaQuery.of(context).size.height / 20,
      width: MediaQuery.of(context).size.width / 8,
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
          color: Color.fromARGB(110, 255, 193, 7),
          border: Border.all(color: Colors.amber, width: 2),
          borderRadius: BorderRadius.circular(5)),
    );
  }

  _showReactionBarUi({required Map<String, int>? messageReactions}) {
    return widget.message.reactions == {} || messageReactions == {'': 0}
        ? SizedBox.shrink()
        : Container(
            height: MediaQuery.of(context).size.height / 20,
            child: Row(
                children: messageReactions!.keys.map((e) {
              return Padding(
                padding:
                    const EdgeInsets.only(top: 5.0, bottom: 5.0, right: 7 ),
                child: reactionContainer(
                    reaction: e, num: widget.message.reactions![e]!),
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
                        if (widget.message.sender!.id ==
                            context.read<AuthBloc>().state.user!.uid) {
                          if (widget.message.text != null &&
                              widget.message.text == "(code:unsent 10987345)") {
                            snackBar(
                                snackMessage: "You can\'t del this fam",
                                context: context,
                                bgColor: Colors.red[400]!);
                          } else {
                            Message messageForDel = widget.message.copyWith(
                              text: "(code:unsent 10987345)",
                              imageUrl: null,
                              mentionedIds: null,
                              thumbnailUrl: null,
                              videoUrl: null,
                            );
                            FirebaseFirestore.instance
                                .collection(Paths.church)
                                .doc(this.widget.cmId)
                                .collection(Paths.kingsCord)
                                .doc(this.widget.kcId)
                                .collection(Paths.messages)
                                .doc(this.widget.message.id)
                                .update(messageForDel.ToDoc(
                                    senderId: widget.message.sender!.id));
                          }
                        } else
                          snackBar(
                              snackMessage:
                                  "hmm, can't del a message that is not yours fam",
                              context: context,
                              bgColor: Colors.red[400]!);
                      },
                      child: Container(
                        child: Text("Unsend",
                            style: Theme.of(context).textTheme.bodyMedium),
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
    return reply != null
        ? Container(
            height: 25,
            width: double.infinity,
            child: Text(reply,
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15)),
            decoration: BoxDecoration(color: Color.fromARGB(120, 255, 145, 0)),
          )
        : SizedBox.shrink();
  }

  // if i send the message.
  _buildText(BuildContext context) {
    if (widget.message.reactions == {}) {
      widget.message.reactions![''] = 0;
    }
    List<String> links = [];
    List<Widget> textWithLinksForColumn = [];
    String tempString = "";
    // checking for strings starting with https:// I do this w/ regex
    widget.message.text!.split(RegExp("\\s")).forEach((element) {
      if (!element.startsWith('https://')) {
        if (textWithLinksForColumn.isEmpty && tempString.isEmpty) {
          tempString += element;
        } else {
          tempString += " $element ";
        }
      } else if (element.startsWith('https://')) {
        textWithLinksForColumn.add(Text(
          tempString,
          style: TextStyle(
              color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.w800),
        ));
        tempString = "";
        // add the element to the links so that the code knows visually there is a link in a show link preview
        links.add(element);
        // make a textbutton so that indivdual links can be taped on

        Widget l = GestureDetector(
          onTap: () {
            launch(element);
          },
          child: Text(element,
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .merge(TextStyle(color: Colors.blue))),
        );
        // add the links to the list below so that the code can later use these txtbuttons w/ links as child
        textWithLinksForColumn.add(l);
      }
    });

    // The return of the build text when there is an unsent message
    if (widget.message.text == "(code:unsent 10987345)") {
      return Text("deleted",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14.0,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w800,
          ));
    }

    if (links.isNotEmpty) {
      // the return of the build text when the links are not empty
      return GestureDetector(
          onLongPress: () => _showReactionsBar(
              widget.message.id!, widget.message.reactions, context),
          onTap: () {
            if (links.length == 1) {
              launch(links[0]);
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinkPreviewContainer(link: links.last),
              SizedBox(height: 2),
              // if a link was sent only without any text
              // widget.message.text!.trim().length != links[0].trim().length ? Text(widget.message.text!) : Text("#weblink")
              Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: textWithLinksForColumn.map((e) => e).toList())
            ],
          ));
    }
    // the return of the text when there is no links involved
    return GestureDetector(
      onLongPress: () => _showReactionsBar(
          widget.message.id!, widget.message.reactions, context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _showReplyBarUi(widget.message.replyed),
          Text(widget.message.text!,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w800)),
          _showReactionBarUi(messageReactions: widget.message.reactions)
        ],
      ),
    );
  }

  //for an image
  _buildImage(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onLongPress: () => _showReactionsBar(
              widget.message.id!, widget.message.reactions, context),
          onTap: () => Navigator.of(context).pushNamed(UrlViewScreen.routeName,
              arguments: UrlViewArgs(
                  urlImg: widget.message.imageUrl!,
                  heroTag: 'Message/${widget.message.imageUrl}/')),
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
                    image:
                        CachedNetworkImageProvider(widget.message.imageUrl!))),
          ),
        ),
        _showReactionBarUi(messageReactions: widget.message.reactions)
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
                onLongPress: () => _showReactionsBar(
                    widget.message.id!, widget.message.reactions, context),
                onTap: () => Navigator.of(context).pushNamed(
                    UrlViewScreen.routeName,
                    arguments: UrlViewArgs(
                        urlVid: widget.message.videoUrl!,
                        urlImg: widget.message.thumbnailUrl!,
                        heroTag:
                            'Message/${widget.message.videoUrl}/${widget.message.thumbnailUrl}')),
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
                  image: CachedNetworkImageProvider(
                      widget.message.thumbnailUrl!))),
        ),
        _showReactionBarUi(messageReactions: widget.message.reactions)
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //FancyListTile(username: '${kingsCordMemInfo.memberInfo[message.senderId]['username']}', imageUrl: '${kingsCordMemInfo.memberInfo[message.senderId]['profileImageUrl']}', onTap: null, isBtn: false, BR: 18, height: 18, width: 18),
                // widget.previousSenderAsUid == widget.message.sender!.id
                //     ? SizedBox.shrink()
                //     : 
                kingsCordAvtar(context),
                SizedBox(
                  width: 5.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.message.sender!.username,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: widget.message.sender!.colorPref == ""
                                  ? Colors.red
                                  : Color(hexcolor.hexcolorCode(
                                      widget.message.sender!.colorPref))),
                        ),
                        SizedBox(width: 2),
                         Text(
                      '${widget.message.date.timeAgo()}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic
                      ),
                    ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width / 1.4,
                        ),
                        child: widget.message.text != null
                            ? _buildText(context)
                            : widget.message.videoUrl != null &&
                                    widget.message.thumbnailUrl != null
                                ? _buildVideo(context)
                                : _buildImage(context)),
                  ],
                )
              ],
            ),
          ],
        ));
  }

  Widget kingsCordAvtar(
    BuildContext context,
  ) {
    HexColor hexcolor = HexColor();
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height / 18.5,
      width: size.width / 8,
      child: widget.message.sender!.profileImageUrl != "null"
          ? kingsCordProfileImg()
          : kingsCordProfileIcon(),
      decoration: BoxDecoration(
          border: Border.all(
              width: 2,
              color: widget.message.sender!.colorPref == ""
                  ? Colors.red
                  : Color(
                      hexcolor.hexcolorCode(widget.message.sender!.colorPref))),
          color: widget.message.sender!.colorPref == ""
              ? Colors.red
              : Color(hexcolor.hexcolorCode(widget.message.sender!.colorPref)),
          shape: BoxShape.circle),
    );
  }

  Widget? kingsCordProfileImg() => CircleAvatar(
        backgroundColor: Colors.grey[400],
        backgroundImage:
            CachedNetworkImageProvider(widget.message.sender!.profileImageUrl),
        radius: 8,
      );

  Widget? kingsCordProfileIcon() =>
      Container(child: Icon(Icons.account_circle));
}
