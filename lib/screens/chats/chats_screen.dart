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
import 'package:kingsfam/screens/chats/bloc/chatscreen_bloc.dart';
import 'package:kingsfam/screens/commuinity/screens/feed/bloc/feed_bloc.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/widgets/feed_screen_widget.dart';
import 'package:kingsfam/widgets/widgets.dart';
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
    with SingleTickerProviderStateMixin {
  ScrollController scrollController = ScrollController();

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
    _tabController.addListener(tabControllerListener);
    scrollController.addListener(listenToScrolling);
    //super.build(context);
  }

  void listenToScrolling() {
    if (scrollController.position.atEdge) {
      if (scrollController.position.pixels != 0.0 &&
          scrollController.position.maxScrollExtent ==
              scrollController.position.pixels) {
        //  const snackBar = SnackBar(content: Text('Yay! A SnackBar!'));
        //  ScaffoldMessenger.of(context).showSnackBar(snackBar);
        context.read<ChatscreenBloc>()..add(ChatScreenPaginatePosts());
      }
    }
  }

  bool feedBeenLoaded = false;
  void tabControllerListener() {
    if (_tabController.index == 0 && !feedBeenLoaded) {
      context.read<ChatscreenBloc>()..add(ChatScreenFetchPosts());
      feedBeenLoaded = true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  late TabController _tabController;
  @override
  Widget build(BuildContext context) {
    HexColor hexcolor = HexColor();
    bool showKfCrown = false;
    final userId = context.read<AuthBloc>().state.user!.uid;
     return DefaultTabController(
       length: 3,
       child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text(
                'K I N G S F A M',
                style: TextStyle(color: Color(hexcolor.hexcolorCode('#FFC050'))),
              ),
              SizedBox(width: 5),
              KFCrownV2()
            ],
          ),
          actions: [
            IconButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(CreatePostScreen.routeName),
                icon: Icon(Icons.camera)),
            GestureDetector(
                onTap: () =>
                    Navigator.of(context).pushNamed(CreateComuinity.routeName),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Container(
                    height: 25,
                    width: 25,
                    child: RiveAnimation.asset('assets/icons/add_icon.riv'),
                  ),
                )),
          ],
        ),
        body: BlocConsumer<ChatscreenBloc, ChatscreenState>(
          listener: (context, state) {
            if (state.status == ChatStatus.error) {
              ErrorDialog(content: 'chat_screen e-code: ${state.failure.code}');
            }
          },
          builder: (context, state) {
            return NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool isScrollableInnerBox) {
                return <Widget>[
                  SliverAppBar(
                    floating: true,
                    toolbarHeight: 10,
                    expandedHeight: 10,
                    bottom: TabBar(
                      controller: _tabController,
                      tabs: [
                        Tab(text: "Feed"),
                        Tab(text: "Commuinities"),
                        Tab(text: "Chats")
                      ],
                    ))];
              }, 
            body: TabBarView(
                        controller: _tabController,
                        children: [
                          _feedViewUi(state),
                          ScreensForPageView().commuinity_view(userId, context),
                          ScreensForPageView().chats_view(userId)
                        ],
                      ));
  })));}

  _feedViewUi(ChatscreenState state) {
    return listviewsinglePost(state);
  }

  Widget listviewsinglePost(ChatscreenState state, ) {
    return Expanded(
      flex: 1,
      child: RefreshIndicator(
        onRefresh: () async => context.read<FeedBloc>()..add(FeedFetchPosts()),
        child: ListView.builder(
          shrinkWrap: false,
          controller: scrollController,
          itemCount: state.posts!.length,
          itemBuilder: (BuildContext context, int index) {
            if (index == state.posts!.length) {
              // TODO call paginate post
            }
            final Post? post = state.posts![index];
            final Post? posts = state.posts![index];
            if (post != null) {
              final LikedPostState = context.watch<LikedPostCubit>().state;
              final isLiked = LikedPostState.likedPostsIds.contains(post.id!);
              final recentlyLiked =
                  LikedPostState.recentlyLikedPostIds.contains(post.id!);
              return PostSingleView(
                isLiked: isLiked,
                post: post,
                recentlyLiked: recentlyLiked,
                onLike: () {
                  if (isLiked) {
                    context.read<LikedPostCubit>().unLikePost(post: post);
                  } else {
                    context.read<LikedPostCubit>().likePost(post: post);
                  }
                },
              );
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class KFCrownV2 extends StatelessWidget {
  const KFCrownV2({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      width: 22,
      color: Colors.black,
      child: RiveAnimation.asset('assets/crown/KFCrownV2.riv'),
    );
  }
}

class ScreensForPageView {
  // ignore: non_constant_identifier_names
  Widget commuinity_view(String userId, BuildContext) {
    return
    BlocConsumer<ChatscreenBloc, ChatscreenState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        return Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
            child: Container(
              height: MediaQuery.of(context).size.height / 1.25,
              width: double.infinity,
              child: Column(
                children: [
                  Expanded(
                      flex: 1,
                      child: ListView.builder(
                        itemCount: state.chs.length,
                        itemBuilder: (context, index) {
                          Church? commuinity = state.chs[index];
                          return GestureDetector(
                            onLongPress: () => _leaveCommuinity(
                                commuinity: commuinity!, context: context),
                            onTap: () => Navigator.of(context)
                                .pushNamed(CommuinityScreen.routeName,
                                    arguments: CommuinityScreenArgs(
                                      commuinity: commuinity!,
                                    )),
                            child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: FancyListTile(
                                    location: commuinity!.location,
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
                      )),
                ],
              ),
            ),
          );
      },
    );
  }

 

  Widget KFStarAmination(BuildContext context) {
    // instance of hexcolor class
    HexColor hexcolor = HexColor();
    return Column(
      children: [
        Container(
            height: 400,
            width: 400,
            child: RiveAnimation.asset('assets/crown/KFCrown.riv')),
        Center(
            child: Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Color(hexcolor.hexcolorCode('#FFC050'))),
            onPressed: () => helpDialog(context),
            child: Text("Hey Fam, Need Help?"),
          ),
        )),
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
                    Expanded(
                      flex: 1,
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

  //Widget _feed(context) => Container();

  //Container(child: FeedScreenWidget());
}

class Constants {
  Constants._();
  static const double padding = 20;
  static const double avatarRadius = 45;
}
