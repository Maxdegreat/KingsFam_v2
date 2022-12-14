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
      {Key? key,
      required this.cm,
      required this.kcId,
      required this.currUsr})
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
        title: Text("Post New Says"),
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
              KingsCordUserDisplay(),
              SizedBox(height: 5),
              TextField(
                controller: _controllerT,
                decoration: InputDecoration(
                  label: Text("Title")
                ),
              ),
              Container(
                height: 300,
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  expands: true,
                  minLines: null,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                      border: InputBorder.none,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 8),
      child: Container(
        height: 18,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: Color(hc.hexcolorCode(widget.currUsr.colorPref))),
          child: Text("Done"),
          onPressed: () {
            try {
              // ignore: unnecessary_null_comparison
              String? title = _controllerT.value.text.isEmpty ||  _controllerT.value.text.isEmpty == null 
                ? null
                : _controllerT.value.text;

                if (title != null) {
                  if (_controllerT.value.text.length > 15) {
                    snackBar(snackMessage: "Make sure your title is 15 or less chars", context: context, bgColor: Colors.red[400]);
                    return;
                  }
                }
              // make the says
            Says says = Says(
                author: widget.currUsr,
                contentTxt: _controller.value.text,
                likes: 0,
                commentsCount: 0,
                date: Timestamp.now(),
                kcId: widget.kcId,
                title: title
            );
            // send the Says using repo
            SaysRepository()
              .createSays(cmId: widget.cm.id!, kcId: widget.kcId, says: says);
            SnackBar(content: Text("Nice! Working On Your Says"), backgroundColor: Colors.green,);
            // nav . pop()
            Navigator.of(context).pop();
            } catch (e) {
              log("There was an error in createSays: " + e.toString());
            }
          },
        ),
      ),
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
