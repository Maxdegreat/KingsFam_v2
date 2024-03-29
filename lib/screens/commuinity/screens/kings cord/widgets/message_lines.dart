// ignore_for_file: unnecessary_null_comparison

import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/constants.dart';
import 'package:kingsfam/config/mode.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/cubits/buid_cubit/buid_cubit.dart';
import 'package:kingsfam/extensions/hexcolor.dart';
import 'package:kingsfam/helpers/clipboard.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/extensions/extensions.dart';
import 'package:kingsfam/screens/commuinity/screens/kings%20cord/cubit/kingscord_cubit.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/widgets/giphy/giphy_widget.dart';
import 'package:kingsfam/widgets/hide_content/hide_content_full_screen_post.dart';
import 'package:kingsfam/widgets/link_preview_container.dart';
import 'package:kingsfam/widgets/roundContainerWithImgUrl.dart';
import 'package:kingsfam/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageLines extends StatefulWidget {
  //class data
  final String? previousSenderAsUid;
  final Message message;
  final KingsCord kc;
  final Church cm;
  final BuildContext inhearatedCtx;
  final KingscordCubit? kcubit;

  MessageLines(
      {required this.message,
      required this.cm,
      required this.kc,
      this.previousSenderAsUid,
      required this.inhearatedCtx,
      required this.kcubit});

  @override
  State<MessageLines> createState() => _MessageLinesState();
}

class _MessageLinesState extends State<MessageLines> {
  late String msgBodyForReply;

  @override
  void initState() {
    super.initState();
    msgBodyForReply = widget.message.text != null
        ? widget.message.text!
        : " Shared something";
  }

