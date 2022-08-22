import 'dart:developer';

import 'package:kingsfam/extensions/date_time_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'bloc/comment_bloc.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/post/post_repository.dart';
import 'package:kingsfam/widgets/widgets.dart';

  // args
  class CommentScreenArgs{
    final Post post;
    CommentScreenArgs({required this.post});
  }

class CommentScreen extends StatefulWidget {
  const CommentScreen({ Key? key, required this.post}) : super(key: key);
  final Post post;
   // route name
  static const String routeName = 'CommentScreenRouteName';
   // make route function
   static Route route({ required CommentScreenArgs args }) {
     return MaterialPageRoute(
       settings: const RouteSettings(name: routeName),
       builder: (context) => BlocProvider<CommentBloc>(
         create: (_) => CommentBloc(
           postsRepository: context.read<PostsRepository>(), 
           authBloc: context.read<AuthBloc>()
          )..add(CommentFtechComments(post: args.post)),
          child: CommentScreen(post: args.post),
       )
     );
   }
  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _messageController = TextEditingController();
  double textHeight = 35;   
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Comments"),),
      body: SafeArea(
        child: BlocConsumer<CommentBloc, CommentState>(
         listener: (context, state) {
           if (state is CommentError) {
             snackBar(snackMessage: "CommentScreen error: ${state.failure.code}", context: context, bgColor: Colors.red[400]);
           }
         },
         builder: (context, state) {
           if (state is CommentInital) {
             return Center(child: Text("No Comments 2 See"));
           } else if (state is CommentLoading) {
             return CircularProgressIndicator();
           } else if (state is CommentLoaded) {
             return commentLoadedWidget(state.comments);//Center(child: Text("${state.comments[0]}"));
           } else if (state is CommentError) {
             return Center(child: Text(state.failure.message));
           } else return SizedBox.shrink();
         },
       )
      ),
    );
  }

  Widget commentLoadedWidget(List<Comment?> comments) {
    return Column(
     mainAxisAlignment: MainAxisAlignment.end,
     children: [
        Expanded(
          child: ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            reverse: true,
            itemCount: comments.length,
            itemBuilder: (BuildContext context, int index) {
              Comment? comment = comments[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                   mainAxisAlignment: MainAxisAlignment.start,
                   children: [
                     comment != null
                         ? ProfileImage(radius: 25, pfpUrl: comment.author.profileImageUrl)
                         : SizedBox.shrink(),
                     SizedBox(width: 10),
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           comment!.author.username,
                           overflow: TextOverflow.fade,
                         ),
                         SizedBox(height: 3),
                         Text(comment.date.timeAgo().toString(), overflow: TextOverflow.fade)
                       ],
                     )
                   ],
                 ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0, right: 10, left: 10, top: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(comment.content),
                        Divider(indent: 17, color: Colors.white,)
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Row(
         children: [
           Expanded(
            flex: 1,
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
                     decoration: InputDecoration(hintText: "Add A Comment Fam..."),
                     maxLines: null,
                     expands: true,
                     textCapitalization: TextCapitalization.sentences,
                     onChanged: (messageText) {
                      if (messageText.length >= 29) 
                        setState(() => textHeight = 50.0);
                      else if (messageText.length >= 87)
                        setState(() => textHeight = 65.0);
                      else 
                        setState(() => textHeight = 30.0 );
                    },
                   ),
                 ),
               ),
             )),
           
           IconButton(
               onPressed: () {
                 final content = _messageController.text.trim();
                 if (content.isNotEmpty) {
                    context.read<CommentBloc>().add(CommentPostComment(comments: comments, content: content, post: widget.post));
                   _messageController.clear();
                 }
               },
               icon: Icon(Icons.send))
         
     ])]);
  }

} // end of stful 



