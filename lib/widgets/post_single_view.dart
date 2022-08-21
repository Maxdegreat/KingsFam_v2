import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';

import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/post/post_repository.dart';

import 'package:kingsfam/screens/screens.dart';

import 'package:kingsfam/extensions/date_time_extension.dart';

import 'package:kingsfam/widgets/commuinity_pf_image.dart';
import 'package:kingsfam/widgets/profile_image.dart';
import 'package:kingsfam/widgets/videos/videoPostView16_9.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostSingleView extends StatefulWidget {
  final Post post;
  final bool isLiked;
  final VoidCallback onLike;
  final bool recentlyLiked;
  final ScrollController? scrollController;

  PostSingleView({
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
  void updateVisibility() {
    if (widget.post.imageUrl != null) {
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
    updateVisibility();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        contentContainer(post: widget.post, size: size),
        _visible ? blackOverLay() : SizedBox.shrink(),
        Positioned.fill(
            child: userPicAndName(
                name: widget.post.author.username,
                imgurl: widget.post.author.profileImageUrl)),
        Positioned.fill(
            child: viewCommuinity(commuinity: widget.post.commuinity)),
        // captionBox(caption: widget.post.caption, size: size),
        Positioned.fill(child: interactions()),
        Positioned.fill(
            child: showCaptions(
                caption: widget.post.caption,
                author: widget.post.author.username))
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

  Widget viewCommuinity({required Church? commuinity}) {
    return commuinity != null
        ? Stack(children: [
            _visible
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
                                CommuinityScreen.routeName,
                                arguments: CommuinityScreenArgs(
                                    commuinity: commuinity)),
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
                                  style: TextStyle(
                                      color: Colors.grey[350], fontSize: 17),
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

  Widget interactions() {
    return Stack(children: [
      // Positioned.fill(child: child)
      Positioned(
          bottom: 310,
          right: 20,
          child: Container(
            width: 80,
            child: widget.isLiked
                ? Icon(Icons.thumb_up, color: Colors.green)
                : Icon(Icons.thumb_up),
          )),
      Positioned(
        bottom: 270,
        right: 20,
        child: SizedBox(
          width: 80,
          child: Center(
            child: Container(
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
          ),
        ),
      ),
      Positioned(
        bottom: 220,
        right: 20,
        child: Container(
          width: 80,
          child: IconButton(
              // onPressed: () => commentSheet(post: widget.post),
              onPressed: () => Navigator.of(context).pushNamed(
                  CommentScreen.routeName,
                  arguments: CommentScreenArgs(post: widget.post)),
              icon: Icon(Icons.message)),
        ),
      ),
      Positioned(
          bottom: 180,
          right: 20,
          child: Container(
              //margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: .5),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(7)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Text("Comments"),
              )))
    ]);
  }

  Widget userPicAndName({required String name, required String imgurl}) {
    return Stack(
      children: [
        Positioned(
          top: 15,
          left: 0,
          right: 30,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(
                  ProfileScreen.routeName,
                  arguments: ProfileScreenArgs(userId: widget.post.author.id)),
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
                  widget.post.author.id ==
                          context.read<AuthBloc>().state.user!.uid
                      ? IconButton(
                          onPressed: () => _postSettings(),
                          icon: Icon(Icons.more_vert))
                      : SizedBox.shrink()
                ],
              ),
            ),
          ),
        ),
      ],
    );
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
                            .deletePost(post: widget.post);
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

  Widget contentContainer({required Post post, required Size size}) {
    if (post.imageUrl != null) {
      return GestureDetector(
        onTap: () {
          if (_visible)
            setState(() => _visible = false);
          else if (_wasEverVisible && !_visible)
            setState(() => _visible = true);
        },
        onDoubleTap: widget.onLike,
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
    } else if (post.videoUrl != null) {
      return GestureDetector(
        onDoubleTap: widget.onLike,
        child: Align(
          alignment: Alignment.center,
          child: VideoPostView16_9(
            post: widget.post,
            userr: widget.post.author,
            videoUrl: widget.post.videoUrl!,
            playVidNow: true,
          ),
        ),
      );
    } else if (post.quote != null) {
      return Text("caption ${post.quote}");
    } else {
      return Text("contennt containe is empty???");
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

  Container _captionTextBox(String caption, String author, double size) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      height: size + 25,
      width: double.infinity,
      child: Stack(children: [
        Positioned(
          bottom: 10,
          right: 30,
          left: 0,
          child: Container(
            height: size,
            width: width,
            color: Colors.black54,
          ),
        ),
        Positioned(
            bottom: 10,
            right: 30,
            left: 0,
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  TextSpan(
                    text: widget.post.date.timeAgo().toString() + '\n',
                    style: GoogleFonts.adventPro(fontWeight: FontWeight.w700, fontSize: 19, color: Colors.white)
                  ),
                  TextSpan(
                      text:  author + " ~ " + caption,
                      style: GoogleFonts.adventPro(fontWeight: FontWeight.w900, fontSize: 19, color: Colors.white)),
                ],
              ),
            ))
      ]),
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