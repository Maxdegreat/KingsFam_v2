import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';

import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/post/post_repository.dart';

import 'package:kingsfam/screens/screens.dart';

import 'package:kingsfam/extensions/date_time_extension.dart';

import 'package:kingsfam/widgets/commuinity_pf_image.dart';
import 'package:kingsfam/widgets/profile_image.dart';
import 'package:kingsfam/widgets/snackbar.dart';
import 'package:kingsfam/widgets/videos/videoPostView16_9.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../config/paths.dart';
import '../screens/commuinity/community_home/home.dart';

class PostSingleView extends StatefulWidget {
  final Post? post;
  final bool isLiked;
  final VoidCallback onLike;
  final bool recentlyLiked;
  final ScrollController? scrollController;
  final TabController? tabCtrl;
  final AdWidget? adWidget;

  PostSingleView({
    this.adWidget,
    this.tabCtrl,
    this.scrollController,
    this.recentlyLiked = false,
    required this.post,
    required this.isLiked,
    required this.onLike,
  });

  @override
  _PostSingleViewState createState() => _PostSingleViewState();
}

class _PostSingleViewState extends State<PostSingleView> {
  bool _visible = false;
  bool _wasEverVisible = false;
  late VideoPlayerController vidCtrl;
  void updateVisibility() {
    if (widget.post != null && widget.post!.imageUrl != null) {
      _visible = true;
      _wasEverVisible = true;
    }
    Future.delayed(Duration(seconds: 1)).then((value) {
      setState(() {
        _visible = false;
      });
    });
  }

