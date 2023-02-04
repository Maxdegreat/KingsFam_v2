import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpers/helpers.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/cubits/buid_cubit/buid_cubit.dart';
import 'package:kingsfam/cubits/liked_says/liked_says_cubit.dart';
import 'package:kingsfam/extensions/date_time_extension.dart';
import 'package:kingsfam/config/constants.dart';
import 'package:kingsfam/models/says_model.dart';
import 'package:kingsfam/screens/report_content_screen.dart';
import 'package:kingsfam/widgets/widgets.dart';

class SaysContainer extends StatefulWidget {
  final Says says;
  final BuildContext? context;
  final double? height;
  final int? taps;
  final Set<String?> localLikesSays;
  final String cmId;
  const SaysContainer(
      {Key? key,
      required this.says,
      required this.context,
      required this.localLikesSays,
      required this.cmId,
      this.height,
      this.taps})
      : super(key: key);

  @override
  State<SaysContainer> createState() => _SaysContainerState();
}

class _SaysContainerState extends State<SaysContainer> {
  @override
  Widget build(BuildContext context) {
    TextStyle title = TextStyle(
      fontSize: 15,
      color: Color(hc.hexcolorCode(widget.says.author!.colorPref)),
      fontWeight: FontWeight.bold,
    );

    TextStyle title2 = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
        [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.secondary
            ),
            width: double.infinity,
            height: MediaQuery.of(context).size.shortestSide / 2.5,
            child: _saysPreview(),
          ),
          SizedBox(height: 7),
          Container(
            width: double.infinity,
            // height: MediaQuery.of(context).size.shortestSide / 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.secondary
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title_says(context),
                header_says(title),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  child: Text(widget.says.date.timeAgo(),
            style: Theme.of(context).textTheme.caption),
                )
              ],
            )
          )
        ],
      ),
    );
  }

  _saysPreview() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(widget.says.contentTxt),
    );
  }

  Widget title_says(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
      child: Text(widget.says.title!,
      overflow: TextOverflow.fade,
          style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 17)),
    );
  }

  Widget contentTxt_says() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        widget.says.contentTxt,
        maxLines: 2,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 17),
      ),
    );
  }

  Widget header_says(TextStyle title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ProfileImage(
              radius: 12,
              pfpUrl: widget.says.author!.profileImageUrl == null ||
                      widget.says.author!.profileImageUrl.isEmpty
                  ? "https://firebasestorage.googleapis.com/v0/b/kingsfam-9b1f8.appspot.com/o/images%2Fchurches%2FchurchAvatar_eb0c7061-a124-41b4-b948-60dcb0dffc49.jpg?alt=media&token=7e2fc437-9448-48bd-95bc-78e977fbcad8"
                  : widget.says.author!.profileImageUrl),
          SizedBox(width: 8),
          Text(
            widget.says.author!.username,
            style: Theme.of(context).textTheme.caption!.copyWith(color: Theme.of(context).colorScheme.inversePrimary),
            overflow: TextOverflow.fade,
            maxLines: 1,
          ),
                        IconButton(onPressed: () {
                  _showPostOptions();
                }, icon: Icon(Icons.more_horiz))
        ],
      ),
    );
  }

  _showPostOptions() {
    return showModalBottomSheet(
      context: context, 
      builder: ((context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.says.author!.id != context.read<AuthBloc>().state.user!.uid) ... [
               ListTile(
                onTap: () {
                Map<String, dynamic> info = {
                  "userId" : widget.says.author!.id,
                  "what" : "post",
                  "continue": FirebaseFirestore.instance.collection(Paths.church).doc(widget.cmId).collection(Paths.kingsCord).doc(widget.says.kcId),                 
                };
                Navigator.of(context).pushNamed(ReportContentScreen.routeName, arguments: RepoetContentScreenArgs(info: info));
                // Navigator.of(context).pushNamed(ReviewContentScreen.routeName, arguments: ReviewContentScreenArgs());  
                //     PostsRepository().reportPost(postId: widget.post.id!, cmId: widget.post.commuinity!.id!).then((value) {
                //      snackBar(snackMessage: "Post will be reviewed, thank you for helping keep KingsFam safe", context: context);
                //      Navigator.of(context).pop();

                //   });
                },
                leading: Icon(Icons.report_gmailerrorred, color: Colors.red[400]),
                title: Text("Report this post", style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.red[400]),),
            ),
            
            SizedBox(height: 7),

            ListTile(
              leading: Icon(Icons.block, color: Colors.red[400]),
              title: Text("Block user", style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.red[400])),
              onTap: () {
                // add userId to systemdb of blocked uids

                context.read<BuidCubit>().onBlockUser(widget.says.author!.id);
                
                snackBar(snackMessage: "KingsFam will hide content from this user.", context: context);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              
              },
            )
          ] 
          // else ... [
          //   ListTile(
          //     leading: Icon(Icons.delete, color: Colors.red[400]),
          //     title: Text("Delete this says", style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.red[400])),
          //     onTap: () {
          //       context.read<PostsRepository>().deletePost(post: widget.post).then((value) {
          //         snackBar(snackMessage: "Your post has been removed", context: context, bgColor: Colors.greenAccent);
          //       });
                
          //     },
          //   )
          // ],
           
          ],
        );
      }
    ));
  }

  // creation of the footer
  Widget footer() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Row(
        children: [
          widget.says.contentImgUrl != null
            ? imgRow()
            : oneLineReactions()
        ],
      ),
    );
  }

  Widget oneLineReactions() {
    String uid = context.read<AuthBloc>().state.user!.uid;
    log("len of locallikedsays from says container: " + context.read<LikedSaysCubit>().state.localLikedSaysIds.toString());
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border_outlined,
               color: context.read<LikedSaysCubit>().state.localLikedSaysIds.contains(widget.says.id) 
                ? Colors.amber
                : Theme.of(context).iconTheme.color,
              ),
              SizedBox(width: 8),
            Text(
              context.read<LikedSaysCubit>().state.localLikedSaysIds.contains(widget.says.id)
               ? (widget.says.likes + 1).toString()
               : widget.says.likes.toString(),
                style: Theme.of(context).textTheme.caption),
            // SizedBox(width: 7),
            // Icon(Icons.mode_comment_outlined),
            // SizedBox(width: 5),
            // Text(widget.says.commentsCount.toString(),
            //     style: Theme.of(context).textTheme.caption),
            // SizedBox(width: 7),
          ],
        ),
        SizedBox(height: 8),
        
      ],
    );
  }

  Row imgRow() {
    return Row(
      children: [
        Container(
          height: 30,
          width: 40,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image:
                      CachedNetworkImageProvider(widget.says.contentImgUrl!))),
        ),
        SizedBox(width: 5),
        oneLineReactions()
      ],
    );
  }
}
