import 'package:flutter/material.dart';
import 'package:kingsfam/extensions/date_time_extension.dart';
import 'package:kingsfam/models/says_model.dart';

class SaysViewArgs {
  final Says s;
  const SaysViewArgs({required this.s});
}

class SaysView extends StatefulWidget {
  final Says s;
  const SaysView({Key? key, required this.s}) : super(key: key);
  static const String routeName = "says_view";
  static Route route({required SaysViewArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) {
          return SaysView(s: args.s);
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
              .copyWith(fontWeight: FontWeight.bold, fontSize:25),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.keyboard_double_arrow_up_outlined),
            Text(widget.s.likes.toString(),
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
