import 'dart:developer';

import 'package:kingsfam/extensions/date_time_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/extensions/hexcolor.dart';
import 'package:kingsfam/widgets/comment_line.dart';
import 'bloc/comment_bloc.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/post/post_repository.dart';
import 'package:kingsfam/widgets/widgets.dart';

// args
class CommentScreenArgs {
  final Post post;
  CommentScreenArgs({required this.post});
}

class CommentScreen extends StatefulWidget {
  const CommentScreen({Key? key, required this.post}) : super(key: key);
  final Post post;
  // route name
  static const String routeName = 'CommentScreenRouteName';
  // make route function
  static Route route({required CommentScreenArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => BlocProvider<CommentBloc>(
              create: (_) => CommentBloc(
                  postsRepository: context.read<PostsRepository>(),
                  authBloc: context.read<AuthBloc>())
                ..add(CommentFtechComments(post: args.post)),
              child: CommentScreen(post: args.post),
            ));
  }

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  HexColor hc = HexColor();
  Comment? commentReplyingTo = null;
  final TextEditingController _messageController = TextEditingController();
  double textHeight = 35;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Comments"),
      ),
      body: SafeArea(
          child: BlocConsumer<CommentBloc, CommentState>(
        listener: (context, state) {
          if (state.status == CommentStatus.error) {
            snackBar(
                snackMessage: "${state.failure.message}",
                context: context,
                bgColor: Colors.red[400]);
            log("!!!!!!!!!!!!!!!!!!" + "commentScreen" + "!!!!!!!!!!!!!!!!!!!");
            log("error: " + state.failure.code);
          }
        },
        builder: (context, state) {
          return _buildComment(state);
        },
      )),
    );
  }

  _buildComment(CommentState state) {
    return Scaffold(
      body: commentLoadedWidget(state.comments, state),
    );
  }

  Widget commentLoadedWidget(List<Comment?> comments, CommentState state) {
    TextStyle style = TextStyle(color: Colors.grey);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        state.status == CommentStatus.loading
            ? LinearProgressIndicator()
            : SizedBox.shrink(),
        Expanded(
          child: ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            reverse: true,
            itemCount: comments.length,
            itemBuilder: (BuildContext context, int index) {
              Comment? comment = comments[index];
              return comment != null
                  ? Column(
                      children: [
                        CommentLines(comment: comment),
                        _replyBtns(comment: comment, postId: widget.post.id!),
                        _showReplys(state: state, comment: comment),
                      ],
                    )
                  : Text("ops, something went wrong");
            },
          ),
        ),
        Column(
          children: [
            commentReplyingTo == null
                ? SizedBox.shrink()
                : Container(
                    child: Text(
                      "replying to ~ " + commentReplyingTo!.author.username,
                      overflow: TextOverflow.ellipsis,
                    ),
                    color: Color(hc.hexcolorCode('#141829')),
                    height: 15,
                    width: double.infinity),
            Row(children: [
              Expanded(
                  child: Container(
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: TextFormField(
                      validator: (val) {
                        if (val != null && val.length > 200) {
                          return "Keep each comment to less than 200 chars. Thanks fam.";
                        }
                      },
                      controller: _messageController,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(fontSize: 18),
                      keyboardType: TextInputType.multiline,
                      decoration:
                          InputDecoration(hintText: "Add A Comment Fam..."),
                      maxLines: null,
                      expands: true,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (messageText) {
                        if (messageText.length >= 29)
                          setState(() => textHeight = 50.0);
                        else if (messageText.length >= 87)
                          setState(() => textHeight = 65.0);
                        else
                          setState(() => textHeight = 30.0);
                      },
                    ),
                  ),
                ),
              )),
              IconButton(
                  onPressed: () {
                    String content = _messageController.text.trim();
                    if (content.isNotEmpty) {
                      if (commentReplyingTo != null) {
                        content = "@" +
                            commentReplyingTo!.author.username +
                            " " +
                            _messageController.text.trim();
    
                        context.read<CommentBloc>().onAddReply(
                            comment: commentReplyingTo!,
                            content: content,
                            post: widget.post);
                        context
                            .read<CommentBloc>()
                            .onViewReplys(commentReplyingTo!, widget.post.id!)
                            .then((_) => setState(() {}));
                        commentReplyingTo = null;
                        setState(() {});
                      } else {
                        context.read<CommentBloc>().add(CommentPostComment(
                            comments: comments,
                            content: content,
                            post: widget.post));
                      }
                      _messageController.clear();
                    }
                  },
                  icon: Icon(Icons.send))
            ]),
          ],
        )
      ]),
    );
  }

  replyBtn(Comment comment) {
    return TextButton(
        onPressed: () {
          commentReplyingTo = comment;
          context.read<CommentBloc>().onReply();
        },
        child: Text("reply"));
  }

  viewReplyBtn({required Comment comment, required String postId}) {
    return TextButton(
        onPressed: () {
          context.read<CommentBloc>().onViewReplys(comment, postId);
        },
        child: Text("view replys"));
  }

  _replyBtns({required Comment comment, required String postId}) {
    return Row(
      children: [
        replyBtn(comment),
        viewReplyBtn(comment: comment, postId: postId),
      ],
    );
  }

  _showReplys({required Comment comment, required CommentState state}) {
    if (state.replys.containsKey(comment.id!) &&
        state.replys[comment.id]!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
        child: Column(
          children: state.replys[comment.id!]!.map((reply) {
            return Column(
              children: [
                CommentLines(comment: reply!),
                replyBtn(comment)
                //_replyBtns(comment: comment, postId: widget.post.id!)
              ],
            );
          }).toList(),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}// end of stful
