import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/extensions/date_time_extension.dart';
import 'package:kingsfam/models/church_kingscord_model.dart';
import 'package:kingsfam/models/church_model.dart';
import 'package:kingsfam/models/message_model.dart';
import 'package:kingsfam/models/says_model.dart';
import 'package:kingsfam/repositories/church/church_repository.dart';
import 'package:kingsfam/repositories/church_kings_cord_repository/kingscord_repository.dart';
import 'package:kingsfam/screens/commuinity/screens/kings%20cord/widgets/message_lines.dart';
import 'package:kingsfam/screens/commuinity/screens/says_room/cubit/says_cubit.dart';
import 'package:kingsfam/widgets/giphy/giphy_widget.dart';

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
          return BlocProvider<SaysCubit>(
            create: (context) => SaysCubit(
              churchRepository: context.read<ChurchRepository>(),
              authBloc: context.read<AuthBloc>(),
              kingsCordRepository: context.read<KingsCordRepository>(),
            ),
            child: SaysView(
              s: args.s,
              cmId: args.cmId,
              kcId: args.kcId,
            ),
          );
        });
  }

  @override
  State<SaysView> createState() => _SaysViewState();
}

class _SaysViewState extends State<SaysView> {
  List<Widget> forms = [];
  List<Message> messages = [];
  late ScrollController scrollCtrl;
  late TextEditingController _messageController;
  bool isTyping = false;
  Map<String, dynamic> metadata = {};
  Message? reply = null;
  Map<String, dynamic> mentionedInfo = {};
  bool flag_has_added_first_child = false;
  @override
  void initState() {
    _messageController = TextEditingController();
    scrollCtrl = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
          body: BlocConsumer<SaysCubit, SaysState>(
            listener: (context, state) {},
            builder: (context, state) {
              // if (!flag_has_added_first_child) {
              //   addChild1();
              //   flag_has_added_first_child = true;
              //   context.read<SaysCubit>().pagMsgs(
              //       cmId: widget.cmId,
              //       kcId: widget.kcId,
              //       sId: widget.s.id!,
              //       limit: 10);
              //       // setState(() {});
              // }

              return Column(
                children: [
                  if (state.saysStatus == SaysStatus.loading) ...[
                    LinearProgressIndicator(
                        color: Theme.of(context).colorScheme.primary)
                  ],
                  // _content(state.msgs),
                  // _bottomTf(context)
                ],
              );
            },
          ),
          ),
    );
  }

  _content(List<Message?> msgs) {
    return Expanded(
      child: ListView(
        controller: scrollCtrl,
        padding: EdgeInsets.symmetric(horizontal: 7.0),
        physics: AlwaysScrollableScrollPhysics(),
        reverse: false,
        addAutomaticKeepAlives: true,
        children: _buildchildren(msgs),
      ),
    );
  }

  _buildchildren(List<Message?> msgs) {
    msgs.forEach((sms) {
      MessageLines messageLine;
      if (sms != null) {
        messageLine = MessageLines(
            cm: Church.empty.copyWith(id: widget.cmId),
            kc: KingsCord.empty.copyWith(id: widget.kcId),
            message: sms,
            inhearatedCtx: context,
            kcubit: null);

        forms.add(messageLine);
      }
    });
    return forms;
  }

  _bottomTf(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width > 700
            ? MediaQuery.of(context).size.width / 5
            : null,
        // margin: EdgeInsets.symmetric(horizontal: 5.0),
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onPrimary,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    bool value = context
                                        .read()<SaysCubit>()
                                        .state
                                        .showHidden;
                                    context
                                        .read()<SaysCubit>()
                                        ._onShowBottomTab(!value);
                                  },
                                  icon: Icon(Icons.add)),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                          cursorColor: Theme.of(context)
                                              .colorScheme
                                              .inversePrimary,
                                          textAlignVertical:
                                              TextAlignVertical.center,
                                          style: TextStyle(fontSize: 18),
                                          autocorrect: true,
                                          controller: _messageController,
                                          keyboardType: TextInputType.multiline,
                                          maxLines: 4,
                                          minLines: 1,
                                          expands: false,
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          onChanged: (messageText) {
                                            if (messageText.isNotEmpty) {
                                              context
                                                  .read<SaysCubit>()
                                                  .onIsTyping(true);
                                            } else {
                                              context
                                                  .read<SaysCubit>()
                                                  .onIsTyping(false);
                                            }
                                          },
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.all(2),
                                            border: InputBorder.none,
                                            hintText:
                                                'Respond to the form thread',
                                            isCollapsed: true,
                                          )),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onPrimary,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: IconButton(
                        icon: !context.read<SaysCubit>().state.isTyping
                            ? Icon(
                                Iconsax.send_1,
                                size: 18,
                              )
                            : Icon(Iconsax.send_21,
                                size: 19, color: Colors.blue),
                        onPressed: context.read<SaysCubit>().state.isTyping
                            ? () {
                               
                              }
                            : null,
                      ),
                    ),
                  ],
                )
              ],
            )));
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

  addChild1() {
    forms.add(
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _title(context, widget.s),
          _body(context, widget.s),
        ],
      ),
    );
    forms.add(Divider(
      color: Theme.of(context).colorScheme.inverseSurface,
    ));
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
          text: TextSpan(
              children: spans,
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(fontSize: 15)),
        ),
      );
    }

    return widgets;
  }

  String extractGiphyId(String url) {
    final lastIndex = url.lastIndexOf('-');
    if (lastIndex >= 0) {
      return url.substring(lastIndex + 1, url.length);
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
      else
        return Text(
          url,
          style: const TextStyle(fontSize: 15, color: Colors.blueAccent),
        );
    }
  }

  String? findHttps(String str) {
    int startIndex = str.indexOf("https://");
    if (startIndex != -1 && (startIndex == 0 || str[startIndex - 1] == ' ')) {
      int endIndex = str.indexOf(' ', startIndex + 1);
      if (endIndex == -1) {
        return str.substring(startIndex);
      } else {
        return str.substring(startIndex, endIndex);
      }
    }
    return null;
  }
}