  @override
  void initState() {
    if (widget.post != null && widget.post!.videoUrl != null) {
      vidCtrl = VideoPlayerController.network(widget.post!.videoUrl!);
      vidCtrl.pause();
    }
    updateVisibility();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Align(
            alignment: Alignment.center,
            child: contentContainer(post: widget.post, size: size)),

        _visible ? blackOverLay() : SizedBox.shrink(),

        Positioned.fill(
            child: userPicAndName(
                name: widget.post == null ? "Ad" : widget.post!.author.username,
                imgurl: widget.post == null
                    ? "Ad"
                    : widget.post!.author.profileImageUrl)),
       
        Align(
            alignment: Alignment.bottomLeft,
            child: showCaptions(
                caption: widget.post == null ? null : widget.post!.caption,
                author:
                    widget.post == null ? "Ad" : widget.post!.author.username)),
      ],
    );
  }

  Widget blackOverLay() {
    return GestureDetector(
      onTap: () {
        if (_visible)
          setState(() => _visible = false);
        else if (_wasEverVisible && !_visible) setState(() => _visible = true);
      },
      onDoubleTap: widget.onLike,
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        color: Colors.black54,
        alignment: Alignment.center,
      ),
    );
  }

  Widget viewCommuinity({required Church? commuinity, required bool isImage}) {
    return commuinity != null
        ? Column(children: [
            !isImage
                ? Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      decoration: BoxDecoration(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 0),
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed(
                              CommunityHome.routeName,
                              arguments:
                                  CommunityHomeArgs(cm: commuinity, cmB: null)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ok add the commuinity image
                              commuinity_pf_img(commuinity.imageUrl, 25, 25),
                              SizedBox(width: 7),
                              // add the commuinity name
                              Text(
                                commuinity.name,
                                style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.grey)
                              )
                            ],
                          ),
                        ),
                      ),
                    ))
                : _visible
                    ? Positioned(
                        top: 90,
                        right: 30,
                        left: 0,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 7.0, right: 12.0, left: 12.0),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(3)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 3),
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).pushNamed(
                                    CommunityHome.routeName,
                                    arguments: CommunityHomeArgs(
                                        cm: commuinity, cmB: null)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // ok add the commuinity image
                                    commuinity_pf_img(
                                        commuinity.imageUrl, 25, 25),
                                    SizedBox(width: 7),
                                    // add the commuinity name
                                    Text(
                                      commuinity.name,
                                      style: TextStyle(
                                          color: Colors.grey[350],
                                          fontSize: 17),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : SizedBox.shrink()
          ])
        : _visible
            ? Stack(
                children: [
                  Positioned(
                      top: 90,
                      right: 30,
                      left: 0,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 7.0, right: 12.0, left: 12.0),
                        child: Container(
                          child: Text("NO Community Bruv"),
                        ),
                      )),
                ],
              )
            : SizedBox.shrink();
  }

  // widget.post!.author.id ==
  //                               context.read<AuthBloc>().state.user!.uid
  //                           ? IconButton(
  //                               onPressed: () => widget.post != null
  //                                   ? _postSettings()
  //                                   : null,
  //                               icon: Icon(Icons.more_vert))
  //                           : IconButton(
  //                               onPressed: () =>
  //                                   widget.post != null ? _reportPost() : null,
  //                               icon: Icon(Icons.report_gmailerrorred_outlined,
  //                                   color: Colors.red[100]),
  //                             )


  Widget interactions() {
    return widget.post == null
        ? SizedBox.shrink()
        : Stack(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  child: widget.isLiked
                      ? Icon(Icons.keyboard_double_arrow_up_sharp,
                          size: 35, color: Colors.amber)
                      : Icon(
                          Icons.keyboard_arrow_up_outlined,
                          size: 30,
                        ),
                ),
                Container(
                  //margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: .5),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(7)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Text(
                        "${widget.recentlyLiked ? widget.post!.likes + 1 : widget.post!.likes}"),
                  ),
                ),
                Container(
                  child: IconButton(
                      // onPressed: () => commentSheet(post: widget.post),
                      onPressed: () => Navigator.of(context).pushNamed(
                          CommentScreen.routeName,
                          arguments: CommentScreenArgs(post: widget.post!)),
                      icon: Icon(Icons.message, color: Colors.white)),
                ),
              ],
            )
          ]);
  }

  Widget userPicAndName({required String name, required String imgurl}) {
    return widget.post != null
        ? Container(
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black38,
                Colors.black12,
              ]
            )
          ),
          child: Stack(
              children: [
                Positioned(
                  top: 5,
                  left: 0,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed(
                          ProfileScreen.routeName,
                          arguments: ProfileScreenArgs(
                              userId: widget.post!.author.id, vidCtrl: vidCtrl)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              ProfileImage(radius: 20, pfpUrl: imgurl),
                              SizedBox(width: 15.0),
                              Text(
                                name,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
        )
        : SizedBox.shrink();
  }

  _postSettings() {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
              height: 120,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 8, bottom: 8),
                    child: TextButton(
                      child: Text("Ummm, U Wana Delete This?",
                          style: TextStyle(color: Colors.red, fontSize: 17)),
                      onPressed: () {
                        context
                            .read<PostsRepository>()
                            .deletePost(post: widget.post!);
                        snackBar(
                            snackMessage:
                                "post removed. update will soon be visible",
                            context: context,
                            bgColor: Colors.grey[700]);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: TextButton(
                      child: Text("Nevermind",
                          style: TextStyle(color: Colors.white, fontSize: 17)),
                      onPressed: () {},
                    ),
                  )
                ],
              ));
        });
  }

  _reportPost() {
    // send a notif to me (kf ceo) to make known that there was a post that was
    // flaged for some reason.
    if (widget.post!.commuinity != null) {
      FirebaseFirestore.instance
          .collection(Paths.report)
          .doc(widget.post!.commuinity!.id)
          .set({"postId": widget.post!.id});

      snackBar(
          snackMessage: "Thank you. this post will be reviewed",
          context: context);
    }
  }

  Widget contentContainer({required Post? post, required Size size}) {
    if (post != null && post.imageUrl != null) {
      return GestureDetector(
        onTap: () {
          if (_visible)
            setState(() => _visible = false);
          else if (_wasEverVisible && !_visible)
            setState(() => _visible = true);
        },
        onDoubleTap: () {
          widget.onLike;
          setState(() {});
        },
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: size.height / 1.7),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: CachedNetworkImageProvider(post.imageUrl!),
                        fit: BoxFit.fitWidth)),
              ),
            ],
          ),
        ),
      );
    } else if (post != null && post.videoUrl != null) {
      // context.read<BottomnavbarCubit>().setVidCtrl(vidCtrl);
      return VisibilityDetector(
        key: ObjectKey(widget.post),
        onVisibilityChanged: (vis) {
          if (vis.visibleFraction == 0) {
            vidCtrl.pause();
          }
        },
        child: GestureDetector(
          onDoubleTap: () {
          widget.onLike;
          setState(() {});
        },
          child: VideoPostView16_9(
            tabCtrl: widget.tabCtrl,
            post: widget.post!,
            userr: widget.post!.author,
            videoUrl: widget.post!.videoUrl!,
            playVidNow: true,
            controller: vidCtrl,
          ),
        ),
      );
    } else if (widget.adWidget != null) {
      return Center(child: widget.adWidget);
    } else {
      return Text("content container is empty???");
    }
  }

  Widget showCaptions({
    required String? caption,
    required String author,
  }) {
    if (caption == null) return _captionTextBox("", author, 35);
    double captionContainerSize = 35;
    if (caption.length > 40) captionContainerSize = 70;
    return _captionTextBox(caption, author, captionContainerSize);
  }

  _captionTextBox(String caption, String author, double size) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black12,
                Colors.black38,
              ]
            )
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // interactions(),
            widget.post != null
                ? viewCommuinity(
                    commuinity: widget.post!.commuinity,
                    isImage: widget.post!.imageUrl != null
                  )
                : SizedBox.shrink(),
            Container(
              height: size + 25,
              width: double.infinity,
              child: Text(
                widget.post != null ? caption : "Advertisement",
                style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.white),
              )
            ),
          ],
        ),
      ),
    );
  }

  // Future<List<int>> getImageData(Image i, double h, double w) async {
  //   File image = new File('image.png'); // Or any other way to get a File instance.
  //   var decodedImage = await decodeImageFromList(image.readAsBytesSync());
  //   print(decodedImage.width);
  //   print(decodedImage.height);
  //   return [decodedImage.height, decodedImage.width];
  // }
}
// Widget makeDismissable({required Widget child}) => GestureDetector(
//   behavior: HitTestBehavior.opaque,
//   onTap: () => Navigator.of(context).pop(),
//   child: GestureDetector(onTap: () {}, child: child,),
// );
