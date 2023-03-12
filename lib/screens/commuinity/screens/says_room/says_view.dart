import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/cubits/liked_says/liked_says_cubit.dart';
import 'package:kingsfam/extensions/date_time_extension.dart';
import 'package:kingsfam/models/says_model.dart';
import 'package:kingsfam/widgets/giphy/giphy_widget.dart';
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
  const SaysView(
      {Key? key, required this.s, required this.kcId, required this.cmId})
      : super(key: key);
  static const String routeName = "says_view";
  static Route route({required SaysViewArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) {
          return SaysView(
            s: args.s,
            cmId: args.cmId,
            kcId: args.kcId,
          );
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
    bool hasLiked;
    hasLiked = context
        .read<LikedSaysCubit>()
        .state
        .localLikedSaysIds
        .contains(widget.s.id!);

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
          body: SingleChildScrollView(
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
          persistentFooterButtons: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.start,
                //   crossAxisAlignment: CrossAxisAlignment.center,
                //   children: [
                //     GestureDetector(
                //       onTap: () {
                //         if (widget.s.id != null) {
                //           context
                //               .read<LikedSaysCubit>()
                //               .updateOnCloudLike(
                //                   cmId: widget.cmId,
                //                   kcId: widget.kcId,
                //                   sayId: widget.s.id!,
                //                   currLikes: widget.s.likes)
                //               .then((value) => setState(() {}));
                //         } else
                //           snackBar(
                //               snackMessage: "s.id is null",
                //               context: context,
                //               bgColor: Colors.red);
                //       },
                //       child: Icon(
                //         Icons.favorite_border_outlined,
                //         size: 25,
                //         color: hasLiked
                //             ? Colors.amber
                //             : Theme.of(context).iconTheme.color,
                //       ),
                //     ),
                //     SizedBox(width: 8),
                //     Text(
                //         hasLiked
                //             ? (widget.s.likes + 1).toString()
                //             : widget.s.likes.toString(),
                //         style: Theme.of(context).textTheme.caption),
                //     // SizedBox(width: 7),
                //     // Icon(Icons.mode_comment_outlined),
                //     // SizedBox(width: 1),
                //     // Text(widget.s.commentsCount.toString(),
                //     //     style: Theme.of(context).textTheme.caption),
                //     // SizedBox(width: 7),
                //   ],
                // ),
                // SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Text(widget.s.date.timeAgo(),
                      style: Theme.of(context).textTheme.caption),
                )
              ],
            )
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
      child: Text(
        s.title!,
        style: Theme.of(context)
            .textTheme
            .bodyText1!
            .copyWith(fontWeight: FontWeight.bold, fontSize: 25),
      ),
    );
  }

  _body(BuildContext context, Says s) {
    return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8.0, right: 8, left: 8),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildContent(context, s.contentTxt),
          ),
        ));
  }

  final urlRegExp = RegExp(
    r'(?:^|[^\w])(https?://\S+)(?:$|[^\w])',
    caseSensitive: false,
  );


List<Widget> _buildContent(BuildContext context, String contentTxt) {
  final lines = contentTxt.split('\n');
  final widgets = <Widget>[];

  for (final line in lines) {
    final spans = <InlineSpan>[];
    final words = line.split(' ');

    for (final word in words) {
      if (urlRegExp.hasMatch(word)) {
        final url = urlRegExp.firstMatch(word)!.group(0)!;
        final before = word.substring(0, word.indexOf(url));
        final after = word.substring(word.indexOf(url) + url.length);
        spans.add(TextSpan(text: before));
        spans.add(WidgetSpan(child: urlDisplay(url)));
        spans.add(TextSpan(text: after));
      } else {
        spans.add(TextSpan(text: word));
      }
      spans.add(TextSpan(text: ' '));
    }

    widgets.add(
      RichText(
        text: TextSpan(children: spans, style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 15)),
      ),
    );
  }

  return widgets;
}

String extractGiphyId(String url) {
  final lastIndex = url.lastIndexOf('-');
  if (lastIndex >= 0) {
    return url.substring(lastIndex+1, url.length);
  }
  return '';
}


urlDisplay(String url) {
  if (url.contains("https://giphy.com/gifs/")) {
    String gifId = extractGiphyId(url);
    log("GIF ID: " + gifId);
    if (gifId.isNotEmpty)
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DisplayGif(giphyId: gifId),
        // const SizedBox(height: 4),
        // Text(url, style: TextStyle(fontSize: 15, color: Colors.blueAccent),)
      ],
    );
    else return Text(url, style: const TextStyle(fontSize: 15, color: Colors.blueAccent),);
  }
}


}
