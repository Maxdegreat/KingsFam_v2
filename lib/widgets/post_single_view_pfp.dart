import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';

import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/post/post_repository.dart';

import 'package:kingsfam/screens/screens.dart';

import 'package:kingsfam/widgets/commuinity_pf_image.dart';
import 'package:kingsfam/widgets/profile_image.dart';
import 'package:kingsfam/widgets/snackbar.dart';
import 'package:kingsfam/widgets/videos/videoPostView16_9.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class PostSingleViewPfp extends StatefulWidget {
  final Post post;
  final bool isLiked;
  final VoidCallback onLike;
  final bool recentlyLiked;

  PostSingleViewPfp({
    this.recentlyLiked = false,
    required this.post,
    required this.isLiked,
    required this.onLike,
  });

  @override
  _PostSingleViewState createState() => _PostSingleViewState();
}

class _PostSingleViewState extends State<PostSingleViewPfp> {
  late VideoPlayerController vidCtrl;

  @override
  void initState() {
    if (widget.post.videoUrl != null) {
      vidCtrl = VideoPlayerController.network(widget.post.videoUrl!);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        userPicAndName(
            name: widget.post.author.username,
            imgurl: widget.post.author.profileImageUrl),
        viewCommuinity(commuinity: widget.post.commuinity),
        captionBox(caption: widget.post.caption, size: size),
        contentContainer(post: widget.post, size: size),
        interactions()
      ],
    );
  }

  Widget viewCommuinity({required Church? commuinity}) {
    return commuinity != null
        ? Padding(
            padding: const EdgeInsets.only(top: 7.0, right: 12.0, left: 12.0),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(3)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed(
                      CommuinityScreen.routeName,
                      arguments: CommuinityScreenArgs(commuinity: commuinity)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ok add the commuinity image
                      commuinity_pf_img(commuinity.imageUrl, 25, 25),
                      SizedBox(width: 7),
                      // add the commuinity name
                      Text(commuinity.name,
                          style:
                              TextStyle(color: Colors.grey[350], fontSize: 17))
                    ],
                  ),
                ),
              ),
            ),
          )
        : Text("No Commuinity bruv");
  }

  Widget interactions() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 5),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: 10),
              widget.isLiked
                  ? Icon(Icons.thumb_up, color: Colors.green)
                  : Icon(Icons.thumb_up),
              SizedBox(width: 5),
              Container(
                //margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: .5),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(7)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Text(
                      "${widget.recentlyLiked ? widget.post.likes + 1 : widget.post.likes}"),
                ),
              ),
              SizedBox(
                width: 15,
              ),
              IconButton(
                  // onPressed: () => commentSheet(post: widget.post),
                  onPressed: () => Navigator.of(context).pushNamed(
                      CommentScreen.routeName,
                      arguments: CommentScreenArgs(post: widget.post)),
                  icon: Icon(Icons.message)),
              SizedBox(width: 5),
              Container(
                //margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: .5),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(7)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Text("Comments"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget userPicAndName({required String name, required String imgurl}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(ProfileScreen.routeName,
            arguments: ProfileScreenArgs(
                userId: widget.post.author.id, vidCtrl: vidCtrl)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ProfileImage(radius: 25, pfpUrl: imgurl),
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
            widget.post.author.id == context.read<AuthBloc>().state.user!.uid
                ? IconButton(
                    onPressed: () => _postSettings(),
                    icon: Icon(Icons.more_vert))
                : SizedBox.shrink()
          ],
        ),
      ),
    );
  }

  _postSettings() {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
              height: 120,
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                            .deletePost(post: widget.post);
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

  Widget captionBox({required String? caption, required Size size}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10.0,
      ),
      child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: size.height / 1.2, minWidth: size.width / 1.5),
          child: caption != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    caption,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w400),
                  ),
                )
              : SizedBox.shrink()),
    );
  }

  Widget contentContainer({required Post post, required Size size}) {
    if (post.imageUrl != null) {
      return GestureDetector(
        onDoubleTap: widget.onLike,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: size.height / 1.7),
          child: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: CachedNetworkImageProvider(post.imageUrl!),
                    fit: BoxFit.fitWidth)),
          ),
        ),
      );
    } else if (post.videoUrl != null) {
      bool playNow = false;
      return VisibilityDetector(
        key: ObjectKey(widget.post),
        onVisibilityChanged: (vis) {
          if (vis.visibleFraction == 1) {
            setState(() {
              playNow = true;
            });
          } else {
            vidCtrl.pause();
          }
        },
        child: GestureDetector(
          onDoubleTap: widget.onLike,
          child: AspectRatio(
              aspectRatio: 9 / 16,
              child: Align(
                alignment: Alignment.center,
                child: VideoPostView16_9(
                  post: widget.post,
                  userr: widget.post.author,
                  videoUrl: widget.post.videoUrl!,
                  playVidNow: playNow,
                  controller: vidCtrl,
                ),
              )),
        ),
      );
    } else if (post.quote != null) {
      return Text("caption ${post.quote}");
    } else {
      return Text("contennt container is empty???");
    }
  }
}
