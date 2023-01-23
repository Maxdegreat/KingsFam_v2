import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/cubits/buid_cubit/buid_cubit.dart';

import 'package:kingsfam/extensions/hexcolor.dart';

import 'package:kingsfam/screens/profile/profile_post_view.dart';
import 'package:kingsfam/screens/profile/profile_screen.dart';
import 'package:kingsfam/screens/report_content_screen.dart';
import 'package:kingsfam/widgets/hide_content/hide_content_full_screen_post.dart';

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
      child: 
      
      context.read<BuidCubit>().state.buids.contains(widget.comment.author.id) 

      ? HideContent.textContent(Theme.of(context).textTheme, () {context.read<BuidCubit>().onBlockUser(widget.comment.author.id); Navigator.of(context).pop();})

      : Column(
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
        Navigator.of(context).pushNamed(ProfileScreen.routeName, arguments: ProfileScreenArgs(userId: widget.comment.author.id, initScreen: true));
      },
      onLongPress: () {
         Map<String, dynamic> info = {
          "userId" : widget.comment.author.id,
          "what" : "comment",
          "continue": FirebaseFirestore.instance.collection(Paths.posts).doc(widget.comment.postId).collection(Paths.comments).doc(widget.comment.id),                 
        };
        Navigator.of(context).pushNamed(ReportContentScreen.routeName, arguments: RepoetContentScreenArgs(info: info));
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
