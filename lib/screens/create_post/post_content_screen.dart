import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/cm_privacy.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/profile/bloc/profile_bloc.dart';
import 'package:kingsfam/screens/screens.dart';

import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../models/church_model.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../widgets/snackbar.dart';

class PostContentArgs {
  final File content;
  final String type;
  final String? cmId;
  PostContentArgs({required this.content, required this.type, this.cmId});
}

class PostContentScreen extends StatefulWidget {
  const PostContentScreen(
      {Key? key, required this.content, required this.type, this.cmId})
      : super(key: key);
  final File content;
  final String type;
  final String? cmId;
  @override
  State<PostContentScreen> createState() => _PostContentScreenState();

  static const String routeName = '/postContent';
  static Route route({required PostContentArgs args}) => MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => PostContentScreen(
          content: args.content,
          type: args.type,
          cmId: args.cmId,
        ),
      );
}

class _PostContentScreenState extends State<PostContentScreen> {
  late VideoPlayerController vidCtrl;
  late TextEditingController txtCtrlC;
  late ScrollController scrollCtrl;

  TextStyle style1 = GoogleFonts.adamina(color: Colors.green);
  TextStyle style2 = GoogleFonts.adamina(color: Colors.grey);

  File? imgF;
  File? vidF;
  String caption = "";
  String hashTags = "";
  List<Church> chs = [];
  String? lastStringId;
  String? cmIdPostingTo;
  bool submitting = false;
  bool success = false;
  String? thumbnailPath;
  bool canSubmit = false;

  @override
  void initState() {
    initStateVars();
    initVid();
    txtCtrlC = TextEditingController();
    scrollCtrl = ScrollController();
    scrollCtrl.addListener(listenToScrolling);
    cmIdPostingTo = widget.cmId;
    if (cmIdPostingTo != null) canSubmit = true;

    super.initState();
  }

  @override
  void dispose() {
    txtCtrlC.dispose();
    vidCtrl.dispose();
    super.dispose();
  }

