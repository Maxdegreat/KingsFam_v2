import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:kingsfam/extensions/hexcolor.dart';

import 'package:kingsfam/screens/profile/profile_post_view.dart';
import 'package:kingsfam/screens/profile/profile_screen.dart';

import '../models/comment_model.dart';


class CommentLines extends StatefulWidget {
  final Comment comment;
  const CommentLines({Key? key, required this.comment}) : super(key: key);

  @override
  State<CommentLines> createState() => _CommentLinesState();
}

class _CommentLinesState extends State<CommentLines> {

  HexColor hc = HexColor();
  @override
  Widget build(BuildContext context) {
    return _commentLine();
  }

  _commentLine() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
        SizedBox(height: 5),
        _body(),
        ],
      ),
    );
  }

  _header() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(ProfilePostView.routeName, arguments: ProfileScreenArgs(userId: widget.comment.author.id, initScreen: true));
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Color(hc.hexcolorCode(widget.comment.author.colorPref)), width: 1)
            ),
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(widget.comment.author.profileImageUrl),
              radius: 15,
            ),
          ),
    
          SizedBox(width: 5),
    
          Text(
            widget.comment.author.username,
            style: Theme.of(context).textTheme.subtitle1,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  _body() {
    return Container(
              
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(widget.comment.content,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(fontWeight: FontWeight.w500, fontSize: 15)),
              ));
  }
}
