import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/https_help.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/models/says_model.dart';
import 'package:kingsfam/repositories/church/church_repository.dart';
import 'package:kingsfam/repositories/church_kings_cord_repository/kingscord_repository.dart';
import 'package:kingsfam/widgets/giphy/giphy_widget.dart';

import '../kings cord/widgets/message_lines.dart';
import '../kings cord/widgets/msgs_loading.dart';
import 'cubit/says_cubit.dart';

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
  const SaysView({
    Key? key,
    required this.s,
    required this.cmId,
    required this.kcId,
  }) : super(key: key);
  static const String routeName = "says_view";
  static Route route({required SaysViewArgs args}) {
    return MaterialPageRoute(
        builder: (context) => BlocProvider(
              create: (context) => SaysCubit(
                  authBloc: context.read<AuthBloc>(),
                  churchRepository: context.read<ChurchRepository>(),
                  kingsCordRepository: context.read<KingsCordRepository>()),
              child: SaysView(s: args.s, cmId: args.cmId, kcId: args.kcId),
            ));
  }

  @override
  State<SaysView> createState() => _SaysViewState();
}

class _SaysViewState extends State<SaysView> {
  List<Widget> forms = [];
  List<Message> messages = [];
  late ScrollController _scrollCtrl;
  late TextEditingController _messageController = TextEditingController();
  static GlobalKey _formKey = GlobalKey<FormState>();
  bool flag_has_added_first_child = false;
  Map<String, dynamic> metadata = {};
  Message? reply = null;
  Map<String, dynamic> mentionedInfo = {};
  int indexSaved = 0;

  @override
  void initState() {
    super.initState();

    _scrollCtrl = ScrollController();

    context.read<SaysCubit>().pagMsgs(
        cmId: widget.cmId, kcId: widget.kcId, sId: widget.s.id!, limit: 10);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

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
        title: _header(context, widget.s),
      ),
      body: BlocConsumer<SaysCubit, SaysState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (!flag_has_added_first_child) {
            addChild1();
            flag_has_added_first_child = true;
          }

          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.saysStatus == SaysStatus.loading) ...[
                  LinearProgressIndicator(
                      color: Theme.of(context).colorScheme.primary)
                ],
                _buildFormLines(state.msgs),
                _bottomTf(context, state),
                _showMediaPopUp(),
              ],
            ),
          );
        },
      ),
    );
  }

  _buildFormLines(List<Message?> msgs) {
    return Expanded(
            child: ListView(
            controller: _scrollCtrl,
            padding: EdgeInsets.symmetric(horizontal: 7.0),
            physics: AlwaysScrollableScrollPhysics(),
            reverse: true,
            addAutomaticKeepAlives: true,
            children: _buildchildren(msgs),
          ));
  }

  _buildchildren(List<Message?> msgs) {
    List<Widget> lst = [];
    msgs.forEach((sms) {
      MessageLines messageLine;
      if (sms != null) {
        messageLine = MessageLines(
            cm: Church.empty.copyWith(id: widget.cmId),
            kc: KingsCord.empty.copyWith(id: widget.kcId),
            message: sms,
            inhearatedCtx: context,
            kcubit: null);

        lst.add(messageLine);
      }
    });
    lst.add(forms[0]);
    lst.add(Divider(color: Theme.of(context).colorScheme.inversePrimary));
    return lst;
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

  _showMediaPopUp() {
    return Container(
      child: Row(
        children: [],
      )
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

  _bottomTf(BuildContext context, SaysState state) {
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
                                          key: _formKey,
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
                                          onChanged: (msgT) {
                                            _onChanged(msgT);
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
                        icon: !state.isTyping
                            ? Icon(
                                Iconsax.send_1,
                                size: 18,
                              )
                            : Icon(Iconsax.send_21,
                                size: 19, color: Colors.blue),
                        onPressed: state.isTyping
                            ? () {
                                _onSend();
                                _messageController.clear();
                              }
                            : null,
                      ),
                    ),
                  ],
                )
              ],
            )));
  }

  String extractGiphyId(String url) {
    final lastIndex = url.lastIndexOf('-');
    if (lastIndex >= 0) {
      return url.substring(lastIndex + 1, url.length);
    }
    return '';
  }

  _header(BuildContext context, Says s) {
    return Text(
      s.author!.username + "'s say",
      style: Theme.of(context).textTheme.bodyText1,
    );
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

  final urlRegExp = RegExp(
    r'(?:^|[^\w])(https?://\S+)(?:$|[^\w])',
    caseSensitive: false,
  );

  _onSend() {
    metadata["kcName"] = widget.s.title;
                                if (reply != null) {
                                  metadata["replyId"] = reply!.id;
                                }

                                String? url =
                                    findHttps(_messageController.text);

                                if (url != null) {
                                  metadata["url"] = url;
                                }

                                final message = Message(
                                  text: _messageController.text,
                                  date: Timestamp.fromDate(DateTime.now()),
                                  imageUrl: null,
                                  senderUsername: widget.s.author!.username,
                                  metadata: metadata,
                                  mentionedIds:
                                      mentionedInfo.keys.toSet().toList(),
                                );

                                KingsCordRepository().sendMsgTxt(
                                    churchId: widget.cmId,
                                    kingsCordId: widget.kcId,
                                    message: message,
                                    senderId: context
                                        .read<AuthBloc>()
                                        .state
                                        .user!
                                        .uid,
                                    saysId: widget.s.id);
                                setState(() {});
  }

  _onChanged(String messageText) {



if (messageText == '' || messageText == ' ' || messageText.isEmpty) {
      // _mentionedController = null;
      // containsAt = false;
      context.read<SaysCubit>().onIsTyping(false);
    }

    // if (messageText[messageText.length - 1] == '@') {
    //   containsAt = true;
    //   idxWhereStartWithat = messageText.length - 1;
    // }

    // if (containsAt) {
    //   setState(() => _mentionedController =
    //       messageText.substring(idxWhereStartWithat + 1, messageText.length));
    // }

    // if (messageText.endsWith(' ') || !messageText.contains("@")) {
    //   containsAt = false;
    //   idxWhereStartWithat = 0;
    //   _mentionedController = null;
    // }

    if (messageText.length > 0) {
      context.read<SaysCubit>().onIsTyping(true);
    } else {
      context.read<SaysCubit>().onIsTyping(false);
    }
    setState(() {});
  }
}
