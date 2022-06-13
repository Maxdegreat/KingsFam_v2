
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/extensions/hexcolor.dart';
import 'package:kingsfam/helpers/helpers.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/commuinity/screens/kings%20cord/cubit/kingscord_cubit.dart';
import 'package:kingsfam/widgets/profile_image.dart';

import 'message_lines.dart';

//will probably need args to pass all members from the commuinity into main room
class KingsCordArgs {
  //class data
  final Church commuinity;
  final KingsCord kingsCord;
  // class constructor
  KingsCordArgs({required this.commuinity, required this.kingsCord});
}

class KingsCordScreen extends StatefulWidget {

  //class data
  final Church commuinity;
  final KingsCord kingsCord;
  const KingsCordScreen({Key? key, required this.commuinity, required this.kingsCord}) : super(key: key);

  // will need a static const string route name
  static const String routeName = '/kingsCord';

  // will need a static Route route that takes args and has a cubit -> child KingsCord()
  static Route route(KingsCordArgs args) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => BlocProvider(
              //may not have needed to; add a type
              create: (context) => KingscordCubit(
                  storageRepository: context.read<StorageRepository>(),
                  authBloc: context.read<AuthBloc>(),
                  kingsCordRepository: context.read<
                      KingsCordRepository>(), 
                  churchRepository: context.read<ChurchRepository>() // may need to report to main reposityory collection
                  ),
              child: KingsCordScreen(
                commuinity: args.commuinity,
                kingsCord: args.kingsCord,
              ),
            ));
  }

  @override
  _KingsCordScreenState createState() => _KingsCordScreenState();
}

  
class _KingsCordScreenState extends State<KingsCordScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? _mentionedController = null;
  int idxWhereStartWithat = 0;
  bool containsAt = false;
  Map<String, dynamic> mentionIdsMap = {};
  HexColor hexColor = HexColor();
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
  double textHeight = 25;
  _buildMessageStream({required Church commuinity, required KingsCord kingsCord, required List<Message?> msgs }) {
    Set<String> memIds = {};
    Map<String, dynamic> mems = {};
    for (var user in widget.commuinity.members) {
      memIds.add(user.id);
      mems[user.username] = user.id;
    }

    return Expanded(
          flex: 1,
          child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 7.0),
          physics: AlwaysScrollableScrollPhysics(),
          reverse: true,
          children: _buildMessageLines(msgs),
        ));
  }

//==========================================================================S 
  List<MessageLines> _buildMessageLines(List<Message?> message) {
    List<MessageLines> messageLines = [];

    message.forEach((sms) {
      if (sms != null) {
        MessageLines messageLine = MessageLines(
        message: sms,);
      messageLines.add(messageLine);
      }
    });

    return messageLines;
  }

