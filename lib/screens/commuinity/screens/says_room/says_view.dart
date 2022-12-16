import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/cubits/liked_says/liked_says_cubit.dart';
import 'package:kingsfam/extensions/date_time_extension.dart';
import 'package:kingsfam/models/says_model.dart';
import 'package:kingsfam/widgets/snackbar.dart';

class SaysViewArgs {
  final Says s;
  final String cmId;
  final String kcId;
  const SaysViewArgs({required this.s, required this.kcId, required this.cmId});
}

class SaysView extends StatefulWidget {
  final Says s;
  final String cmId;
  final String kcId;
  const SaysView({Key? key, required this.s, required this.kcId, required this.cmId}) : super(key: key);
  static const String routeName = "says_view";
  static Route route({required SaysViewArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) {
          return SaysView(s: args.s, cmId: args.cmId, kcId: args.kcId,);
        });
  }

  @override
  State<SaysView> createState() => _SaysViewState();
}

class _SaysViewState extends State<SaysView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Theme.of(context).iconTheme.color,
                )),
            title: _header(context, widget.s),
          ),
          body: GestureDetector(

            onDoubleTap: () {
              if (widget.s.id != null)
                context.read<LikedSaysCubit>().updateOnCloudLike(cmId: widget.cmId, kcId: widget.kcId, sayId: widget.s.id!, currLikes: widget.s.likes);
              else 
                snackBar(snackMessage: "s.id is null", context: context, bgColor: Colors.red);
            },


            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  _title(context, widget.s),
                  _body(context, widget.s),
                ],
              ),
            ),
          ),
          persistentFooterButtons: [
            _oneLineReactions(),
          ]),
    );
  }

  _header(BuildContext context, Says s) {
    return Text(
      s.author!.username + "'s say",
      style: Theme.of(context).textTheme.bodyText1,
    );
  }

  _title(BuildContext context, Says s) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 8,
        right: 8,
        bottom: 10,
      ),
      child: Center(
        child: Text(
          s.title!,
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(fontWeight: FontWeight.bold, fontSize: 25),
        ),
      ),
    );
  }

  _body(BuildContext context, Says s) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8.0, right: 8, left: 8),
      child: SingleChildScrollView(
        child: Text(
          s.contentTxt,
          overflow: TextOverflow.ellipsis,
          maxLines: 100,
          style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 17),
        ),
      ),
    );
  }

  Widget _oneLineReactions() {
    String uid = context.read<AuthBloc>().state.user!.uid;
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
              color: context
                      .read<LikedSaysCubit>()
                      .state
                      .localLikedSaysIds
                      .contains(widget.s.id)
                  ? Colors.amber
                  : Theme.of(context).iconTheme.color,
            ),
            Text(
                context.read<LikedSaysCubit>().state.localLikedSaysIds.contains(widget.s.id)
                    ? (widget.s.likes + 1).toString()
                    : widget.s.likes.toString(),
                style: Theme.of(context).textTheme.caption),
            SizedBox(width: 7),
            Icon(Icons.mode_comment_outlined),
            SizedBox(width: 1),
            Text(widget.s.commentsCount.toString(),
                style: Theme.of(context).textTheme.caption),
            SizedBox(width: 7),
          ],
        ),
        Text(widget.s.date.timeAgo(),
            style: Theme.of(context).textTheme.caption)
      ],
    );
  }
}
