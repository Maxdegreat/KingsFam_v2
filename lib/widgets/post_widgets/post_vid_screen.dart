import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kingsfam/models/post_model.dart';
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
    log("post vid url: " + widget.post.videoUrl.toString());
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

  @override
  Widget build(BuildContext context) {
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
            onDoubleTap: () {},
            child: VideoPlayerWidget(controller: videoPlayerController!),
          ), 
        ),
      ),

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
    );
  }

  Widget _engagmentColumn() {
    TextStyle captionS = Theme.of(context).textTheme.caption!.copyWith(color: Colors.white);
    return Positioned(
      right: 0,
      bottom: 50,
      child: SizedBox(
        height: 45,
        child: Align(
          alignment: Alignment.bottomRight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              
                IconButton(
                  onPressed: () {}, 
                  icon: Icon(Icons.favorite, size: 20, color: Colors.white,)
                ),
              
                SizedBox(height: 10),
              
                Text(widget.post.likes.toString(), style: captionS,),
              
                SizedBox(height: 15),
                
                IconButton(
                  onPressed: ()  {}, 
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
      ),
    );
  }


  Widget _captionSection() {
    TextStyle captionS = Theme.of(context).textTheme.caption!.copyWith(color: Colors.white);
    String? displayCaption = widget.post.caption != null
      ? widget.post.caption
      : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: MediaQuery.of(context).size.width / 1.5,
        child: displayCaption != null 
        ? GestureDetector(
          onTap: () {},
          child: Text(
            "This is a dummy caption for testing purposes, and this a longer caption for more testing reasons. you best bet im stretching this.", // widget.post.caption ?? "",
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
      );
  }

  Widget _cmInfo() {
    if (widget.post.commuinity == null) return SizedBox.shrink();
    TextStyle captionS = Theme.of(context).textTheme.caption!.copyWith(color: Colors.white);
    String? imageUrl = widget.post.commuinity!.imageUrl;
    return
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
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
            
            Text(widget.post.commuinity!.name, style: captionS,),
          ],
        ),
      );
  }

}