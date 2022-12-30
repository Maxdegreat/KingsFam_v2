import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/cubits/liked_post/liked_post_cubit.dart';
import 'package:kingsfam/models/post_model.dart';
import 'package:kingsfam/screens/comment_ui/comment_screen.dart';
import 'package:kingsfam/screens/profile/profile_screen.dart';

import '../../screens/commuinity/community_home/home.dart';

class ImgPost1_1 extends StatefulWidget {
  final Post post;
  const ImgPost1_1({Key? key, required this.post}) : super(key: key);

  @override
  State<ImgPost1_1> createState() => _ImgPost1_1State();
}

class _ImgPost1_1State extends State<ImgPost1_1> {

  bool showCaptionFull = false;

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
)

    );
  }

  Widget _imgContainer(Size size) {
    return GestureDetector(
      onDoubleTap: () {
        bool isLiked = context.read<LikedPostCubit>().state.recentlyLikedPostIds.contains(widget.post.id!);
        bool isRecetlyLiked = context.read<LikedPostCubit>().state.likedPostsIds.contains(widget.post.id!);
        if (!isLiked && !isRecetlyLiked) {
          context.read<LikedPostCubit>().likePost(post: widget.post);
        }
      },
      child: Container(
        height: size.height / 2.2,
        width: size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(widget.post.imageUrl!),
            fit: BoxFit.cover,
          )
        ),
      ),
    );
  }

  Widget _engagmentColumn() {
    TextStyle captionS = Theme.of(context).textTheme.caption!.copyWith(color: Colors.white);
    bool isLikedPost = context.read<LikedPostCubit>().state.likedPostsIds.contains(widget.post.id);
    bool recentlyLiked = context.watch<LikedPostCubit>().state.recentlyLikedPostIds.contains(widget.post.id);
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
                    context.read<LikedPostCubit>().unLikePost(post: widget.post);
                  } else {
                    context.read<LikedPostCubit>().likePost(post: widget.post);
                  }
                }, 
                icon: Icon(Icons.favorite_outline_rounded, color: recentlyLiked ? Colors.amber : Colors.white,)
              ),
            
              SizedBox(height: 10),
            
              Text(likeCount, style: captionS,),
            
              SizedBox(height: 15),
              
              IconButton(
                onPressed: ()  {
                  Navigator.of(context).pushNamed(CommentScreen.routeName,arguments: CommentScreenArgs(post: widget.post));
                }, 
                icon: Icon(Icons.messenger_outline_outlined, color: Colors.white)
              ),
            
              SizedBox(height: 15),
            
              IconButton(
                onPressed: () {}, 
                icon: Icon(Icons.more_vert, color: Colors.white,) 
              ),
            
          ],
        ),
      ),
    );
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