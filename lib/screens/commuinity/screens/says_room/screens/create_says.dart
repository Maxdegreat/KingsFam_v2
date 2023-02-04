import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kingsfam/config/constants.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/models/says_model.dart';
import 'package:kingsfam/repositories/says/says_repository.dart';
import 'package:kingsfam/widgets/snackbar.dart';

class CreateSaysArgs {
  final String kcId;
  final Church chLim;
  final Userr currUsr;
  const CreateSaysArgs(
      {required this.chLim, required this.kcId, required this.currUsr});
}

class CreateSays extends StatefulWidget {
  const CreateSays(
      {Key? key, required this.cm, required this.kcId, required this.currUsr})
      : super(key: key);
  final String kcId;
  final Church cm;
  final Userr currUsr;
  static const String routeName = "createSays";
  static Route route({required CreateSaysArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(),
        builder: (context) {
          return CreateSays(
            cm: args.chLim,
            kcId: args.kcId,
            currUsr: args.currUsr,
          );
        });
  }

  @override
  State<CreateSays> createState() => _CreateSaysState();
}

class _CreateSaysState extends State<CreateSays> {
  late TextEditingController _controller;
  late TextEditingController _controllerT;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controllerT = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _controllerT.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _txtHeight = 50;

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).iconTheme.color,
            )),
        title: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            height: 30,
            width: double.infinity,
            child: TextField(textAlign: TextAlign.left,
            
              controller: _controllerT,
              decoration: InputDecoration(alignLabelWithHint: true,
                border: InputBorder.none,
                focusColor: Theme.of(context).colorScheme.secondary,
                hintStyle: Theme.of(context).textTheme.caption,
                hintText: "Add a title",
                contentPadding: EdgeInsets.all(10.0),
              ),
              textInputAction: TextInputAction.search,
              textAlignVertical: TextAlignVertical.center,
            ),
          ),
        ),
        actions: [_sendSays()],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KingsCordUserDisplay(),
              // SizedBox(height: 5),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  minLines: null,
                  maxLines: 150,
                  textCapitalization: TextCapitalization.sentences,
                  autocorrect: true,
                  decoration: InputDecoration(
                    // fillColor: Theme.of(context).colorScheme.secondary,
                  // filled: true,
                  // focusColor: Theme.of(context).colorScheme.secondary,
                      border: InputBorder.none,
                      hintStyle: Theme.of(context).textTheme.caption!.copyWith(fontSize: 17),
                      hintText: "Share Your Thoughts"),
                  controller: _controller,
                  onSubmitted: (String value) async {
                    await showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Thanks!'),
                          content: Text(
                              'You typed "$value", which has length ${value.characters.length}.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  _sendSays() {
    return TextButton(
      
      child: Text("Post", style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.white),),
      onPressed: () {
        try {
          // ignore: unnecessary_null_comparison
          String? title = _controllerT.value.text.isEmpty ||
                  _controllerT.value.text.isEmpty == null
              ? null
              : _controllerT.value.text;

          if (title != null) {
            if (_controllerT.value.text.length > 35) {
              snackBar(
                  snackMessage: "Make sure your title is 25 or less chars",
                  context: context,
                  bgColor: Colors.red[400]);
              return;
            }
          }
          // make the says
          if (_controller.value.text.length > 0) {
            Says says = Says(
              author: widget.currUsr,
              contentTxt: _controller.value.text,
              likes: 0,
              commentsCount: 0,
              date: Timestamp.now(),
              kcId: widget.kcId,
              title: title);
          // send the Says using repo
          SaysRepository().createSays(cmId: widget.cm.id!, kcId: widget.kcId, says: says);
          snackBar(snackMessage: "Working on post...", context: context, bgColor: Colors.green);
          Navigator.of(context).pop();
          } else {
            snackBar(snackMessage: "Please share in order to post", context: context, bgColor: Colors.red[400]);
          }
        } catch (e) {
          log("There was an error in createSays: " + e.toString());
        }
      },
    );
  }

  Widget KingsCordUserDisplay() {
    return Row(
      children: [
        kingsCordAvtar(context, widget.currUsr),
        SizedBox(width: 5),
        Text(widget.currUsr.username,
            style: TextStyle(
                color: Color(hc.hexcolorCode(widget.currUsr.colorPref)))),
      ],
    );
  }

  Widget kingsCordAvtar(BuildContext context, Userr usr) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.height / 18.5,
      width: size.width / 8,
      child: usr.profileImageUrl != "null"
          ? kingsCordProfileImg(usr.profileImageUrl)
          : kingsCordProfileIcon(),
      decoration: BoxDecoration(
          border: Border.all(
              width: 2,
              color: usr.colorPref == ""
                  ? Colors.red
                  : Color(hc.hexcolorCode(usr.colorPref))),
          color: usr.colorPref == ""
              ? Colors.red
              : Color(hc.hexcolorCode(usr.colorPref)),
          shape: BoxShape.circle),
    );
  }

  Widget? kingsCordProfileImg(String imgUrl) => CircleAvatar(
        backgroundColor: Colors.grey[400],
        backgroundImage: CachedNetworkImageProvider(imgUrl),
        radius: 8,
      );
  Widget? kingsCordProfileIcon() =>
      Container(child: Icon(Icons.account_circle));
}
