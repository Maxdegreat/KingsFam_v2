import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/helpers/helpers.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/commuinity/screens/kings%20cord/cubit/kingscord_cubit.dart';

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
                      KingsCordRepository>() // may need to report to main reposityory collection
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
  double textHeight = 35;
  _buildMessageStream({required Church commuinity, required KingsCord kingsCord}) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(Paths.church)
          .doc(commuinity.id)
          .collection(Paths.kingsCord)
          .doc(kingsCord.id)
          .collection(Paths.messages)
          .orderBy('date', descending: true)
          .limit(30)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return Expanded(
            child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 7.0),
          physics: AlwaysScrollableScrollPhysics(),
          reverse: true,
          children: _buildMessageLines(snapshot),
        ));
      },
    );
  }

//==========================================================================S 
  List<MessageLines> _buildMessageLines(AsyncSnapshot<QuerySnapshot> message) {
    List<MessageLines> messageLines = [];

    message.data?.docs.forEach((doc) {
      Message message = Message.fromDoc(doc);
      MessageLines messageLine = MessageLines(
        kingsCord: widget.commuinity.memberInfo,
        message: message,
      );
      messageLines.add(messageLine);
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
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(fontSize: 18),
                      autocorrect: true,
                      controller: _messageController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      expands: true,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (messageText) {
                        if (messageText.length >= 29) 
                          setState(() => textHeight = 50.0);
                        else if (messageText.length >= 87)
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
                        
                          //ctx.onTextMessage(_messageController.text);
                          ctx.onSendTxtMsg(
                              churchId: widget.commuinity.id!,
                              kingsCordId: widget.kingsCord.id!,
                              txtMsgBody: _messageController.text
                            );
                          ctx.onIsTyping(false);
                          _messageController.clear();
                        }
                      : null,
                ))
          ],
        ));
  }

  Future<void> isUserUpToDate(BuildContext context, String userId, Map<String, dynamic> fieldMap ) async {
    // if flag is true then we need to update this user in the commuinity else we do nothing
    bool flag = await context.read<UserrRepository>().updateUserInField(userId, fieldMap);
    print("The User Flag is flag: $flag ================");

    if (flag) {
      // now update the user
      context.read<KingscordCubit>().updateUserMap(userId: userId, commuinity: widget.commuinity, kingsCord: widget.kingsCord);
    }
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
          widget.commuinity.name,
          style: TextStyle(letterSpacing: 1.0),
        ),
      ),
      // the body is a collumn containeing message widgets... with a bottom sheet for the txt controller
      body: BlocConsumer<KingscordCubit, KingscordState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          return Column(
            children: [
              // bulid message stream
              _buildMessageStream( commuinity: widget.commuinity, kingsCord: widget.kingsCord  ),
              //divider of a height 1
              Divider(height: 1.0),
              widget.commuinity.memberIds.contains(context.read<AuthBloc>().state.user!.uid) ?
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