//===========================================================================
// building the bottom sheet
  _buildBottomTF(KingscordState state, BuildContext context) {
    final ctx = context.read<KingscordCubit>();
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
                    ctx.onSendTxtImg(
                        churchId: widget.commuinity.id!,
                        kingsCordId: widget.kingsCord.id!);
                  }
                },
                icon: Icon(Icons.add_box_outlined)),
            Expanded(
              child: Container(
                height: textHeight,
                decoration: BoxDecoration(
                    color: Colors.grey[900],                                                                                        
                    borderRadius: BorderRadius.circular(5.0)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: TextFormField(
                      validator: (value) {
                          
  
                      },
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(fontSize: 18),
                      autocorrect: true,
                      controller: _messageController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      expands: true,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (messageText) {
                        if (messageText == '' || messageText == ' ') {
                          _mentionedController = null;
                          containsAt = false;
                        }
                        if (messageText[messageText.length-1] == '@') {
                          containsAt = true;
                          idxWhereStartWithat = messageText.length-1;
                          log("here you can add the @ container");
                        }
                        if (containsAt)
                          setState(() => _mentionedController = messageText.substring(idxWhereStartWithat+1, messageText.length));
                        if (messageText.endsWith(' ')) {
                          containsAt = false;
                          idxWhereStartWithat = 0;
                          _mentionedController = null;
                        }
                        if (messageText.length >= 25) 
                          setState(() => textHeight = 50.0);
                        else if (messageText.length >= 50)
                          setState(() => textHeight = 65.0);
                        else 
                          setState(() => textHeight = 30.0 );
                        ctx.onIsTyping(messageText.length >= 1);
                      },
                      decoration:
                          InputDecoration.collapsed(hintText: 'Mat 6:33'),
                    ),
                  ),
                ),
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
                          Set<String> mentionedUserNames = {};
                          var msgAsLst = _messageController.text.split(' ');
                          for (String msg in msgAsLst) {
                            if (msg.length >= 2 && msg[0] == '@') {
                              var mentionedUserName = msg.substring(1, msg.length);
                              if (!mentionedUserNames.contains(mentionedUserName)) {

                                mentionedUserNames.add(mentionedUserName);
                                if (mems)
                              }
                            }
                          }
                          ctx.onSendTxtMsg(
                              churchId: widget.commuinity.id!,
                              kingsCordId: widget.kingsCord.id!,
                              txtMsgBody: _messageController.text,
                              mentionIdsMap: mentionIdsMap,
                              cmTitle: widget.commuinity.name
                            );
                          ctx.onIsTyping(false);
                          _messageController.clear();
                        }
                      : null,
                ))
          ],
        ));
  }

  // for the mention user =================================================
  Widget _mentionUserContainer({required String? username}) {
    int? _containerHeight;
    List<Userr> potentialMentions = [];
    if (username != null) {for (Userr member in widget.commuinity.members) {
      if (member.username.startsWith(username)) {
        potentialMentions.add(member);
      }
    }}
    if (potentialMentions.length == 0) 
      _containerHeight = 0;
    else if (potentialMentions.length == 1)
      _containerHeight = 50;
    else if (potentialMentions.length == 2)
      _containerHeight = 100;
    else if (potentialMentions.length == 3)
      _containerHeight = 125;
    else if (potentialMentions.length >= 4)
      _containerHeight = 150;

    return username != null ? Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15)
      ),
      height: _containerHeight!.toDouble(),
      width: double.infinity,
      child: ListView.builder(
        itemCount: potentialMentions.length,
        itemBuilder: (BuildContext context, int index) {
          Userr _mentioned = potentialMentions[index];
          return ListTile(
            leading: ProfileImage(radius: 24, pfpUrl: _mentioned.profileImageUrl),
            title: Text(_mentioned.username, style: TextStyle(color: Color(hexColor.hexcolorCode(_mentioned.colorPref))), overflow: TextOverflow.fade,),
            onTap: () {
              var oldMessageControllerBody = _messageController.text.substring(0, idxWhereStartWithat);
              _messageController.text = oldMessageControllerBody += '@${_mentioned.username} ';
               _messageController.selection = TextSelection.fromPosition(TextPosition(offset:  _messageController.text.length));
               mentionIdsMap[_mentioned.id] = {
                'token': _mentioned.token,
                'username': _mentioned.username,
               };
              _mentionedController = null;
            },
          );
        }
      ),
    ) : SizedBox.shrink();
  }


  Widget _permissionDenied({required String messasge}) {

    return Padding(
      padding: const EdgeInsets.all(7.0),
      child: Container(
        width: double.infinity, height: 30,
        child: Center(child: Text(messasge, style: Theme.of(context).textTheme.bodyText1,)),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(7),
        ),
      ),
    );
  }

//============================================================================
    @override
    void initState() {
      super.initState();
        // isUserUpToDate(context, context.read<AuthBloc>().state.user!.uid, widget.kingsCord.memberInfo);
    }

  @override
  Widget build(BuildContext context) {




    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.kingsCord.cordName} ~ ${widget.commuinity.name}',
          style: TextStyle(letterSpacing: 1.0),
          overflow: TextOverflow.fade,
        ),
      ),
      // the body is a collumn containeing message widgets... with a bottom sheet for the txt controller
      body: BlocConsumer<KingscordCubit, KingscordState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          context.read<KingscordCubit>().onLoadInit(
            cmId: widget.commuinity.id!,
            kcId: widget.kingsCord.id!,
            limit: 30,
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // bulid message stream
              _buildMessageStream( commuinity: widget.commuinity, kingsCord: widget.kingsCord, msgs: state.msgs),
              //divider of a height 1
              Divider(height: 1.0),

              _mentionUserContainer(username: _mentionedController),

              memIds.contains(context.read<AuthBloc>().state.user!.uid) ?
              //bottom sheet
              _buildBottomTF(state, context) :

            _permissionDenied(messasge: "Join Commuinity To say whats up")
            ],
          );
        },
      ),
    );
  }
}