  initVid() async {
    vidCtrl = VideoPlayerController.file(vidF!);
    thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: vidF!.path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.PNG,
      //maxHeight: 64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 50,
    );
    setState(() {});
  }

  void listenToScrolling() async {
    if (scrollCtrl.position.atEdge) {
      if (scrollCtrl.position.pixels != 0.0 &&
          scrollCtrl.position.maxScrollExtent == scrollCtrl.position.pixels) {
        var lst = await ChurchRepository().getCommuinitysUserIn(
            userrId: context.read<AuthBloc>().state.user!.uid,
            limit: 10,
            lastStringId: lastStringId);
        chs..addAll(lst);
        setState(() {});
      }
    }
  }

  void initStateVars() async {
    if (widget.type == "image")
      imgF = widget.content;
    else if (widget.type == "video") vidF = widget.content;
    var lst = await ChurchRepository().getCommuinitysUserIn(
        userrId: context.read<AuthBloc>().state.user!.uid, limit: 10);
    lastStringId = lst.last.id;
    chs..addAll(lst);
    setState(() {});
  }

  Widget submitButton() {
    return TextButton(
      onPressed: () {
        if (submitting != true && canSubmit) {
          snackBar(snackMessage: "Posting", context: context);
          submit();
        }
        ;
      },
      child: Row(
        children: [
          Text("Share Post",
              style: TextStyle(
                color: canSubmit ? Colors.green : Colors.grey,
              )),
          Icon(
            Icons.arrow_forward,
            color: canSubmit ? Colors.green : Colors.grey,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int popScreens = 0;
    if (success) {
      // Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
      // Navigator.of(context).popUntil((_) => popScreens++ >= 1); log("we poped $popScreens");
      //Navigator.of(context).pop();
    }
    log("curr user is: " + context.read<ProfileBloc>().state.userr.toString());
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title:
              Text('Add details', style: Theme.of(context).textTheme.bodyText1),
          actions: [submitButton()],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                submitting
                    ? LinearProgressIndicator(
                        color: Colors.amber,
                      )
                    : SizedBox.shrink(),
                Align(
                    alignment: Alignment.centerLeft,
                    child: imgF != null
                        ? displayImageWid(imgF!)
                        : vidF != null
                            ? thumbnailPath != null
                                ? displayVidThumbnail()
                                : _placeHolder()
                            : SizedBox.shrink()),
                txtBox("c"),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "Add Your Post To A Community",
                        style: Theme.of(context).textTheme.bodyText1,
                        textAlign: TextAlign.left,
                      ),
                    )),
                cmLisView(),
                
              ],
            ),
          ),
        ));
  }

  Widget txtBox(String s) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          fillColor: Theme.of(context).colorScheme.secondary,
          filled: true,
          focusColor: Theme.of(context).colorScheme.secondary,
          border: OutlineInputBorder(),
          labelText: s == "c" ? 'Caption???' : "ex: #meme #sermon #God",
        ),
        onChanged: (val) {
          if (s == "c") {
            caption = val;
            setState(() {});
          } else if (s != "c") {
            hashTags = val;
            setState(() {});
          }
        },
      ),
    );
  }

  Widget _placeHolder() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          height: 250,
          width: 250,
          child: Center(child: CircularProgressIndicator()),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0))),
    );
  }

  Widget displayVidThumbnail() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(UrlViewScreen.routeName,
              arguments: UrlViewArgs(
                userr: context.read<ProfileBloc>().state.userr,
                  heroTag: 'heroTag',
                  fileImg: File(thumbnailPath!),
                  fileVid: vidF!,
                  urlImg: null));
        },
        child: Stack(
          children: [
            Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  image: DecorationImage(
                      image: FileImage(File(thumbnailPath!)),
                      fit: BoxFit.cover)),
            ),
            Positioned.fill(
                child: Container(
              color: Colors.black26,
            )),
            Positioned.fill(
                child: Icon(
              Icons.play_circle_outline_outlined,
              size: 50,
            ))
          ],
        ),
      ),
    );
  }

  Widget displayImageWid(File imgF) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 250,
        width: 250,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            image: DecorationImage(image: FileImage(imgF), fit: BoxFit.cover)),
      ),
    );
  }

  Widget cmLisView() {
    // Get curr id
    // grab 15 cms curr id is a part of
    // if scroll ctrl hits bottom then grab next 15
    return Container(
      height: MediaQuery.of(context).size.shortestSide,
      child: Padding(
        padding: EdgeInsets.only(top: 15, left: 10, right: 10, bottom: 5),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 40,
          ),
          itemCount: chs.length,
          itemBuilder: (BuildContext context, int index) {
            Church ch = chs[index];
            return chBox(ch);
          },
        )),
    );
  }

  Widget chBox(Church ch) {
    return Padding(
      padding: EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (cmIdPostingTo == null)
                canSubmit = true;
              else
                canSubmit = false;

              if (!submitting) {
                if (ch.id == cmIdPostingTo) {
                  cmIdPostingTo = null;
                } else {
                  cmIdPostingTo = ch.id;
                }
              }
              setState(() {});
            },
            child: Container(
              height: MediaQuery.of(context).size.shortestSide / 2.7,
              width:  MediaQuery.of(context).size.shortestSide / 2.7,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7.0),
                  border: (cmIdPostingTo != null && ch.id == cmIdPostingTo)
                      ? Border.all(color: Colors.green, width: 3)
                      : null,
                  image: DecorationImage(
                      image: CachedNetworkImageProvider(ch.imageUrl),
                      fit: BoxFit.cover)),
            ),
          ),
          Text(
            ch.name,
            style: (cmIdPostingTo != null && ch.id == cmIdPostingTo)
                ? style1
                : style2,
          ),
          Text(
            ch.location,
            style: (cmIdPostingTo != null && ch.id == cmIdPostingTo)
                ? style1
                : style2,
          ),
        ],
      ),
    );
  }

  void submit() async {
    if (submitting == true) return;
    submitting = true;
    setState(() {});

    final author = await UserrRepository()
        .getUserrWithId(userrId: context.read<AuthBloc>().state.user!.uid);
    if (author.id == Userr.empty.id) {
      Navigator.of(context).pop();
    }
    final Church ch = Church(
        cmPrivacy: CmPrivacy.open,
        searchPram: [],
        name: '',
        location: '',
        imageUrl: '',
        members: {},
        events: [],
        about: '',
        recentMsgTime: Timestamp.now(),
        boosted: 0,
        themePack: 'none');

    if (imgF != null) {
      final postImageUrl =
          await StorageRepository().uploadPostImage(image: imgF!);
      var decodedImage = await decodeImageFromList(imgF!.readAsBytesSync());
      // var heightImgF = decodedImage.height;
      final post = Post(
        author: author,
        quote: null,
        imageUrl: postImageUrl,
        videoUrl: null,
        thumbnailUrl: null,
        commuinity: ch.copyWith(id: cmIdPostingTo),
        soundTrackUrl: null,
        caption: caption,
        likes: 0,
        date: Timestamp.now(),
        commentCount: 0,
      );

      PostsRepository().createPost(post: post);
      snackBar(
          snackMessage: "working on your post fam",
          context: context,
          bgColor: Colors.greenAccent);
      Navigator.popUntil(
          context, ModalRoute.withName(NavScreen.routeName));
      log("----------->posted<---------------- from post_content_screen.dart");
    } else if (vidF != null) {
      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: vidF!.path,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG,
        //maxHeight: 64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
        quality: 50,
      );

      final thumbnailUrl = await StorageRepository()
          .uploadThumbnailVideo(thumbnail: File(thumbnail!));

      final postVideoUrl =
          await StorageRepository().uploadPostVideo(video: vidF!);

      final post = Post(
          author: author,
          quote: null,
          imageUrl: null,
          videoUrl: postVideoUrl,
          thumbnailUrl: thumbnailUrl,
          commuinity: ch.copyWith(id: cmIdPostingTo),
          soundTrackUrl: null,
          caption: caption,
          likes: 0,
          date: Timestamp.now(),
          commentCount: 0);

      PostsRepository().createPost(post: post);
      snackBar(
          snackMessage: "working on your post fam",
          context: context,
          bgColor: Colors.greenAccent);
      Navigator.popUntil(
          context, ModalRoute.withName(NavScreen.routeName));
      //Navigator.of(context).popUntil((_) => popScreens++ >= 1);

      log("----------->posted<---------------- from post_content_screen.dart");
    }
  }
}
