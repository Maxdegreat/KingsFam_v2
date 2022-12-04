import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/constants.dart';
import 'package:kingsfam/extensions/hexcolor.dart';
import 'package:kingsfam/helpers/helpers.dart';
import 'package:kingsfam/helpers/user_preferences.dart';

import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/commuinity/screens/kings%20cord/cubit/kingscord_cubit.dart';
import 'package:kingsfam/screens/commuinity/screens/kings%20cord/widgets/media_bottom_sheet.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/widgets/profile_image.dart';

import 'widgets/message_lines.dart';

// for kc's to be dynamic know that there is a rollesAllowed in the schema. This is defaulted to Members
// if members make so all can type as long as part of cm.

// now We need a cm setting. this role can change. for ex if we want to make the roles allowed be chior
// then we just use the chior rid.

//will probably need args to pass all members from the commuinity into main room
class KingsCordArgs {
  //class data
  final Church commuinity;
  final KingsCord kingsCord;
  final Userr usr;
  final Map<String, dynamic> userInfo;
  // class constructor
  KingsCordArgs(
      {required this.commuinity,
      required this.kingsCord,
      required this.userInfo,
      required this.usr});
}

class KingsCordScreen extends StatefulWidget {
  //class data
  final Church commuinity;
  final KingsCord kingsCord;
  final Map<String, dynamic> userInfo;
  final Userr usr;
  const KingsCordScreen(
      {Key? key,
      required this.commuinity,
      required this.kingsCord,
      required this.userInfo,
      required this.usr})
      : super(key: key);

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
                  kingsCordRepository: context.read<KingsCordRepository>(),
                  churchRepository: context.read<
                      ChurchRepository>() // may need to report to main reposityory collection
                  ),
              child: KingsCordScreen(
                usr: args.usr,
                userInfo: args.userInfo,
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
  // this controller is used to know when a user is mentioned
  String? _mentionedController;

  int idxWhereStartWithat = 0;

  bool containsAt = false;

  String currUsersName = "";

  bool showMediaPopUp = false;

  List<String> UrlBucket = [];

  HexColor hexColor = HexColor();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  double textHeight = 50;
  _buildMessageStream(
      {required Church commuinity,
      required KingsCord kingsCord,
      required List<Message?> msgs}) {
    // set the current username
    // add all users in cm into a list named memIds - to replace I just need to know if the user is allowed in the cm.
    // make a membersMapUsernameAsKey where you have username as a ker and {id, token} as values - to replace I use the cubit and it holds a list of mentioned users

    return Expanded(
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
      MessageLines messageLine;
      if (sms != null) {
        if (messageLines.length > 0) {
          messageLine = MessageLines(
            previousSenderAsUid: message != null ? message.last!.sender!.id : null,
            cmId: widget.commuinity.id!,
            kcId: widget.kingsCord.id!,
            message: sms,
            inhearatedCtx: context,
            kcubit: context.read<KingscordCubit>(),
          );
        } else {
          messageLine = MessageLines(
            cmId: widget.commuinity.id!,
            kcId: widget.kingsCord.id!,
            message: sms,
            inhearatedCtx: context,
            kcubit: context.read<KingscordCubit>()
          );
        }
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
        height: textHeight + 10,
        // margin: EdgeInsets.symmetric(horizontal: 5.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width / 1.28,
                height: textHeight,
                decoration: BoxDecoration(
                  color: Color(hc.hexcolorCode("#20263c")),
                  //border: Border.all(color: Colors.blue[900]!, width: .5),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Row(
                  children: [
                    IconButton(
                        // onPressed: () async => mediaBottomSheet(
                        //     kingscordCubit: ctx,
                        //     context: context,
                        //     cmId: widget.commuinity.id!,
                        //     kcId: widget.kingsCord.id!,
                        //     seenderUsername: currUsersName,
                        // ),
                        onPressed: () {
                          showMediaPopUp = !showMediaPopUp;
                          setState(() {});
                        },
                        icon: Icon(Icons.add)),
                    Expanded(
                      child: Container(
                        height: textHeight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3.0),
                          child: Align(
                            alignment: Alignment.center,
                            child: TextFormField(
                                // validator: (value) {},

                                textAlignVertical: TextAlignVertical.center,
                                style: TextStyle(fontSize: 18),
                                autocorrect: true,
                                controller: _messageController,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                expands: true,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                onChanged: (messageText) {
                                  if (messageText == '' || messageText == ' ') {
                                    _mentionedController = null;
                                    containsAt = false;
                                  }
                                  if (messageText[messageText.length - 1] ==
                                      '@') {
                                    containsAt = true;
                                    idxWhereStartWithat =
                                        messageText.length - 1;
                                    log("here you can add the @ container");
                                  }
                                  if (containsAt)
                                    setState(() => _mentionedController =
                                        messageText.substring(
                                            idxWhereStartWithat + 1,
                                            messageText.length));
                                  if (messageText.endsWith(' ')) {
                                    containsAt = false;
                                    idxWhereStartWithat = 0;
                                    _mentionedController = null;
                                  }
                                  if (messageText.length > 26)
                                    setState(() => textHeight = 70.0);
                                  else if (messageText.length > 57)
                                    setState(() {
                                      textHeight = 90;
                                    });
                                  else if (messageText.length < 24)
                                    setState(() => textHeight = 50.0);
                                  if (_messageController.text.length > 0) {
                                    ctx.onIsTyping(true);
                                    setState(() {
                                      
                                    });
                                  } else {
                                    ctx.onIsTyping(false);
                                    setState(() {
                                      
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(2),
                                  border: InputBorder.none,
                                  // filled: true,
                                  hintText: 'Think first',
                                  isCollapsed: true,
                                  // fillColor: Color(hc.hexcolorCode("#141829")!)
                                )),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: IconButton(
                    icon: Icon(Iconsax.send_1),
                      color: state.isTyping ? Colors.red[400] : Colors.white,
                    
                    onPressed: state.isTyping
                        ? () {
                            // this will be passed to the cubit then to the db. upon a get msg lines will psrse for a good look
                            String messageWithsSmbolesForParsing = "";
                            // map of mentioned info that will be added to the kc cubit
                            Map<String, dynamic> mentionedInfo = {};
                            for (var u in state.mentions) {
                              mentionedInfo[u.id] = {
                                "username": u.username,
                                "token": u.token,
                                'communityName': widget.commuinity.name,
                                'kingsCordName': widget.kingsCord.cordName,
                              };
                            }
                            var msgAsLst = _messageController.text.split(' ');
                            // for (String msg in msgAsLst) {
                            //   // handels if a shares a link

                            //   if (msg.length > 8 &&
                            //       msg.substring(0, 8) == 'https://') {
                            //     messageWithsSmbolesForParsing += '{{a-$msg}}';
                            //     // we want to check if the msg is mentioning someone
                            //   } else {
                            //     messageWithsSmbolesForParsing += '$msg ';
                            //   }
                            // }
                            if (_messageController.text.length > 0 && _messageController.text.trim() != "") {
                              ctx.removeReply();
                              ctx.onSendTxtMsg(
                              churchId: widget.commuinity.id!,
                              kingsCordId: widget.kingsCord.id!,
                              txtMsgBodyWithSymbolsForParcing:
                                  _messageController
                                      .text, //messageWithsSmbolesForParsing,
                              txtMsgWithOutSymbolesForParcing:
                                  _messageController.text,
                              mentionedInfo: mentionedInfo,
                              cmTitle: widget.commuinity.name,
                              kingsCordData: widget.kingsCord,
                              currUserName: currUsersName,
                              reply: state.replyMessage,
                            );
                            }
                            ctx.onIsTyping(false);
                            _messageController.clear();
                            ctx.clearMention();
                          }
                        : null,
                  ))
            ],
          ),
        ));
  }

  // for the mention user =================================================
  Widget _mentionUserContainer({required String? username}) {
    int? _containerHeight;
    List<Userr> potentialMentions = [];
    if (username != null) {
      // for (Userr member in widget.commuinity.members.keys) {
      //   if (member.username.startsWith(username)) {
      //     potentialMentions.add(member);
      //   }
      // }

      // read on the path of cm members while using the username caseList
      context.read<KingscordCubit>().searchMentionedUsers(
          cmId: widget.commuinity.id!, username: username);
    }
    var state = context.read<KingscordCubit>().state;
    if (state.potentialMentions.length == 0)
      _containerHeight = 0;
    else if (state.potentialMentions.length == 1)
      _containerHeight = 70;
    else if (state.potentialMentions.length == 2)
      _containerHeight = 120;
    else if (state.potentialMentions.length == 3)
      _containerHeight = 175;
    else if (state.potentialMentions.length >= 4) _containerHeight = 220;

    return username != null
        ? Container(
            decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(15)),
            height: _containerHeight!.toDouble(),
            width: double.infinity,
            child: ListView.builder(
                itemCount: state.potentialMentions.length,
                itemBuilder: (BuildContext context, int index) {
                  Userr _mentioned = state.potentialMentions[index];
                  return ListTile(
                    leading: ProfileImage(
                        radius: 24, pfpUrl: _mentioned.profileImageUrl),
                    title: Text(
                      _mentioned.username,
                      style: TextStyle(
                          color: Color(
                              hexColor.hexcolorCode(_mentioned.colorPref))),
                      overflow: TextOverflow.fade,
                    ),
                    onTap: () {
                      var oldMessageControllerBody = _messageController.text
                          .substring(0, idxWhereStartWithat);
                      _messageController.text = oldMessageControllerBody +=
                          '@${_mentioned.username} ';
                      _messageController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _messageController.text.length));
                      context
                          .read<KingscordCubit>()
                          .selectMention(userr: _mentioned);
                    },
                  );
                }),
          )
        : SizedBox.shrink();
  }

  Widget _permissionDenied({required String messasge}) {
    return Padding(
      padding: const EdgeInsets.all(7.0),
      child: Container(
        width: double.infinity,
        height: 30,
        child: Center(
            child: Text(
          messasge,
          style: Theme.of(context).textTheme.bodyText1,
        )),
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
    UserPreferences.updateKcTimeStamp(cmId: widget.commuinity.id!, kcId: widget.kingsCord.id!);
    super.initState();
    // isUserUpToDate(context, context.read<AuthBloc>().state.user!.uid, widget.kingsCord.memberInfo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(hc.hexcolorCode("#141829")),
        centerTitle: false,
        toolbarHeight: 50,
        title: Text(
          widget.kingsCord.cordName.length > 15
              ? '${widget.kingsCord.cordName.substring(0, 15)}'
              : '# ${widget.kingsCord.cordName}',
          overflow: TextOverflow.fade,
        ),
        actions: [
          IconButton(
              onPressed: () {
                // Nav to a settings room that will
                // 1) allow only certian roles to enter the room. only an owner / admin can do this
                // 2) allow someone to subscribe to get notifications
                Navigator.of(context).pushNamed(KingsCordSettings.routeName,
                    arguments: KingsCordSettingsArgs(
                        cmId: widget.commuinity.id!,
                        kcId: widget.kingsCord.id!));
              },
              icon: Icon(Icons.notifications_on_outlined))
        ],
      ),
      // the body is a collumn containeing message widgets... with a bottom sheet for the txt controller
      body: BlocConsumer<KingscordCubit, KingscordState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          currUsersName = widget.usr.username;

          context.read<KingscordCubit>().onLoadInit(
                cmId: widget.commuinity.id!,
                kcId: widget.kingsCord.id!,
                limit: 17,
              );
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  child: SvgPicture.asset(
                    widget.commuinity.themePack,
                    alignment: Alignment.topCenter,
                  ),
                  height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.black45),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // bulid message stream
                    _buildMessageStream(
                        commuinity: widget.commuinity,
                        kingsCord: widget.kingsCord,
                        msgs: state.msgs),
                    //divider of a height 1
                    Divider(height: 1.0),

                    state.replyMessage != null && state.replyMessage!.isNotEmpty
                      ? _showReplying(state)
                      : SizedBox.shrink(),

                    state.mentions.length > 0
                        ? _showMentioned(state)
                        : SizedBox.shrink(),

                    _mentionUserContainer(username: _mentionedController),

                    // this is can only ocour if the user is apart of the commuinity. in this case they can share
                    // content
                    state.fileShareStatus != FileShareStatus.inital
                        ? Container(
                            height: 90,
                            width: double.infinity,
                            color: Colors.transparent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Sharing Files Fam, Sit Tight...",
                                  overflow: TextOverflow.fade,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: state.filesToBePosted
                                      .map((file) => ProfileImage(
                                            radius: 27,
                                            pfpUrl: '',
                                            pfpImage: file,
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          )
                        : SizedBox.shrink(),

                    // use the state.isMem to know if the user is a part of cm.
                    // this values will have to be updated soon tho. because we want
                    // dynamic roles to be sourced
                    widget.userInfo["isMember"]
                        ? _buildBottomTF(state, context)
                        : _permissionDenied(
                            messasge: "Join Community To say whats up"),

                    showMediaPopUp ? showMedias() : SizedBox.shrink()
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  showMedias() {

    return Container(
      width: double.infinity,
      height: 55,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
       onPressed: () async {
                showMediaPopUp = !showMediaPopUp;
        setState(() {});
                      final pickedFile = await ImageHelper.pickImageFromGallery(
                          context: context,
                          cropStyle: CropStyle.rectangle,
                          title: 'send');
                      if (pickedFile != null) {
                        context.read<KingscordCubit>().onUploadImage(pickedFile);
                        context.read<KingscordCubit>().onSendTxtImg(
                      churchId: widget.commuinity.id!,
                      kingsCordId: widget.kingsCord.id!,
                      senderUsername: widget.usr.username);
                      }
                    },
              icon: Icon(Icons.image),
            ),
            IconButton(
              
              onPressed: () async {
                        showMediaPopUp = !showMediaPopUp;
        setState(() {});
                final pickedFile =
                    await ImageHelper.pickVideoFromGallery(context);
                if (pickedFile != null) {
                  context.read<KingscordCubit>().onUploadVideo(
                      videoFile: pickedFile,
                      cmId: widget.commuinity.id!,
                      kcId: widget.kingsCord.id!,
                      senderUsername: widget.usr.username);
                } else {}
              },
              
              
               icon: Icon(Icons.video_collection_rounded))
          ],
        ),
      ),
    );
  }

  _showReplying(KingscordState state) {
    return Container(
      color: Color.fromARGB(110, 255, 193, 7),
      height: 22,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: Align(
            alignment: Alignment.center,
            child: IconButton(onPressed: () {
              context.read<KingscordCubit>().removeReply();
            }, icon: Icon(Icons.cancel_outlined, size: 15,)))),
          Text("Replying to " + state.replyMessage!.split(":")[0].substring(20), overflow: TextOverflow.ellipsis,)
        ],
      ),
    );
  }

  _showMentioned(KingscordState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
            onPressed: () {
              context.read<KingscordCubit>().clearMention();
              // log(state.mentions.length.toString());
            },
            child: Row(
              children: [
                Text("Clear mentions  "),
                Icon(Icons.cancel_outlined),
              ],
            )),
        Container(
          height: 25,
          width: double.infinity,
          child: ListView.builder(
            itemCount: state.mentions.length,
            itemBuilder: (BuildContext context, int index) {
              Userr m = state.mentions[index];
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(m.username),
              );
            },
          ),
        ),
      ],
    );
  }
}
