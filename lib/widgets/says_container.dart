import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpers/helpers.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/cubits/liked_says/liked_says_cubit.dart';
import 'package:kingsfam/extensions/date_time_extension.dart';
import 'package:kingsfam/config/constants.dart';
import 'package:kingsfam/models/says_model.dart';
import 'package:kingsfam/widgets/widgets.dart';

class SaysContainer extends StatefulWidget {
  final Says says;
  final BuildContext? context;
  final double? height;
  final int? taps;
  final Set<String?> localLikesSays;
  const SaysContainer(
      {Key? key,
      required this.says,
      required this.context,
      required this.localLikesSays,
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
      fontSize: 18,
      color: Color(hc.hexcolorCode(widget.says.author!.colorPref)),
      fontWeight: FontWeight.bold,
    );

    TextStyle title2 = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Container(
        color: Theme.of(context).colorScheme.primary,
        height: 200,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              header_says(title),
              SizedBox(height: 5),
              title_says(context),
              SizedBox(height: 5),
              contentTxt_says(),
              SizedBox(height: 10),
              footer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget title_says(BuildContext context) {
    return Text(widget.says.title!,
        style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 20));
  }

  Widget contentTxt_says() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        widget.says.contentTxt,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 17),
      ),
    );
  }

  Row header_says(TextStyle title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileImage(
            radius: 25,
            pfpUrl: widget.says.author!.profileImageUrl == null ||
                    widget.says.author!.profileImageUrl.isEmpty
                ? "https://firebasestorage.googleapis.com/v0/b/kingsfam-9b1f8.appspot.com/o/images%2Fchurches%2FchurchAvatar_eb0c7061-a124-41b4-b948-60dcb0dffc49.jpg?alt=media&token=7e2fc437-9448-48bd-95bc-78e977fbcad8"
                : widget.says.author!.profileImageUrl),
        SizedBox(width: 10),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // cm name as title
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      widget.says.author!.username,
                      style: title,
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // creation of the footer
  Widget footer() {
    return Row(
      children: [
        widget.says.contentImgUrl != null
            ?
            // show the img or vid thumbnail
            imgRow()
            : oneLineReactions()
      ],
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.keyboard_double_arrow_up_outlined,
               color: context.read<LikedSaysCubit>().state.localLikedSaysIds.contains(widget.says.id) 
                ? Colors.amber
                : Theme.of(context).iconTheme.color,
              ),
            Text(
              context.read<LikedSaysCubit>().state.localLikedSaysIds.contains(widget.says.id)
               ? (widget.says.likes + 1).toString()
               : widget.says.likes.toString(),
                style: Theme.of(context).textTheme.caption),
            SizedBox(width: 7),
            Icon(Icons.mode_comment_outlined),
            SizedBox(width: 1),
            Text(widget.says.commentsCount.toString(),
                style: Theme.of(context).textTheme.caption),
            SizedBox(width: 7),
          ],
        ),
        Text(widget.says.date.timeAgo(),
            style: Theme.of(context).textTheme.caption)
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
