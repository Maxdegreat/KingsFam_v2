import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/repositories/church/church_repository.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/profile/bloc/profile_bloc.dart';
import 'package:bloc/bloc.dart';

import 'package:kingsfam/widgets/videos/videoPostView16_9.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../models/church_model.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';

class PostContentArgs {
  final File content;
  final String type;
  PostContentArgs({required this.content, required this.type});
}

class PostContentScreen extends StatefulWidget {
  const PostContentScreen({Key? key, required this.content, required this.type})
      : super(key: key);
  final File content;
  final String type;
  @override
  State<PostContentScreen> createState() => _PostContentScreenState();

  static const String routeName = '/postContent';
  static Route route({required PostContentArgs args}) => MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => PostContentScreen(
              content: args.content,
              type: args.type,
            ),);
}

class _PostContentScreenState extends State<PostContentScreen> {
  late VideoPlayerController vidCtrl;
  late TextEditingController txtCtrlC;
  late TextEditingController txtCtrlH;
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
  

  @override
  void initState() {
    initStateVars();
    txtCtrlC = TextEditingController();
    txtCtrlH = TextEditingController();
    scrollCtrl = ScrollController();
    scrollCtrl.addListener(listenToScrolling);
    if (widget.type == "video") {
      vidCtrl = VideoPlayerController.file(vidF!);
      vidCtrl
      ..addListener(() => setState(() {}))
      ..setLooping(true) // -------------------------------- SET PERKED LOOPING TO TRUE
      ..initialize().then((_) {
        vidCtrl.play();
        vidCtrl.setVolume(1);
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    txtCtrlC.dispose();
    vidCtrl.dispose();
    txtCtrlH.dispose();
    super.dispose();
  }

  void listenToScrolling() async {
    if (scrollCtrl.position.atEdge) {
      if (scrollCtrl.position.pixels != 0.0 &&
          scrollCtrl.position.maxScrollExtent ==
              scrollCtrl.position.pixels) {
                var lst = await ChurchRepository().getCommuinitysUserIn(userrId: context.read<AuthBloc>().state.user!.uid, limit: 10, lastStringId: lastStringId );
                chs..addAll(lst);
                setState(() {});
      }
    }
  }

  void initStateVars() async {
    if (widget.type == "image")
      imgF = widget.content;
    else if (widget.type == "video")
      vidF = widget.content;
    var lst = await ChurchRepository().getCommuinitysUserIn(userrId: context.read<AuthBloc>().state.user!.uid, limit: 10);
    lastStringId = lst.last.id;
    chs..addAll(lst);
    setState(() {});
  }



  Widget submitButton() {
    return ElevatedButton(
      onPressed: () => submit(), 
      child: Row(
        children: [
          Text("POST", style: TextStyle(color: Colors.green)),
          Icon(Icons.arrow_forward, color: Colors.green,)
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (success) {
      Navigator.of(context).popUntil(ModalRoute.withName("/Page1"));
    }
    log("curr user is: " + context.read<ProfileBloc>().state.userr.toString());
    return Scaffold(
      appBar: AppBar(title: Text('Post'), actions: [submitButton()],),
      body:  SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              submitting ? LinearProgressIndicator(color: Colors.amber,) : SizedBox.shrink(),
              txtBox("c"),
              Center(child: imgF != null ? displayImageWid(imgF!) : vidF != null ? displayVidWid(vidF!) : SizedBox.shrink()),
              txtBox("h"),
              Text("Hey Fam Wana Include Your Post In A Community?"),
              cmLisView()
            ],
          ),
        )
    );
  }

  Widget txtBox(String s) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: s == "c" ? 'Caption???' : "ex: #meme #sermon #God",
        ),
      ),
    );
  }

  Container displayVidWid(File vidF) {
    return Container(
      height: 250,
      child: VisibilityDetector(
        key: ObjectKey(widget.content),
        onVisibilityChanged: (vis) {
          if (vis.visibleFraction == 0) {
            vidCtrl.dispose();
            Navigator.of(context).pop();
          }
        },
        child: VideoPostView16_9(
          controller: vidCtrl,
          post: Post.empty,
          userr: Userr.empty,
          videoUrl: "",
          playVidNow: true,
        ),
      ),
    );
  }

  Container displayImageWid(File imgF) {
    return Container(
      height: 300,
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
          image: DecorationImage(
              image: FileImage(imgF), fit: BoxFit.cover)),
    );
  }

  Widget cmLisView() {
    // Get curr id
    // grab 15 cms curr id is a part of
    // if scroll ctrl hits bottom then grab next 15
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Container(
        height: 350,
        width: double.infinity,
        child: ListView.builder(
          itemCount: chs.length,
          itemBuilder: (context, index) {
            Church ch = chs[index];
            return chBox(ch);
          },
        ),
      ),
    );
  }

  Widget chBox(Church ch) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (!submitting) {
                if (ch.id == cmIdPostingTo) {
                cmIdPostingTo = null;
                setState(() {});
              } else {
                cmIdPostingTo = ch.id;
                setState(() {});
              }
              }
            },
            child: Container(
              height: 130,
              width: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7.0),
                image: DecorationImage( image: CachedNetworkImageProvider(ch.imageUrl), fit: BoxFit.cover)
              ),
            ),
          ),
          Text(ch.name, style: (cmIdPostingTo != null && ch.id == cmIdPostingTo) ? style1 : style2,),
          Text(ch.location, style: (cmIdPostingTo != null && ch.id == cmIdPostingTo) ? style1 : style2,),
        ],
      ),
    );
  }

    void submit() async {
      submitting = true;
      setState(() {});
      final author = context.read<ProfileBloc>().state.userr;
      final Church ch = Church(searchPram: [], name: '', location: '', imageUrl: '', members: {}, events: [], about: '', recentMsgTime: Timestamp.now(), boosted: 0, themePack: 'none');
      
      if (imgF != null) {
        final postImageUrl = await StorageRepository().uploadPostImage(image: imgF!);

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
            height: 0
        );

        await PostsRepository().createPost(post: post);
        success = true;
        setState(() {});
        log("----------->posted<---------------- from post_content_screen.dart");


        
      }  else if (vidF != null) {

        // make the thumbnail
        final thumbnail = await VideoThumbnail.thumbnailFile(
          video: vidF!.path,
          thumbnailPath: (await getTemporaryDirectory()).path,
          imageFormat: ImageFormat.PNG,
          //maxHeight: 64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
          quality: 100,
        );

        final  thumbnailUrl = await StorageRepository().uploadThumbnailVideo(thumbnail: File(thumbnail!));
        print("The thumbnail:  $thumbnail");
        final postVideoUrl = await StorageRepository().uploadPostVideo(video: vidF!);

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
            height: null

        );
       
        await PostsRepository().createPost(post: post);
        success = true;
        setState(() {});
        log("----------->posted<---------------- from post_content_screen.dart");
      }
  }

}
