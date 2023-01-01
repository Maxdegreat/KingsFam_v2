import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/cubits/cubits.dart';
import 'package:kingsfam/models/post_model.dart';
import 'package:kingsfam/repositories/post/post_repository.dart';
import 'package:kingsfam/screens/comment_ui/comment_screen.dart';
import 'package:kingsfam/screens/commuinity/community_home/home.dart';
import 'package:kingsfam/screens/profile/profile_screen.dart';
import 'package:kingsfam/widgets/snackbar.dart';
import 'package:kingsfam/widgets/videos/video_player.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

// view needs : Post

class PostFullVideoView16_9 extends StatefulWidget {
  final Post post;
  const PostFullVideoView16_9({Key? key, required this.post}) : super(key: key);

  @override
  State<PostFullVideoView16_9> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<PostFullVideoView16_9> {

  late VideoPlayerController? videoPlayerController;

  @override
  void initState() {

    videoPlayerController = new VideoPlayerController.network(widget.post.videoUrl!);

    videoPlayerController!
      ..addListener(() {
        setState(() {});
      })
      ..setLooping(true)
      ..initialize().then((_) {
        videoPlayerController!.play();
      });
    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController!.dispose();
    super.dispose();
  }

  bool showCaptionFull = false;

  @override
  Widget build(BuildContext context) {

    Set<String?> l  = context.read<LikedPostCubit>().state.likedPostsIds;
    log( "This post is contained in the likedPostIds: " + l.contains(widget.post.id).toString() );
    Size size = MediaQuery.of(context).size;

    return Stack(

      children: [
        Container(
        height: size.height,
        width: size.width,
        child: VisibilityDetector(
          key: ObjectKey(widget.post),
    
    
          onVisibilityChanged: (vis) {
            if (vis.visibleFraction == 0) {
              videoPlayerController!.pause();
            }
          },
    
    
          child: GestureDetector(
            onDoubleTap: () {
              context.read<LikedPostCubit>().likePost(post: widget.post);
              // context.read<LikedPostCubit>().likePost(post: widget.post);
            },
            child: VideoPlayerWidget(controller: videoPlayerController!),
          ), 
        ),
      ),
      if (!showCaptionFull) ... [

       _engagmentColumn(),
        
          Positioned(
            bottom: 10,
            left: 10,
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
          )
      ] 
    ],
    );
  }

  Widget _engagmentColumn() {
    TextStyle captionS = Theme.of(context).textTheme.caption!.copyWith(color: Colors.white);
    bool isLikedPost = context.read<LikedPostCubit>().state.likedPostsIds.contains(widget.post.id);
    log("The val of bool checking if postid is contained is: " + isLikedPost.toString());
    bool recentlyLiked = context.read<LikedPostCubit>().state.recentlyLikedPostIds.contains(widget.post.id);
    String likeCount = recentlyLiked
      ? (widget.post.likes + 1).toString() 
      : widget.post.likes.toString();
    return Positioned(
      right: 0,
      top: 0,
      bottom: 70,
      child: SizedBox(
        height: 45,
        child: Align(
          alignment: Alignment.bottomRight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
                IconButton(
                  onPressed: () {
                    if (isLikedPost || recentlyLiked) {
                      context.read<LikedPostCubit>().unLikePost(post: widget.post);
                    } else {
                      context.read<LikedPostCubit>().likePost(post: widget.post);
                    }
                  }, 
                  icon: Icon(Icons.favorite_outline_rounded, color: (isLikedPost || recentlyLiked) ? Colors.amber : Colors.white,)
                ),
              
                SizedBox(height: 7),
              
                Text(likeCount, style: captionS,),
              
                SizedBox(height: 15),
                
                IconButton(
                  onPressed: ()  {
                    Navigator.of(context).pushNamed(CommentScreen.routeName,arguments: CommentScreenArgs(post: widget.post));
                  }, 
                  icon: Icon(Icons.messenger_outline_outlined, color: Colors.white)
                ),
                
                SizedBox(height: 7),

                Text(widget.post.commentCount.toString(), style: captionS,),
                            
                SizedBox(height: 15),
              
                IconButton(
                  onPressed: () {
                    _showPostOptions();
                  }, 
                  icon: Icon(Icons.more_vert, color: Colors.white,) 
                ),
            ],
          ),
        ),
      ),
    );
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
            ListTile(
              onTap: () {
                PostsRepository().reportPost(postId: widget.post.id!, cmId: widget.post.commuinity!.id!);
                Future.delayed(Duration(seconds: 10)).then((value) => snackBar(snackMessage: "Post will be reviewed", context: context));
              },
              leading: Icon(Icons.report_gmailerrorred, color: Colors.red[400]),
              title: Text("Report this post", style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.red[400]),),
            )
          ],
        );
      }
    ));
  }

  Widget _captionSection() {
    TextStyle captionS = Theme.of(context).textTheme.caption!.copyWith(color: Colors.white, fontStyle: FontStyle.italic);
    String? displayCaption = widget.post.caption != null
      ? widget.post.caption
      : null;
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
        : SizedBox.shrink()
      ),
    );
  }

  Widget _userInfo() {
    TextStyle captionS = Theme.of(context).textTheme.caption!.copyWith(color: Colors.white);
    String? imageUrl = widget.post.author.profileImageUrl;
    return
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(ProfileScreen.routeName, arguments: ProfileScreenArgs(userId: widget.post.author.id, initScreen: true));
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(imageUrl),
              ),
        
              SizedBox(width: 8),
              
              Text(widget.post.author.username, style: captionS,),
            ],
          ),
        ),
      );
  }

  Widget _cmInfo() {
    if (widget.post.commuinity == null) return SizedBox.shrink();
    TextStyle captionS = Theme.of(context).textTheme.caption!.copyWith(color: Colors.white);
    String? imageUrl = widget.post.commuinity!.imageUrl;
    return
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(CommunityHome.routeName, arguments: CommunityHomeArgs(cm: widget.post.commuinity!, cmB: null));
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
                  border: Border.all(width: 2, color: Colors.white),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(imageUrl), 
                    fit: BoxFit.cover,
                  )
                )
              ),
        
              SizedBox(width: 8),
              
              Text(widget.post.commuinity!.name, style: captionS,),
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
              child: Icon(Icons.drag_handle_outlined, color: Colors.white38,),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.post.caption ?? "",
                  style: Theme.of(context).textTheme.caption!.copyWith(color: Colors.white),
                  softWrap: true,
                ),
              ),
            ),
          ],
        );
      }
    );
  }
}