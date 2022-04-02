import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/cubits/cubits.dart';
import 'package:kingsfam/extensions/hexcolor.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/church/church_repository.dart';
import 'package:kingsfam/repositories/post/post_repository.dart';
import 'package:kingsfam/screens/chats/bloc/chatscreen_bloc.dart';
import 'package:kingsfam/screens/commuinity/screens/feed/bloc/feed_bloc.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/widgets/feed_screen_widget.dart';
import 'package:kingsfam/widgets/widgets.dart';
import 'package:kingsfam/extensions/extensions.dart';
import 'package:rive/rive.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({
    Key? key,
  }) : super(key: key);

  static const String routeName = '/chatScreen';

  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen>
    with SingleTickerProviderStateMixin  {

  //bool get wantKeepAlive => true;

  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage() async {
    print("running setupInteractedMessage()");
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (2 == 2) {
      print("THE DANG MESSAGE DATA BOY ${message.data}");
      print("the date time is ${message.data['date']}");
      final obj = message.data;
      DateTime date = DateTime.parse(obj['date']);
      Chat chat = Chat(
          name: obj['name'],
          recentMessage: obj['recentMessage'],
          searchPram: obj['searchPram'],
          imageUrl: obj['imageUrl'],
          recentSender: obj['recentSender'],
          date: date,
          memberIds: obj['memberIds'],
          memberInfo: obj['memberInfo'],
          readStatus: obj['readStatus']);
      Navigator.pushNamed(
        context,
        ChatRoom.routeName,
        arguments: ChatRoomArgs(chat: chat),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    setupInteractedMessage();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    //super.build(context);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  late TabController _tabController;
  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthBloc>().state.user!.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text('K I N G S F A M'),
        actions: [
          IconButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(CreatePostScreen.routeName),
              icon: Icon(Icons.add_rounded)),
          IconButton(
              icon: Icon(Icons.menu_rounded),
              onPressed: () => Navigator.of(context).pushNamed(
                    CreateComuinity.routeName,
                  ))
        ],
      ),
      body: BlocConsumer<ChatscreenBloc, ChatscreenState>(
        listener: (context, state) {},
        builder: (context, state) {
          //final bloc = context.read<ChatscreenBloc>();
          return SingleChildScrollView(
            child: Column(
              children: [
                //ring_view(_ringStream,  context),
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: "Feed"),
                    Tab(text: "Commuinities"),
                    Tab(text: "Chats")
                  ],
                ),
                Container(
                  height: MediaQuery.of(context).size.height,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      ScreensForPageView()._feed(context),
                      ScreensForPageView().commuinity_view(userId, context),
                      ScreensForPageView().chats_view(userId)
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  //  FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>  ring_view(Future<DocumentSnapshot<Map<String, dynamic>>> _ringStream, BuildContext context) =>
  //  FutureBuilder(
  //  future: _ringStream,
  //  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
  //  if (snapshot.hasData && snapshot.data!.exists) {
//
  // Navigator.of(context).pushNamed(RingScreen.routeName, arguments: RingScreenArgs(call: CallModel.fromDoc(snapshot.data!)));
  // return SizedBox.shrink();
  //  } else {
  //  return SizedBox.shrink();
  //  }
  //  },
  //  );
}

class ScreensForPageView {
  // ignore: non_constant_identifier_names
  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> commuinity_view(String userId, BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(Paths.church)
          .where('memberIds', arrayContains: userId)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot2) {
        // look at navscreen.dart for the bottom sheet thing
        if (!snapshot2.hasData)
          return commuinitysList_chatsScreen(context);
        else if (snapshot2.data!.docs.length <= 0)
          return commuinitysList_chatsScreen(context);
        else 
          return commuintysListChatsScreen2(context, snapshot2);
        
      },
    );
  }

  Padding commuintysListChatsScreen2(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot2) {
    return Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
              child: Container(
                height: MediaQuery.of(context).size.height / 1.25,
                width: double.infinity,
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 1.25,
                      child: ListView.builder(
                        itemCount: snapshot2.data!.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          Church commuinity =
                              Church.fromDoc(snapshot2.data!.docs[index]);
                          return GestureDetector(
                            onLongPress: () => _leaveCommuinity(
                                commuinity: commuinity, context: context),
                            onTap: () => Navigator.of(context)
                                .pushNamed(CommuinityScreen.routeName,
                                    arguments: CommuinityScreenArgs(
                                      commuinity: commuinity,
                                    )),
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0),
                                child: FancyListTile(
                                    username: commuinity.name,
                                    imageUrl: commuinity.imageUrl,
                                    onTap: () => Navigator.of(context)
                                        .pushNamed(CommuinityScreen.routeName,
                                            arguments: CommuinityScreenArgs(
                                                commuinity: commuinity)),
                                    isBtn: false,
                                    BR: 12.0,
                                    height: 12.0,
                                    width: 12.0)),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
  }

  Widget commuinitysList_chatsScreen(BuildContext context) {
    // instance of hexcolor class
    HexColor hexcolor = HexColor();
    return Column(
      children: [
        Container(height: 400, width: 400, child:  RiveAnimation.asset('assets/crown/KFCrown.riv')) ,
        Center(
            child: Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary:  Color(hexcolor.hexcolorCode('#FFC050'))),
                onPressed: () => helpDialog(context),
                child: Text("Hey Fam, Need Help?"),
              ),
            )
          ),

      ],
    );
  }

  // ignore: non_constant_identifier_names
  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> chats_view(String userId) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(Paths.chats)
            .where('memberIds', arrayContains: userId)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot1) {
          if (!snapshot1.hasData) {
            return Center(child: Text('waiting for simpels img'));
          } else if (snapshot1.data!.docs.length <= 0) {
            return Center(child: Text('Join some chats!'));
          } else {
            return Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Container(
                      height: MediaQuery.of(context).size.height / 1.30,
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisSpacing: 20.0,
                          crossAxisSpacing: 20.0,
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                        ),
                        itemBuilder: (context, index) {
                          Chat chat = Chat.fromDoc(snapshot1.data!.docs[index]);
                          return GestureDetector(
                            onTap: () => Navigator.of(context).pushNamed(
                                ChatRoom.routeName,
                                arguments: ChatRoomArgs(chat: chat)),
                            child: _buildChat(
                                chat: chat, context: context, userId: userId),
                          );
                        },
                        itemCount: snapshot1.data!.docs.length,
                      ),
                    )
                  ],
                ));
          }
        });
  }

  Widget _buildChat({BuildContext? context, Chat? chat, String? userId}) {
    return Container(
      height: 20,
      decoration: BoxDecoration(
          color: Colors.grey[800], borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChatImage(chatUrl: chat!.imageUrl),
            SizedBox(height: 5),
            Center(
              child: Text(
                chat.name,
                style: Theme.of(context!).textTheme.bodyText1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 15),
            Center(
                child:
                    Text('${chat.memberInfo[chat.recentSender]['username']}')),
            Center(
                child: //Text("${chat.date.timeAgo()}"),
                    Text("chats screen"))
          ],
        ),
      ),
    );
  }

  Future<dynamic> _leaveCommuinity(
      {required Church commuinity, required BuildContext context}) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Leave ${commuinity.name}???"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("NOOO", style: TextStyle(color: Colors.white))),
                TextButton(
                    onPressed: () async {
                      //to get out of a commuinity you will have to update the commuinity orrr delete certian criteria
                      await context.read<ChurchRepository>().leaveCommuinity(
                          commuinity: commuinity,
                          currId: context.read<AuthBloc>().state.user!.uid);
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Did I Stutter???",
                      style: TextStyle(color: Colors.red),
                    ))
              ],
            ));
  }

  Widget _feed(context) => FeedScreenWidget();
}

class Constants{
  Constants._();
  static const double padding =20;
  static const double avatarRadius =45;
}