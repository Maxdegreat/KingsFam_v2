import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/extensions/hexcolor.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/extensions/extensions.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageLines extends StatelessWidget {
  //class data
  final Message message;
  final String kcId;
  final String cmId;

  MessageLines({required this.message, required this.cmId, required this.kcId});

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
        text: TextSpan(text: reaction, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold), children: [TextSpan(text: '\t$num', style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold))]),
      )),
      decoration: BoxDecoration(
          color: Colors.white24,
          border: Border.all(color: Colors.red[800]!, width: 2),
          borderRadius: BorderRadius.circular(5)),
    );
  }

  _showReactionsBar(String messageId, Map<String, int> messageReactions,
      BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                      onTap: () {
                        uploadReaction('💖', messageId, messageReactions);
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
                        uploadReaction('😁', messageId, messageReactions);
                        Navigator.of(context).pop();
                      },
                      child: Text('😁', style: TextStyle(fontSize: 27))),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                      onTap: () {
                        uploadReaction('😭', messageId, messageReactions);
                        Navigator.of(context).pop();
                      },
                      child: Text('😭', style: TextStyle(fontSize: 27))),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                      onTap: () {
                        uploadReaction('👀', messageId, messageReactions);
                        Navigator.of(context).pop();
                      },
                      child: Text('👀', style: TextStyle(fontSize: 27))),
                ),
              ],
            ),
          );
        });
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
          Padding(
            padding: const EdgeInsets.only(left: 7),
            child: Text(message.text!,
                style: TextStyle(
                    color: Colors.amber[100],
                    fontSize: 17.0,
                    fontWeight: FontWeight.w800)),
          ),
          message.reactions == {} || message.reactions == {'': 0}
              ? SizedBox.shrink()
              : Container(
                  height: 30,
                  child: Row(
                      children: message.reactions!.keys.map((e) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 7.0),
                      child: reactionContainer(
                          reaction: e, num: message.reactions![e]!),
                    );
                  }).toList()),
                )
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
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(UrlViewScreen.routeName,
          arguments: UrlViewArgs(
              urlMain: message.imageUrl!,
              urlSub: '',
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
    );
  }

  _buildVideo(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(
                UrlViewScreen.routeName,
                arguments: UrlViewArgs(
                    urlMain: message.videoUrl!,
                    urlSub: message.thumbnailUrl!,
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
          )
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
                kingsCordAvtar(context),
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
          borderRadius: BorderRadius.circular(25)),
    );
  }

  Widget? kingsCordProfileImg() => CircleAvatar(
      backgroundColor: Colors.grey[400],
      backgroundImage:
          CachedNetworkImageProvider(message.sender!.profileImageUrl));
  Widget? kingsCordProfileIcon() =>
      Container(child: Icon(Icons.account_circle));
}
