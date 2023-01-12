import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/extensions/hexcolor.dart';
import 'package:kingsfam/screens/profile/bloc/profile_bloc.dart';
import 'package:kingsfam/widgets/comment_line.dart';
import 'bloc/comment_bloc.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/post/post_repository.dart';

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
TextStyle style = TextStyle(color: Colors.grey);

class _CommentScreenState extends State<CommentScreen> {
  HexColor hc = HexColor();
  Comment? commentReplyingTo = null;
  final TextEditingController _messageController = TextEditingController();
  double textHeight = 50;
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommentBloc, CommentState>(
      listener: (context, state) {

      },

      builder: (context, state) {
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).iconTheme.color,
              )),
              title: Text("Comments", style: Theme.of(context).textTheme.bodyText1,),
              actions: [

              ],
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [

        if (state.status == CommentStatus.loading)
            LinearProgressIndicator(),
            
        _commentListView(state),
        Divider(),
       _bottomTf(),
     
    
              ],
            ),
          )
        );
      }, 
    );
  }

  Expanded _commentListView(CommentState state) {
    return Expanded(
        child: ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          reverse: true,
          itemCount: state.comments.length,
          itemBuilder: (BuildContext context, int index) {
            if (state.comments.length == 0) {
              return Center(child: Text("Be the first to comment", style: Theme.of(context).textTheme.caption,));
            } else {
              Comment? comment = state.comments[index];
            return comment != null
                ? Column(
                    children: [
                      CommentLines(comment: comment),
                      // _replyBtns(comment: comment, postId: widget.post.id!),
                      // _showReplys(state: state, comment: comment),
                    ],
                  )
                : Text("ops, something went wrong");
            }
          },
        ),
      );
  }



  _bottomTf() {
    String? imageUrl = context.read<ProfileBloc>().state.userr.profileImageUrl;
    return Container(
      // height: textHeight + 10,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // IconButton(
            //   onPressed: () {}, 
            //   icon: Icon(Icons.gif),
            // ),
    
            SizedBox(width: 5),
    
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3.0),
                child: Align(
                  alignment: Alignment.center,
                  child: TextField(
                            onChanged: _textFieldOnChanged(_messageController),
                            cursorColor: Theme.of(context).colorScheme.inversePrimary,
                            textAlignVertical: TextAlignVertical.center,
                            style: TextStyle(fontSize: 18),
                            expands: false,
                            autocorrect: true,
                            controller: _messageController,
                            keyboardType: TextInputType.multiline,
                            maxLines: 8,
                            minLines: 1,
                            textCapitalization:
                                  TextCapitalization.sentences,
                            decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "comment",
                  hintStyle: Theme.of(context).textTheme.caption,
                
                            ),
                          ),
                ),
              ),
            ),
            
            SizedBox(width: 5),
            _postButton(),
          ]
        ),
      ),
    );
  }

  _postButton() {
    return TextButton(
      onPressed: () {
        if (canPost) {
          context.read<CommentBloc>().add(CommentPostComment(content: _messageController.value.text, post: widget.post));
          _messageController.clear();
        }
      }, 
      child: Text(
        "Post", 
        style: canPost ? 
          Theme.of(context).textTheme.caption!.copyWith(color: Colors.greenAccent)
          : Theme.of(context).textTheme.caption!.copyWith(color: Colors.grey)
      )
    );
  }

  _textFieldOnChanged(TextEditingController ctrl) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
    if (ctrl.value.text.length > 1) {
      canPost = true;
    } else {
      canPost = false;
    }

    if (ctrl.value.text.length > 26) {
       textHeight += 25;
    }

    if (ctrl.value.text.length > 38) {
      textHeight += 25;
    }

    if (ctrl.value.text.length < 26) {
      textHeight = 50;
    }

    if (ctrl.value.text.length > 26) {
      
      setState(() {});
      
    } else if (ctrl.value.text.length > 38) {
      
      setState(() {});

    } else if (ctrl.value.text.length < 26) {
      setState(() {});
    }

    });
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
