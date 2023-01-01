import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kingsfam/extensions/hexcolor.dart';
import 'package:kingsfam/models/chat_model.dart';
import 'package:kingsfam/screens/comment_ui/bloc/comment_bloc.dart';
import 'package:kingsfam/screens/profile/profile_post_view.dart';
import 'package:kingsfam/screens/profile/profile_screen.dart';
import 'package:kingsfam/widgets/message_bubbles.dart';
import 'package:kingsfam/widgets/profile_header_info.dart';

import '../models/comment_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(),
      SizedBox(height: 5),
      _body(),
      ],
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
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(widget.comment.author.profileImageUrl),
            radius: 15,
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
    Text(
      widget.comment.content,
      style: Theme.of(context).textTheme.caption,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
    );
  }

}
