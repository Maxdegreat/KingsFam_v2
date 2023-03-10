import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:kingsfam/helpers/image_helper.dart';
import 'package:kingsfam/helpers/user_preferences.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/models/says_model.dart';
import 'package:kingsfam/repositories/says/says_repository.dart';
import 'package:kingsfam/widgets/snackbar.dart';
import 'package:uuid/uuid.dart';

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
  String _title = "Untitled";
  Map<String, dynamic> items = {};

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
        title: Text(_title, style: Theme.of(context).textTheme.bodyText1),
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
              Expanded(
                flex: 1,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: double.infinity,
                  child: TextField(
                    maxLines: 1,
                    style: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(fontSize: 25, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.left,
                    controller: _controllerT,
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      border: InputBorder.none,
                      focusColor: Theme.of(context).colorScheme.secondary,
                      hintStyle: Theme.of(context)
                          .textTheme
                          .caption!
                          .copyWith(fontSize: 25, fontWeight: FontWeight.w500),
                      hintText: "Untitled",
                    ),
                    onChanged: (_) => setState(() {
                      _title = _controllerT.text;
                      if (_controllerT.text.isEmpty) {
                        _title = "Untitled";
                      }
                    }),
                    textInputAction: TextInputAction.search,
                    textAlignVertical: TextAlignVertical.center,
                  ),
                ),
              ),
              // ------------------
              Expanded(
                flex: 10,
                child: Container(
                  width: double.infinity,
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    minLines: null,
                    maxLines: 150,
                    textCapitalization: TextCapitalization.sentences,
                    autocorrect: true,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintStyle: Theme.of(context)
                            .textTheme
                            .caption!
                            .copyWith(fontSize: 17),
                        hintText: "..."),
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
              ),
              items.length > 0 ? _footerShow() : const SizedBox.shrink(),
              _footer(),
            ],
          ),
        ),
      ),
    ));
  }

  _sendSays() {
    return TextButton(
      child: Text(
        "Publish",
        style: Theme.of(context).textTheme.bodyText1,
      ),
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
            SaysRepository()
                .createSays(cmId: widget.cm.id!, kcId: widget.kcId, says: says);
            snackBar(
                snackMessage: "Working on post...",
                context: context,
                bgColor: Colors.green);
            Navigator.of(context).pop();
          } else {
            snackBar(
                snackMessage: "Please share in order to post",
                context: context,
                bgColor: Colors.red[400]);
          }
        } catch (e) {
          log("There was an error in createSays: " + e.toString());
        }
      },
    );
  }

  Widget _footerShow() {
    return SingleChildScrollView(
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          if (items.values.toList()[index].contains("https://")) {
            return Container(height: 50, width: 50, child: Text(items.values.length.toString(), style: Theme.of(context).textTheme.bodyText1,));
          } else {
            return Container(height: 50, width: 50, child: Text(items.values.length.toString(), style: Theme.of(context).textTheme.bodyText1,));
          }
        } ,
      )
    );
  }

  // need to make a footer
  Widget _footer() {
    return Container(
      height: MediaQuery.of(context).size.shortestSide / 10,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          // child 1 will be a image
          _imageFooterBtn(),
          // child 2 will be a gif
          _gifFooterBtn(),
        ],
      ),
    );
  }

  _imageFooterBtn() {
    return IconButton(
        onPressed: () async {
          final pickedFile = await ImageHelper.pickImageFromGallery(
              context: context,
              cropStyle: CropStyle.rectangle,
              title: 'Add To Forum');
          if (pickedFile != null) {
            items["item-" + (items.keys.length + 1).toString()] = pickedFile;
            _controller.value = TextEditingValue(
              text: _controller.value.text +
                  " item-" +
                  (items.keys.length + 1).toString(),
              selection: TextSelection.collapsed(
                  offset: _controller.value.text.length + 1),
            );
          }
        },
        icon: Icon(Icons.image));
  }

  _gifFooterBtn() {
    return IconButton(
        onPressed: () {
          GiphyGet.getGif(
            context: context,
            apiKey: "ge17PWpKQ9OmxKuPE8ejeYmI3SHLZOeY",
            modal: true,
            randomID: Uuid().v4().toString(),
            tabColor: Theme.of(context).colorScheme.primary,
          ).then((gif) {
            items["item-" + (items.keys.length + 1).toString()] = gif!.url!;
            _controller.value = TextEditingValue(
              text: _controller.value.text +
                  " item-" +
                  (items.keys.length + 1).toString(),
              selection: TextSelection.collapsed(
                  offset: _controller.value.text.length + 1),
            );
          });
        },
        icon: Icon(Icons.gif));
  }
}
