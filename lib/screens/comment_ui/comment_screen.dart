import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:kingsfam/extensions/date_time_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/extensions/hexcolor.dart';
import 'package:kingsfam/screens/commuinity/bloc/commuinity_bloc.dart';
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

bool canPost = false;

class _CommentScreenState extends State<CommentScreen> {
  HexColor hc = HexColor();
  Comment? commentReplyingTo = null;
  final TextEditingController _messageController = TextEditingController();
  double textHeight = 35;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).iconTheme.color,
            )),
        title: Text(
          "Comments",
          style: Theme.of(context).textTheme.bodyText1,
        ),
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
                        // _replyBtns(comment: comment, postId: widget.post.id!),
                        // _showReplys(state: state, comment: comment),
                      ],
                    )
                  : Text("ops, something went wrong");
            },
          ),
        ),
       _bottomTf(),
      ]),
    );
  }

  _bottomTf() {
    String? imageUrl = context.read<CommuinityBloc>().state.currUserr.profileImageUrl;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: CachedNetworkImageProvider(imageUrl),
        ),

        SizedBox(width: 7),

        TextFormField(
          controller: _messageController,
          keyboardType: TextInputType.multiline,
          maxLines: 4,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "comment",
            hintStyle: Theme.of(context).textTheme.caption,
            focusColor: Colors.green,
          ),
        ),

        _postButton(),
      ]
    );
  }

  _postButton() {
    return TextButton(
      onPressed: () {
        context.read<CommentBloc>()
      }, 
      child: Text("Post")
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
