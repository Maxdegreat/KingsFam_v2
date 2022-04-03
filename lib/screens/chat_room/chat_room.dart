import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/helpers/helpers.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/chat_room/cubit/chatroom_cubit.dart';
import 'package:kingsfam/widgets/message_bubbles.dart';

import '../screens.dart';

class ChatRoomArgs {
  final Chat chat;

  ChatRoomArgs({required this.chat});
}

class ChatRoom extends StatefulWidget {
  final Chat chat;
  const ChatRoom({
    Key? key,
    required this.chat,
  }) : super(key: key);

  static const String routeName = '/chatRoom';

  static Route route({required ChatRoomArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => BlocProvider(
              create: (_) => ChatroomCubit(
                  storageRepository: context.read<StorageRepository>(),
                  chatRepository: context.read<ChatRepository>(),
                  authBloc: context.read<AuthBloc>()),
              child: ChatRoom(chat: args.chat),
            ));
  }

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final TextEditingController _messageController = TextEditingController();
  // THE STREAM FOR THE MESSAGES
  _buildMessageStream() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(Paths.chats)
          .doc(widget.chat.id)
          .collection(Paths.messages)
          .orderBy('date', descending: true)
          .limit(50)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return Expanded(
          child: GestureDetector(
            onTap: () => Focus.of(context).unfocus(),
            child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                physics: AlwaysScrollableScrollPhysics(),
                reverse: true,
                children: _buidlMessageBubbles(snapshot)),
          ),
        );
      },
    );
  }
  // THE CREATION OF THE TEXT FORM
  List<MessageBubble> _buidlMessageBubbles(AsyncSnapshot<QuerySnapshot> message) {
    List<MessageBubble> messagebubbles = [];
    
    message.data?.docs.forEach((doc) {
      Message message = Message.fromDoc(doc);
      MessageBubble messagebubble =
          MessageBubble(chat: widget.chat, message: message);
      messagebubbles.add(messagebubble);
    });
    return messagebubbles;
  }
  // BUILD MESSAGE TEXTFORM
  _buildMessageTF(ChatroomState state, BuildContext context) {
    final ctx = context.read<ChatroomCubit>();
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        child: Row(
          children: [
            IconButton(
                onPressed: () async {
                  final pickedFile = await ImageHelper.pickImageFromGallery(
                      context: context,
                      cropStyle: CropStyle.rectangle,
                      title: 'send');
                  if (pickedFile != null) {
                    ctx.onUploadImage(pickedFile);
                    ctx.sendImage(widget.chat);
                  }
                },
                icon: FaIcon(FontAwesomeIcons.image)),
            Expanded(
              child: TextField(
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (messageText) =>
                    ctx.onIsTyping(messageText.length >= 1),
                //setState(() => _isComposingMessage = messageText.isNotEmpty
                decoration:
                    InputDecoration.collapsed(hintText: 'Provbers 16:23'),
              ),
            ),
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: IconButton(
                  icon: Icon(
                    Icons.send,
                    color: state.isTyping ? Colors.red[400] : Colors.white,
                  ),
                  onPressed: state.isTyping
                      ? () {
                          //ctx.onTextMessage(_messageController.text);
                          ctx.sendTextMesage(
                              chatId: widget.chat,
                              textMessage: _messageController.text);
                          ctx.onIsTyping(false);
                          _messageController.clear();
                        }
                      : null,
                ))
          ],
        ));
  }

  // WIDGET BUILD 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.chat.name, overflow: TextOverflow.ellipsis),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(ChatRoomSettings.routeName,
                      arguments: ChatRoomSettingsArgs(chat: widget.chat));
                },
                icon: Icon(Icons.horizontal_distribute))
          ],
        ),
        body: BlocConsumer<ChatroomCubit, ChatroomState>(
          listener: (context, state) {
            // TODO: implement listener
          },
          builder: (context, state) {
            return SafeArea(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMessageStream(),
                Divider(height: 1.0),
                _buildMessageTF(state, context),
              ],
            ));
          },
        ));
  }
}