  uploadReaction(String reaction, String msgId, Map<String, dynamic> reactions,
      Map<String, dynamic> metadata) {
    int? incrementedReaction = reactions[reaction];
    if (incrementedReaction == null) {
      incrementedReaction = 1;
    } else {
      incrementedReaction += 1;
    }
    reactions[reaction] = incrementedReaction;
    metadata['reactions'] = reactions;
    FirebaseFirestore.instance
        .collection(Paths.church)
        .doc(widget.cm.id!)
        .collection(Paths.kingsCord)
        .doc(widget.kc.id!)
        .collection(Paths.messages)
        .doc(msgId)
        .update({'metadata': metadata});
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

  _showReactionBarUi({required Map<String, dynamic>? messageReactions}) {
    Map<String, dynamic> reactions = {};
    if (widget.message.metadata!.containsKey("reactions"))
      reactions = widget.message.metadata!['reactions'];
    if (!(reactions.length > 0)) {
      return SizedBox.shrink();
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          height: MediaQuery.of(context).size.height / 20,
          child: Row(
              children: reactions.keys.map((e) {
            return Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 5.0, right: 7),
              child: reactionContainer(reaction: e, num: reactions[e]!),
            );
          }).toList()),
        ),
      );
    }
  }

  _showReactionsBar(String messageId, Map<String, dynamic>? messageReactions,
      BuildContext context, Map<String, dynamic> metadata) {
    if (messageReactions == null) {
      messageReactions = {};
    }

    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 8, right: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 3),
                Icon(Icons.drag_handle),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                          onTap: () {
                            uploadReaction(
                                '💖', messageId, messageReactions!, metadata);
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
                            uploadReaction(
                                '😁', messageId, messageReactions!, metadata);
                            Navigator.of(context).pop();
                          },
                          child: Text('😁', style: TextStyle(fontSize: 27))),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                          onTap: () {
                            uploadReaction(
                                '😭', messageId, messageReactions!, metadata);
                            Navigator.of(context).pop();
                          },
                          child: Text('😭', style: TextStyle(fontSize: 27))),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                          onTap: () {
                            uploadReaction(
                                '😎', messageId, messageReactions!, metadata);
                            Navigator.of(context).pop();
                          },
                          child: Text('😎', style: TextStyle(fontSize: 27))),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                          onTap: () {
                            uploadReaction(
                                '👀', messageId, messageReactions!, metadata);
                            Navigator.of(context).pop();
                          },
                          child: Text('👀', style: TextStyle(fontSize: 27))),
                    ),
                  ],
                ),
                SizedBox(height: 7),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 7),
                    ListTile(
                        leading: Icon(Icons.reply),
                        title: Text("Reply",
                            style: Theme.of(context).textTheme.bodyText1),
                        onTap: () {
                          kcubit!.addReply(widget.message);
                          Navigator.of(context).pop();
                        }),
                    ListTile(
                      leading: Icon(Icons.copy),
                      title: Text("Copy",
                          style: Theme.of(context).textTheme.bodyText1),
                      onTap: () {
                        if (widget.message.text != null) {
                          copyTextToClip(widget.message.text!);
                        } else {
                          snackBar(
                              snackMessage: "can not copy", context: context);
                        }
                      },
                    ),
                    if (context.read<AuthBloc>().state.user!.uid ==
                        widget.message.sender!.id) ...[
                      ListTile(
                        leading: Icon(Icons.delete),
                        title: Text("Unsend",
                            style: Theme.of(context).textTheme.bodyText1),
                        onTap: () {
                          FirebaseFirestore.instance
                              .collection(Paths.church)
                              .doc(this.widget.cm.id!)
                              .collection(Paths.kingsCord)
                              .doc(this.widget.kc.id!)
                              .collection(Paths.messages)
                              .doc(this.widget.message.id)
                              .delete();
                          Navigator.of(context).pop();
                        },
                      ),
                    ] else ...[
                      ListTile(
                          leading: Icon(
                            Icons.report,
                            color: Colors.redAccent,
                          ),
                          title: Text(
                            "Report this message",
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(color: Colors.redAccent),
                          ),
                          onTap: () {
                            Map<String, dynamic> info = {
                              "userId": widget.message.sender!.id,
                              "what": "message",
                              "continue": FirebaseFirestore.instance
                                  .collection(Paths.church)
                                  .doc(widget.cm.id)
                                  .collection(Paths.kingsCord)
                                  .doc(widget.kc.id)
                                  .collection(Paths.messages)
                                  .doc(widget.message.id),
                            };
                            Navigator.of(context).pushNamed(
                                ReportContentScreen.routeName,
                                arguments: RepoetContentScreenArgs(info: info));
                          }),
                      ListTile(
                          leading: Icon(
                            Icons.block,
                            color: Colors.redAccent,
                          ),
                          title: Text(
                            "Block " + widget.message.sender!.username,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(color: Colors.redAccent),
                          ),
                          onTap: () {
                            context
                                .read<BuidCubit>()
                                .onBlockUser(widget.message.sender!.id);
                            snackBar(
                                snackMessage: widget.message.sender!.username +
                                    "is blocked",
                                context: context);
                            Navigator.of(context).pop();
                          }),
                    ],
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

  final urlRegExp = RegExp(
    r'(?:^|[^\w])(https?://\S+)(?:$|[^\w])',
    caseSensitive: false,
  );

  // if i send the message.
  _buildText(BuildContext context) {
    if (widget.message.metadata!['reactions'] == {}) {
      widget.message.metadata!['reactions']![''] = 0;
    }

    final lines = widget.message.text!.split('\n');
    final widgets = <Widget>[];
    bool hasLinkPreview = false;

    for (final line in lines) {
      final spans = <InlineSpan>[];
      Widget? linkPreview;
      final words = line.split(' ');

      for (final word in words) {
        if (word.startsWith('https://') &&
            !hasLinkPreview &&
            widget.message.metadata!["linkP"] != null) {
          // log("LinkP: ${widget.message.metadata!["linkP"]}");
          linkPreview = LinkPreviewContainer(
              linkP: widget.message.metadata!["linkP"],
              color: Color(hc.hexcolorCode(widget.message.sender!.colorPref)));
          hasLinkPreview = true;
        }

        if (word.startsWith('https://')) {
          final launchUrl = GestureDetector(
            onTap: () => launch(word),
            child: Text(word,
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: Colors.blueAccent)),
          );
          spans.add(WidgetSpan(child: launchUrl));
        } else {
          spans.add(TextSpan(
              text: word,
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(fontWeight: FontWeight.w500, fontSize: 15)));
        }

        spans.add(TextSpan(text: " "));
      }
      widgets.add(RichText(text: TextSpan(children: spans)));
      if (linkPreview != null) {
        widgets.insert(0, RichText(text: WidgetSpan(child: linkPreview)));
      }
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets
        ..add(_showReactionBarUi(
            messageReactions: widget.message.metadata!["reactions"])),
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
            onTap: () => Navigator.of(context).pushNamed(
                UrlViewScreen.routeName,
                arguments: UrlViewArgs(
                    userr: widget.message.sender!,
                    urlImg: widget.message.imageUrl!,
                    heroTag: 'Message/${widget.message.imageUrl}/')),
            child: Container(
              padding: const EdgeInsets.only(top: 2, right: 2),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: Theme.of(context).colorScheme.secondary),
              child: Container(
                height: size.height * 0.2,
                width: size.width * 0.6,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(
                            widget.message.imageUrl!))),
              ),
            )),
        _showReactionBarUi(
            messageReactions: widget.message.metadata!["reactions"])
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
          height: size.height * 0.2,
          width: size.width * 0.6,
          child:GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(
                    UrlViewScreen.routeName,
                    arguments: UrlViewArgs(
                        userr: widget.message.sender!,
                        urlVid: widget.message.videoUrl!,
                        urlImg: widget.message.thumbnailUrl!,
                        heroTag:
                            'Message/${widget.message.videoUrl}/${widget.message.thumbnailUrl}')),
                child: Container(
                  child: Icon(
                      Icons.play_arrow,
                      size: 35,
                      color: Colors.black26,
                    ),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                     image: DecorationImage(
                            fit: BoxFit.cover,
                            image: CachedNetworkImageProvider(
                                widget.message.thumbnailUrl!)),
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ),
          
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7.0),
             ),
        ),
        _showReactionBarUi(
            messageReactions: widget.message.metadata!["reactions"])
      ],
    );
  }

  bool isInit = false;
  KingscordCubit? kcubit;
  @override
  Widget build(BuildContext context) {
    if (!isInit) {
      if (widget.kcubit == null) {
        kcubit = context.read<KingscordCubit>();
      } else {
        kcubit = widget.kcubit;
      }
    }

    return BlocProvider.value(
      value: kcubit!,
      child: context
              .read<BuidCubit>()
              .state
              .buids
              .contains(widget.message.sender!.id)
          ? HideContent.textContent(Theme.of(context).textTheme, () {
              context.read<BuidCubit>().onBlockUser(widget.message.sender!.id);
              Navigator.of(context).pop();
            })
          : GestureDetector(
              onLongPress: () {
                _showReactionsBar(
                    widget.message.id!,
                    widget.message.metadata!.containsKey('reactions')
                        ? widget.message.metadata!['reactions']
                        : {},
                    context,
                    widget.message.metadata!);
              },
              child: messageLineChild()),
    );
  }

  Widget messageLineChild() {
    var messageType = (widget.message.text == firstMsgEncoded ||
        widget.message.text == welcomeMsgEncoded);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 8.0, right: 8.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: widget.message.metadata!.containsKey(Mode.announcement)
                ? Color.fromARGB(46, 255, 193, 7)
                : null),
        // color: Colors.white24,
        child: messageType
            ? _messageWelcomeWidget()
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    kingsCordAvtar(context),
                    const SizedBox(
                      width: 15.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.message.sender!.username,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15),
                            ),
                            SizedBox(width: 5),
                            Text('${widget.message.date.timeAgo()}',
                                style: Theme.of(context)
                                    .textTheme
                                    .caption!
                                    .copyWith(fontStyle: FontStyle.italic)),
                          ],
                        ),
                        SizedBox(height: 2),
                        if (widget.message.replyMsg != null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3.0),
                            child: Container(
                              padding: EdgeInsets.only(left: 5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7.0),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(7.0),
                                    bottomRight: Radius.circular(7.0),
                                  ),
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 4.0, bottom: 5, left: 2, right: 2),
                                  child: RichText(
                                    text: TextSpan(
                                      style:
                                          Theme.of(context).textTheme.caption,
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: 'Replied ' +
                                                widget.message.replyMsg!
                                                    .senderUsername! + ' '),
                                        TextSpan(
                                            text: widget.message.replyMsg!
                                                        .text !=
                                                    null
                                                ? widget.message.replyMsg!.text!
                                                : 'Shared something',
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                        if (widget.message.metadata != null &&
                            widget.message.metadata!
                                .containsKey('isKngAi')) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3.0),
                            child: Container(
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7.0),
                                  gradient: LinearGradient(
                                      colors: [
                                        Colors.red,
                                        Colors.orange,
                                        Colors.yellow,
                                        Colors.green,
                                        Colors.blue,
                                        Colors.indigo,
                                        Colors.purple
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight)),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(2)),
                                  
                                  color:Theme.of(context).colorScheme.secondary,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 4.0, bottom: 5, left: 2, right: 2),
                                  child: Text('#kngAi', style: Theme.of(context).textTheme.caption),
                                ),
                              ),
                            ),
                          )
                        ],
                        Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width / 1.4,
                            ),
                            child: widget.message.giphyId != null
                                ? DisplayGif(giphyId: widget.message.giphyId!)
                                : widget.message.text != null
                                    ? _buildText(context)
                                    : widget.message.videoUrl != null &&
                                            widget.message.thumbnailUrl != null
                                        ? _buildVideo(context)
                                        : _buildImage(context)),
                      ],
                    )
                  ],
                ),
              ),
      ),
    );
  }

  Widget kingsCordAvtar(
    BuildContext context,
  ) {
    HexColor hexcolor = HexColor();
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          ProfileScreen.routeName,
          arguments: ProfileScreenArgs(initScreen: true, userId: widget.message.sender!.id, userr: widget.message.sender!));

      },
      child: Container(
        height: size.width > 400 ? 35 : size.height / 18.5,
        width: size.width > 400 ? 35 : size.width / 8,
        child: widget.message.sender!.profileImageUrl != "null"
            ? kingsCordProfileImg()
            : kingsCordProfileIcon(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
              width: 2,
              color: widget.message.sender!.colorPref == ""
                  ? Colors.red
                  : Color(
                      hexcolor.hexcolorCode(widget.message.sender!.colorPref))),
          color: widget.message.sender!.colorPref == ""
              ? Colors.red
              : Color(hexcolor.hexcolorCode(widget.message.sender!.colorPref)),
        ),
      ),
    );
  }

  Widget? kingsCordProfileImg() => ContainerWithURLImg(
      imgUrl: widget.message.sender!.profileImageUrl,
      height: 35,
      width: 35,
      pc: null);

  Widget? kingsCordProfileIcon() =>
      Container(child: Icon(Icons.account_circle));

  Widget _messageWelcomeWidget() {
    if (widget.message.text == firstMsgEncoded) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(widget.cm.imageUrl),
              radius: 57,
            ),
            SizedBox(height: 10),
            Text(widget.cm.name,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(fontSize: 20, fontWeight: FontWeight.w500)),
            SizedBox(height: 7),
            Text("Welcome to " + widget.kc.cordName,
                style: Theme.of(context)
                    .textTheme
                    .caption!
                    .copyWith(fontSize: 15, fontWeight: FontWeight.w300)),
            SizedBox(height: 7),
            Text(widget.message.sender!.username + " created this room",
                style: Theme.of(context)
                    .textTheme
                    .caption!
                    .copyWith(fontStyle: FontStyle.italic)),
            SizedBox(height: 7),
            Text("${widget.message.date.timeAgo()}",
                style: Theme.of(context)
                    .textTheme
                    .caption!
                    .copyWith(fontStyle: FontStyle.italic)),
            SizedBox(height: 5),
            Divider(
                color: Theme.of(context).colorScheme.inversePrimary, height: 7)
          ],
        ),
      );
    } else if (widget.message.text == welcomeMsgEncoded) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Container(
          decoration: BoxDecoration(
              color: Color.fromARGB(46, 255, 193, 7),
              borderRadius: BorderRadius.circular(7)),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          CachedNetworkImageProvider(widget.cm.imageUrl),
                      radius: 25,
                    ),
                    SizedBox(width: 7),
                    Text(widget.message.sender!.username,
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            fontSize: 20, fontWeight: FontWeight.w500)),
                  ],
                ),

                SizedBox(height: 7),

                Text("Welcome to " + widget.kc.cordName,
                    style: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(fontSize: 15, fontWeight: FontWeight.w300)),

                SizedBox(height: 7),

                // Text(widget.message.sender!.username + " created this room", style: Theme.of(context).textTheme.caption!.copyWith(fontStyle: FontStyle.italic)),

                // SizedBox(height: 7),

                Text("${widget.message.date.timeAgo()}",
                    style: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }
}
