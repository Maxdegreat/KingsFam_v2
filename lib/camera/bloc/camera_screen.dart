import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:kingsfam/helpers/image_helper.dart';
import 'package:kingsfam/helpers/navigator_helper.dart';
import 'package:kingsfam/screens/create_post/post_content_screen.dart';
import 'package:kingsfam/widgets/snackbar.dart';

class CameraScreenArgs {
  final String? cmId;
  CameraScreenArgs({this.cmId});
}

class CameraScreen extends StatefulWidget {
  final String? cmId;
  static const String routeName = "/camera_screen";

  const CameraScreen({Key? key, this.cmId}) : super(key: key);

  static Route route({required CameraScreenArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) {
          return CameraScreen(
            cmId: args.cmId,
          );
        });
  }

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? imageFile;
  File? videoFile;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              )),
          backgroundColor: Colors.black,
          title: Text('Share whats going on',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: Colors.white)),
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.black,
                      Colors.black,
                      Theme.of(context).colorScheme.primary
                      // Theme.of(context).colorScheme.onPrimary,
                    ]),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // const SizedBox(height: 40),
                  const Spacer(),
                  _showImage(),
                  const SizedBox(height: 20),
                  _showText(),
                  const SizedBox(height: 20),
                  _pickImg(),
                  const SizedBox(height: 0),
                  _pickVideo(),
                  const SizedBox(height: 0),
                  _post(),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ));
  }

  _showImage() {
    if (imageFile != null || videoFile != null) {
      return Container(
        height: 105,
        width: 80,
        decoration:
            BoxDecoration(image: DecorationImage(image: FileImage(imageFile!))),
      );
    } else {
      return Container(
        height: 105,
        width: 80,
        color: Theme.of(context).colorScheme.secondary,
        child: Icon(Icons.camera_alt_outlined),
      );
    }
  }

  _showText() {
    return Text(
      "Pick an image to share then chose which commuinity if any to share to",
      style: Theme.of(context)
          .textTheme
          .bodyText1!
          .copyWith(fontWeight: FontWeight.w700, color: Colors.white),
      textAlign: TextAlign.center,
    );
  }

  _pickImg() {
    return Container(
      width: MediaQuery.of(context).size.width / 1,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(84, 255, 255, 255),
            side: BorderSide(color: Colors.white, width: 2),
          ),
          onPressed: () async {
            final pickedFile = await ImageHelper.pickImageFromGallery(
                context: context,
                cropStyle: CropStyle.rectangle,
                title: 'send');
            if (pickedFile != null) {
              imageFile = pickedFile;
            }
            setState(() {});
          },
          child: Text("Pick an image",
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(color: Colors.white))),
    );
  }

  _pickVideo() {
    return Container(
      width: MediaQuery.of(context).size.width / 1,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(84, 255, 255, 255),
            side: BorderSide(color: Colors.white, width: 2),
          ),
          onPressed: () async {
            final pickedFile = await ImageHelper.pickVideoFromGallery(context);
            if (pickedFile != null) {
              imageFile = pickedFile;
            }
            if (pickedFile != null) {
              videoFile = File(pickedFile.path);
              NavHelper().navToVideoEditor(
                  context, videoFile!, PostContentScreen.routeName);
            }
            setState(() {});
          },
          child: Text("Pick a video",
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(color: Colors.white))),
    );
  }

  _post() {
    return Container(
      width: MediaQuery.of(context).size.width / 1,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(84, 255, 255, 255),
            side: BorderSide(color: Colors.white, width: 2),
          ),
          onPressed: () {
            if (imageFile != null)
              Navigator.of(context).pushNamed(PostContentScreen.routeName,
                  arguments:
                      PostContentArgs(content: imageFile!, type: 'image'));
            else
              snackBar(snackMessage: "Pick an image of video first", context: context);
          },
          child: Text("Pick Community")),
    );
  }
}
