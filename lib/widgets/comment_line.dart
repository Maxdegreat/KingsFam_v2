import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kingsfam/extensions/hexcolor.dart';
import 'package:kingsfam/models/chat_model.dart';
import 'package:kingsfam/screens/comment_ui/bloc/comment_bloc.dart';
import 'package:kingsfam/widgets/message_bubbles.dart';
import 'package:kingsfam/widgets/profile_header_info.dart';

import '../models/comment_model.dart';
import '../models/message_model.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.00),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MessageBubble(
            passedColor: Color(hc.hexcolorCode('#40444b ')), 
            chat: Chat.empty, 
            message: Message.empty().copyWith(date: widget.comment.date, 
            text: widget.comment.content, imageUrl: null, 
            thumbnailUrl: null, 
            videoUrl: null, 
            reply: null, 
            sender: widget.comment.author, ),
          )
        ],
      ),
    );
  }
}
