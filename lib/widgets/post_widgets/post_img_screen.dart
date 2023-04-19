import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/constants.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/cubits/buid_cubit/buid_cubit.dart';
import 'package:kingsfam/cubits/liked_post/liked_post_cubit.dart';
import 'package:kingsfam/models/post_model.dart';
import 'package:kingsfam/repositories/post/post_repository.dart';
import 'package:kingsfam/screens/comment_ui/comment_screen.dart';
import 'package:kingsfam/screens/profile/profile_screen.dart';
import 'package:kingsfam/screens/report_content_screen.dart';
import 'package:kingsfam/widgets/roundContainerWithImgUrl.dart';
import 'package:kingsfam/widgets/snackbar.dart';

import '../../screens/commuinity/community_home/home.dart';

class ImgPost1_1 extends StatefulWidget {
  final Post post;
  const ImgPost1_1({Key? key, required this.post}) : super(key: key);

  @override
  State<ImgPost1_1> createState() => _ImgPost1_1State();
}

class _ImgPost1_1State extends State<ImgPost1_1>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<double> _opacityAnimation;
  bool _isFavorited = false;
  bool showCaptionFull = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _sizeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _opacityAnimation = Tween<double>(begin: 0.5, end: 1).animate(_controller);
  }

  _localLikeAnimation() {
    if (!_isFavorited) {
      setState(() {
        _isFavorited = true;
      });
      _controller.forward(from: 0).whenComplete(() {
        _controller.reverse(from: 1).whenComplete(() {
          setState(() {
            _isFavorited = false;
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
        height: size.height,
        width: size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            _engagmentColumn(),
            SizedBox(height: 10),
            Align(
              alignment: FractionalOffset(0.5, 0.5),
              child: _imgContainer(size),
            ),
            SizedBox(
              height: size.height / 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _cmInfo(),
                  _userInfo(),
                  _captionSection(),
                ],
              ),
            ),
          ],
        ));
  }

  Widget _imgContainer(Size size) {
    return GestureDetector(
      onDoubleTap: () {
        _localLikeAnimation();
        bool isLiked = context
            .read<LikedPostCubit>()
            .state
            .recentlyLikedPostIds
            .contains(widget.post.id!);
        bool isRecetlyLiked = context
            .read<LikedPostCubit>()
            .state
            .likedPostsIds
            .contains(widget.post.id!);
        if (!isLiked && !isRecetlyLiked) {
          context.read<LikedPostCubit>().likePost(post: widget.post);
        }
      },
      child: Stack(
        children: [
          Container(
            height: size.height / 2.2,
            width: size.width,
            decoration: BoxDecoration(
                image: DecorationImage(
              image: CachedNetworkImageProvider(widget.post.imageUrl!),
              fit: BoxFit.cover,
            )),
          ),
          if (_isFavorited) ...[
            Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value,
                      child: Transform.scale(
                        scale: _sizeAnimation.value,
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.amber,
                          size: 200,
                        ),
                      ),
                    );
                  },
                ))
          ],
        ],
      ),
    );
  }

  Widget _engagmentColumn() {
    TextStyle captionS =
        Theme.of(context).textTheme.caption!.copyWith(color: Colors.white);
    bool isLikedPost = context
        .read<LikedPostCubit>()
        .state
        .likedPostsIds
        .contains(widget.post.id);
    bool recentlyLiked = context
        .watch<LikedPostCubit>()
        .state
        .recentlyLikedPostIds
        .contains(widget.post.id);
    String likeCount = recentlyLiked
        ? (widget.post.likes + 1).toString()
        : widget.post.likes.toString();
    return SizedBox(
      height: 45,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                onPressed: () {
                  if (isLikedPost || recentlyLiked) {
                    context
                        .read<LikedPostCubit>()
                        .unLikePost(post: widget.post);
                  } else {
                    context.read<LikedPostCubit>().likePost(post: widget.post);
                  _localLikeAnimation();
                  }
                },
                icon: Icon(
                  Icons.favorite_outline_rounded,
                  color: (isLikedPost || recentlyLiked)
                      ? Colors.amber
                      : Colors.white,
                )),
            SizedBox(height: 10),
            Text(
              likeCount,
              style: captionS,
            ),
            SizedBox(height: 15),
            IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(CommentScreen.routeName,
                      arguments: CommentScreenArgs(post: widget.post));
                },
                icon: Icon(Icons.messenger_outline_outlined,
                    color: Colors.white)),
            SizedBox(height: 15),
            IconButton(
                onPressed: () {
                  _showPostOptions();
                },
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                )),
          ],
        ),
      ),
    );
  }

  Widget _captionSection() {
    TextStyle captionS = Theme.of(context)
        .textTheme
        .caption!
        .copyWith(color: Colors.white, fontStyle: FontStyle.italic);
    String? displayCaption =
        widget.post.caption != null ? widget.post.caption : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
          width: MediaQuery.of(context).size.width / 1.5,
          child: displayCaption != null
              ? GestureDetector(
                  onTap: () {
                    showCaptionFull = true;
                    setState(() {});
                    _showCaptionFullBottomSheet().then((value) {
                      showCaptionFull = false;
                      setState(() {});
                    });
                  },
                  child: Text(
                    widget.post.caption ?? "",
                    style: captionS,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                )
              : SizedBox.shrink()),
    );
  }

  Widget _userInfo() {
    TextStyle captionS =
        Theme.of(context).textTheme.caption!.copyWith(color: Colors.white);
    String? imageUrl = widget.post.author.profileImageUrl;
    String colorP = widget.post.author.colorPref;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(ProfileScreen.routeName,
              arguments: ProfileScreenArgs(
                  userId: widget.post.author.id, initScreen: true));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ContainerWithURLImg(
                imgUrl: imageUrl,
                height: 34,
                width: 34,
                pc: Color(hc.hexcolorCode(colorP))),
            SizedBox(width: 8),
            Text(
              widget.post.author.username,
              style: captionS,
            ),
          ],
        ),
      ),
    );
  }

  Widget _cmInfo() {
    if (widget.post.commuinity == null) return SizedBox.shrink();
    TextStyle captionS =
        Theme.of(context).textTheme.caption!.copyWith(color: Colors.white);
    String? imageUrl = widget.post.commuinity!.imageUrl;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(CommunityHome.routeName,
              arguments:
                  CommunityHomeArgs(cm: widget.post.commuinity!, cmB: null));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(width: .5, color: Colors.white),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(imageUrl),
                      fit: BoxFit.cover,
                    ))),
            SizedBox(width: 8),
            Text(
              widget.post.commuinity!.name,
              style: captionS,
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _showCaptionFullBottomSheet() {
    return showModalBottomSheet(
        backgroundColor: Colors.black26,
        isDismissible: true,
        context: context,
        builder: (context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Icon(
                  Icons.drag_handle_outlined,
                  color: Colors.white38,
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.post.caption ?? "",
                    style: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(color: Colors.white),
                    softWrap: true,
                  ),
                ),
              ),
            ],
          );
        });
  }

  _showPostOptions() {
    return showModalBottomSheet(
        context: context,
        builder: ((context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.post.author.id !=
                  context.read<AuthBloc>().state.user!.uid) ...[
                ListTile(
                  onTap: () {
                    Map<String, dynamic> info = {
                      "userId": widget.post.author.id,
                      "what": "post",
                      "continue": FirebaseFirestore.instance
                          .collection(Paths.posts)
                          .doc(widget.post.id),
                    };
                    Navigator.of(context).pushNamed(
                        ReportContentScreen.routeName,
                        arguments: RepoetContentScreenArgs(info: info));
                    // Navigator.of(context).pushNamed(ReviewContentScreen.routeName, arguments: ReviewContentScreenArgs());
                    //     PostsRepository().reportPost(postId: widget.post.id!, cmId: widget.post.commuinity!.id!).then((value) {
                    //      snackBar(snackMessage: "Post will be reviewed, thank you for helping keep KingsFam safe", context: context);
                    //      Navigator.of(context).pop();

                    //   });
                  },
                  leading:
                      Icon(Icons.report_gmailerrorred, color: Colors.red[400]),
                  title: Text(
                    "Report this post",
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1!
                        .copyWith(color: Colors.red[400]),
                  ),
                ),
                SizedBox(height: 7),
                ListTile(
                  leading: Icon(Icons.block, color: Colors.red[400]),
                  title: Text("Block user",
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1!
                          .copyWith(color: Colors.red[400])),
                  onTap: () {
                    // add userId to systemdb of blocked uids

                    context
                        .read<BuidCubit>()
                        .onBlockUser(widget.post.author.id);

                    snackBar(
                        snackMessage:
                            "KingsFam will hide content from this user.",
                        context: context);
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                )
              ] else ...[
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red[400]),
                  title: Text("Delete this post",
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1!
                          .copyWith(color: Colors.red[400])),
                  onTap: () {
                    context
                        .read<PostsRepository>()
                        .deletePost(post: widget.post)
                        .then((value) {
                      snackBar(
                          snackMessage: "Your post has been removed",
                          context: context,
                          bgColor: Colors.greenAccent);
                    });
                  },
                )
              ],
            ],
          );
        }));
  }
}
