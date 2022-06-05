import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/widgets/videoPostView16_9.dart';
import 'package:kingsfam/widgets/widgets.dart';

class ColumnOfPost extends StatelessWidget {
  const ColumnOfPost({
    Key? key,
    required this.posts, //remove later its useless.....
    required this.post,
    // for likes
    required this.isLiked,
    required this.onLike,
    required this.recentlyLiked,
  }) : super(key: key);

  final List<Post?> posts;
  final Post? post;

  // for likes
  final bool isLiked;
  final VoidCallback onLike;
  final bool recentlyLiked;

  @override
  Widget build(BuildContext context) {
    return Column(
      //mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ========================================================================== 1 add the list tile
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(ProfileScreen.routeName,
              arguments: ProfileScreenArgs(userId: post!.author.id)),
          child: FancyListTile(
            username: post!.author.username,
            imageUrl: post!.author.profileImageUrl,
            onTap: () {},
            isBtn: false,
            BR: 5,
            height: 16,
            width: 18,
          ),
          // ========================================================================= 2 add the actual post content
        ),
        SizedBox(height: 5),

        GestureDetector(
          onDoubleTap: onLike,
          child: Container(
            child: // 1 if the post.imageUrl is not null
                post!.imageUrl != null
                    ? imageDisplay()
                    // 2 if post.videoUrl is not null
                    : post!.videoUrl != null
                        ?  VideoPostView16_9(post: post!, userr: post!.author, videoUrl: post!.videoUrl!,) 
                        // 3 else quote is not null
                        : QuoteDisplay(
                            quote: post!.quote!,
                          ),
          ),
        ),
        //===================================================container for the caption, likes, comments, nd timespamp
        ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: 105, maxWidth: double.infinity),
          child: post!.caption!.length < 2
              ? Container(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 10.0),
                        Text(post!.caption!),
                        SizedBox(height: 10),
                        //add like and comment icons / functionality
                        Container(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                                onPressed: () {},
                                icon: isLiked
                                    ? Icon(
                                        Icons.favorite,
                                        color: Colors.deepPurple[700],
                                      )
                                    : Icon(Icons.favorite)),
                            Text(recentlyLiked
                                ? "${post!.likes + 1}"
                                : "${post!.likes}"),
                            SizedBox(
                                width: MediaQuery.of(context).size.width / 5),
                            IconButton(
                                onPressed: () {},
                                icon: FaIcon(FontAwesomeIcons.comment)),
                            SizedBox(
                                width: MediaQuery.of(context).size.width / 5),
                            //Text(post!.date.timeAgo())
                            Text("post columns")
                          ],
                        ))
                      ]))
              :

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

              Container(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //add like and comment icons / functionality
                        Container(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                                onPressed: () {},
                                icon: isLiked
                                    ? Icon(
                                        Icons.favorite,
                                        color: Colors.deepPurple[700],
                                      )
                                    : Icon(Icons.favorite)),
                            Text(recentlyLiked
                                ? "${post!.likes + 1}"
                                : "${post!.likes}"),
                            SizedBox(
                                width: MediaQuery.of(context).size.width / 5),
                            IconButton(
                                onPressed: () {},
                                icon: FaIcon(FontAwesomeIcons.comment)),
                            SizedBox(
                                width: MediaQuery.of(context).size.width / 5),
                            //Text(post!.date.timeAgo())
                            Text("post columns")
                          ],
                        ))
                      ]))
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

          , //=================================add second container if there is no caption
        )
      ],
    );
  }

  Padding imageDisplay() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 900),
        child: Container(
            width: double.infinity,
            child: DecoratedBox(
              child: CachedNetworkImage(imageUrl: post!.imageUrl!),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.contain,
                      //if error on loading image throw here
                      image: CachedNetworkImageProvider(post!.imageUrl!))),
            )),
      ),
    );
  }
}
