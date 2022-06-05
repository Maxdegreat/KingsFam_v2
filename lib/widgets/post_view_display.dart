/*

  This page handels most of things that include displaying a post
  to see where vidoes and images are defined for the post_view_display look a the 
  bottom of the page
*/

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/widgets/videoPostView16_9.dart';

import 'package:kingsfam/widgets/widgets.dart';

enum postTypeEnum { photo, quote, video }

//
class PostViewDisplay extends StatefulWidget {
  const PostViewDisplay({
    Key? key,
    this.scrollCtrl,
    required this.post,
    required this.isLiked,
    required this.onLike,
    this.recentlyLiked = false,
  }) : super(key: key);

  final ScrollController? scrollCtrl;
  final Post post;
  final bool isLiked;
  final VoidCallback onLike;
  final bool recentlyLiked;

  @override
  _PostViewDisplayState createState() => _PostViewDisplayState();
}

class _PostViewDisplayState extends State<PostViewDisplay> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(ProfileScreen.routeName,
              arguments: ProfileScreenArgs(userId: widget.post.author.id)),
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: FancyListTile(
              username: widget.post.author.username,
              imageUrl: widget.post.author.profileImageUrl,
              onTap: () {},
              isBtn: false,
              BR: 5,
              height: 16,
              width: 18,
            ),
          ),
        ),
        /*
          we want to show 3 options as of oct 22 2021
          opt 1: post.videourl
          opt 2: post.imageUrl
          opt 3: post.quote
          we can acheieve this with turnarry operatos. 
          we alredy have methods for each display so just 
          implement the logic to display it
          pending on what the post contains
        */
        widget.post.videoUrl != null
            ? GestureDetector(
                onDoubleTap: widget.onLike,
                child: VideoPostView16_9(post: widget.post, userr: widget.post.author, videoUrl: widget.post.videoUrl!, scrollCtrl: widget.scrollCtrl!,) )
            : widget.post.imageUrl != null
                ? imageDisplay()
                : SizedBox.shrink(),
        Container(
          child: widget.post.quote != null
              ? quoteDisplay(context)
              : SizedBox.shrink(),
        ),
        Stack(children: [
          Container(
              height: MediaQuery.of(context).size.height / 9,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.black),
              child: Padding(
                padding: EdgeInsets.only(left: 15),
                child: widget.post.caption != null ? RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        style: Theme.of(context).textTheme.bodyText1,
                        children: [
                          // TextSpan(text: '${post.author.username}. '),
                          TextSpan(
                              text: widget.post.caption != null
                                  ? '${widget.post.caption}'
                                  : null,
                              style: TextStyle(color: Colors.grey))
                        ])) : SizedBox.shrink(),
              )),
          Positioned(
              bottom: 23,
              left: 15,
              child: Row(
                children: [
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: widget.isLiked ? Colors.red[50] : Colors.black,
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(
                        width: 1,
                        color: widget.isLiked ?  Colors.red[900]! : Colors.white
                      )
                    ),
                    child: Stack(
                      children: [
                       Positioned( 
                         top: -5.5,
                         left: -8.5,
                         child: IconButton(
                        onPressed: widget.onLike,
                        icon: !widget.isLiked
                            ? FaIcon(
                                FontAwesomeIcons.heartBroken,
                                size: 20,
                                color: Colors.white,
                              )
                            : FaIcon(FontAwesomeIcons.solidHeart,
                                size: 20, color: Colors.red[400])), )
                       
                      ],
                    ),
                  ),
                  
                  
                ],
              )),
          Positioned(
              bottom: 23,
              left: 60,
              child: Row(
                children: [
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(color: Colors.white)
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: FaIcon(
                        FontAwesomeIcons.comment,
                        size: 20,
                      )),
                  )
                ],
              )),
          Positioned(
              bottom: 1.0,
              left: 15,
              child: Row(
                children: [
                  //Text(widget.post.date.timeAgo())
                  Text("post view display")
                ],
              )),
        ])
      ],
    );
  }

  Padding quoteDisplay(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 80),
            child: GestureDetector(
              onDoubleTap: widget.onLike,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 12.0),
                    child: Flexible(
                      child: Text(
                        // post.quote!.length >= 20 ? post.quote!.substring(0, 20) + "\n" : null,
                        widget.post.quote!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ),
                ],
              ),
            )));
  }

  Padding imageDisplay() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 500),
        child: GestureDetector(
          onDoubleTap: widget.onLike,
          child: Container(
              width: double.infinity,
              child: DecoratedBox(
                child: CachedNetworkImage(imageUrl: widget.post.imageUrl!),
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.contain,
                        //if error on loading image throw here
                        image:
                            CachedNetworkImageProvider(widget.post.imageUrl!))),
              )),
        ),
      ),
    );
  }
}

