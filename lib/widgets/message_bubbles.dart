import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/extensions/hexcolor.dart';
import 'package:kingsfam/models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/extensions/extensions.dart';
import 'package:kingsfam/screens/screens.dart';

class MessageBubble extends StatelessWidget {
  //class data

  //we need chat for collection location and message to know what we are writing and maybe where to
  final Chat chat;
  final Message message;
  final Color? passedColor;
  const MessageBubble({
    Key? key,
    required this.chat,
    required this.message,
    this.passedColor,
  }) : super(key: key);

  _buildText() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      child: Text(message.text!,
          style: TextStyle(color: Colors.white, fontSize: 15.0)),
    );
  }

  _buildImage(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: (() => Navigator.of(context).pushNamed(UrlViewScreen.routeName, arguments: UrlViewArgs(
        userr: Userr.empty,
        urlImg: message.imageUrl, heroTag: 'heroTag'))),
      child: Container(
        height: size.height * 0.2,
        width: size.width * 0.6,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(message.imageUrl!))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    HexColor hc = HexColor();
     bool isMe =
        context.read<AuthBloc>().state.user!.uid == message.sender!.id;
    if (passedColor != null) isMe = false;
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: isMe
                          ? const EdgeInsets.only(right: 12.0)
                          : const EdgeInsets.only(left: 12.0),
                      child: Text(
                        isMe
                            ? '${message.date.timeAgo()}' //.timeAgo()
                            : '${message.sender!.username} ${message.date.timeAgo()}', //.timeAgo()
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                    const SizedBox(height: 7.0),
                    Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.65,
                        ),
                        decoration: BoxDecoration(
                            color: message.imageUrl == null
                                ? passedColor != null
                                    ? passedColor
                                    : isMe
                                        ? Theme.of(context).colorScheme.background
                                        : Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0))),
                        child: message.text != null
                            ? _buildText()
                            : _buildImage(context))
                  ])
            ]));
  }
}
