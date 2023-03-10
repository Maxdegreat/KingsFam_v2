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

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).iconTheme.color,
            )),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [Container(
                    height: 70,
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
                        hintText: "Title",
                      ),
                      onChanged: (_) => setState(() {}),
                      textInputAction: TextInputAction.search,
                      textAlignVertical: TextAlignVertical.center,
                    ),
                  ),
                  
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                      ],
                    )

                  ],
                ),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _footer(),
            ),
          ],
        ),
      ),
    ));
  }

  _sendSays() {
    

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        shape: StadiumBorder(),
        side: BorderSide(color: Theme.of(context).colorScheme.primary, width: .5),
      ),
      child: Text(
        "Publish",
        style: Theme.of(context).textTheme.subtitle1,
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
          //  _imageFooterBtn(),
          // child 2 will be a gif
          _gifFooterBtn(),
          Spacer(),
          _sendSays()
        ],
      ),
    );
  }

  // _imageFooterBtn() {
  //   return IconButton(
  //       onPressed: () async {
  //         final pickedFile = await ImageHelper.pickImageFromGallery(
  //             context: context,
  //             cropStyle: CropStyle.rectangle,
  //             title: 'Add To Forum');
  //         if (pickedFile != null) {

  //         }
  //       },
  //       icon: Icon(Icons.image));
  // }

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
            _controller.value = TextEditingValue(
              text: _controller.value.text + gif!.url!,
              selection: TextSelection.fromPosition(
                  TextPosition(offset: _controller.text.length)),
            );
          });
        },
        icon: Icon(Icons.gif));
  }
}
