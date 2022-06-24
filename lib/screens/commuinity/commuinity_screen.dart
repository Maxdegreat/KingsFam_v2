// this is the commuinity screen here we shold be able to acess many screens including some settings maybe if ur admin tho
// on the main room we need to pass a list of member ids which this, the church / commuinity contains. so will extract it and make the main room

//esentally this has the main room, events, storyes ,calls
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';
// import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/helpers/helpers.dart';
// import 'package:kingsfam/models/church_kingscord_model.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/build_church/cubit/buildchurch_cubit.dart';
import 'package:kingsfam/screens/commuinity/bloc/commuinity_bloc.dart';
// import 'package:kingsfam/screens/commuinity/screens/commuinity_calls/calls_home.dart';
// import 'package:kingsfam/screens/commuinity/screens/feed/commuinity_feed.dart';
// import 'package:kingsfam/screens/commuinity/screens/sounds/sounds.dart';
import 'package:kingsfam/screens/commuinity/screens/kings%20cord/kingscord.dart';
// import 'package:kingsfam/screens/commuinity/screens/stories/storys.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/widgets/widgets.dart';
import 'package:rive/rive.dart';

class CommuinityScreenArgs {
  final Church commuinity;

  CommuinityScreenArgs({required this.commuinity});
}

class CommuinityScreen extends StatefulWidget {
  final Church commuinity;

  const CommuinityScreen({Key? key, required this.commuinity})
      : super(key: key);

  static const String routeName = '/CommuinityScreen';
  static Route route({required CommuinityScreenArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => BlocProvider<CommuinityBloc>(
              create: (context) => CommuinityBloc(
                callRepository: context.read<CallRepository>(),
                authBloc: context.read<AuthBloc>(),
                churchRepository: context.read<ChurchRepository>(),
                storageRepository: context.read<StorageRepository>(),
                userrRepository: context.read<UserrRepository>(),
              )..add(CommuinityLoadCommuinity(commuinity: args.commuinity)),
              child: CommuinityScreen(
                commuinity: args.commuinity,
              ),
            ));
  }

  @override
  _CommuinityScreenState createState() => _CommuinityScreenState();
}

class _CommuinityScreenState extends State<CommuinityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _txtController;

  @override
  void initState() {
    super.initState();
    _txtController = TextEditingController();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _txtController.dispose();
    context.read<CommuinityBloc>().close();
    context.read<CommuinityBloc>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final userId = context.read<AuthBloc>().state.user!.uid;
    return BlocConsumer<CommuinityBloc, CommuinityState>(
      listener: (context, state) {
        if (state.status == CommuintyStatus.error) {
          log("commuinityScreenError: ${state.failure.code}");
          ErrorDialog(
            content:
                'hmm, something went worong. check your connection - ecode: commuinityScreenError: ${state.failure.code}',
          );
        }
      },
      builder: (context, state) {
        // make a list commuinity_nav using the state's list calls nd commuinities.

        //context.read<BuildchurchCubit>().isCommuinityMember(widget.commuinity);

        if (state.status == CommuintyStatus.loading) {
          return Container(child: Center(child: CircularProgressIndicator()));
        } else if (state.status == CommuintyStatus.loaded) {
          return _loadedDisplay(context, state);
        } else if (state.status == CommuintyStatus.error) {
          return Center(
              child: Text("error: my bad yall, i probably messed up the code"));
        } else
          return SizedBox.shrink();
      },
    );
  }

  Scaffold _loadedDisplay(BuildContext context, CommuinityState state) {
    var cmMemSet = widget.commuinity.members.keys.map((e) => e.id).toSet();
    var currId = context.read<AuthBloc>().state.user!.uid;
    return Scaffold(
        body: SafeArea(
      child: CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          expandedHeight: MediaQuery.of(context).size.height / 3,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(widget.commuinity.name),
            background: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: CachedNetworkImageProvider(
                              widget.commuinity.imageUrl),
                          fit: BoxFit.cover)),
                ),
                Container(
                    height: MediaQuery.of(context).size.height / 2,
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    alignment: Alignment.bottomCenter,
                    decoration: BoxDecoration(
                        // gradient: Gradient.linear(Alignment.bottomCenter, Alignment.topCenter, colors)
                        ))
              ],
            ),
          ),
          actions: [
            _settingsBtn(),
            _inviteButton(),
          ],
        ),
        SliverToBoxAdapter(
            child: Column(
          children: [
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                state.isMember
                    ? ElevatedButton(
                        onPressed: () {
                          _onLeaveCommuinity();
                        },
                        child: Text(
                          "...Leave :(",
                          style: TextStyle(color: Colors.red),
                        ),
                        style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.transparent),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                    side: BorderSide(color: Colors.red)))),
                      )
                    : joinBtn(state),
                SizedBox(width: 10),
                Text("${widget.commuinity.size} members")
              ],
            ),
            SizedBox(height: 25),
            //TODO remove row below?
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${widget.commuinity.name}\'s Content",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.fade,
                ),
              ],
            ),
            Container(
              height: 85,
              width: double.infinity,
              child: state.postDisplay.length > 0
                  ? ListView.builder(
                      itemCount: state.postDisplay.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        Post? post = state.postDisplay[index];
                        if (post != null) {
                          return contentPreview(post);
                        } else {
                          return SizedBox.shrink();
                        }
                      })
                  : Center(child: Text("Your Community's post will show here")),
            ),
            //ContentContaner(context),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Chat Rooms",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.fade,
                ),
                //TODO check btn
                new_kingscord(),
              ],
            ),
            //TODO below should work if change name else use lib?
            Column(
              children: state.kingCords.map((cord) {
                if (cord != null) {

                  return GestureDetector(
                      onTap: () {
                        // handels the navigation to the kingscord screen and also handels the 
                        // deletion of a noti if it eist. we check if noty eist by through a function insde the bloc.
                        Navigator.of(context).pushNamed(
                            KingsCordScreen.routeName,
                            arguments: KingsCordArgs(
                                commuinity: widget.commuinity,
                                kingsCord: cord));
                      
                        if (state.mentionedMap[cord.id] != false) {
                          // del the @ notification (del the mention)
                          String currId = context.read<AuthBloc>().state.user!.uid;
                          FirebaseFirestore.instance.collection(Paths.mention).doc(currId).collection(widget.commuinity.id!).doc(cord.id).delete();
                        }
                      },
                      onLongPress: () => _delKcDialog(
                          cord: cord, commuinity: widget.commuinity),
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 7,
                            bottom: 7,
                            left: MediaQuery.of(context).size.width / 7),
                        child: Container(
                          height: 35,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  bottomLeft: Radius.circular(5))),
                          child: Center(
                              child: Text(
                            cord.cordName,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                                color: state.mentionedMap[cord.id] == true
                                    ? Colors.amber
                                    : Colors.white,
                                fontWeight: state.mentionedMap[cord.id] == true
                                    ? FontWeight.w900
                                    : FontWeight.w700),
                          )),
                        ),
                      ));
                } else {
                  return SizedBox.shrink();
                }
              }).toList(),
            ),
            SizedBox(height: 15),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                "Voice / Video Rooms",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.fade,
              ),
              _new_call(),
            ]),
            Column(
              children: state.calls.map((call) {
                if (call != null) {
                  // return Container();
                  return GestureDetector(
                    onTap: () {},
                    // onTap: () => Navigator.of(context).pushNamed(
                    //     VideoCallScreen.routeName,
                    //     arguments: VideoCallScreenArgs(channlName: call.name, tokenUrl: call.id! + widget.commuinity.id! + call.name)),
                    child: callTile(context, call),
                  );
                } else {
                  return SizedBox.shrink();
                }
              }).toList(),
            )
          ],
        ))
      ]),
    ));
  }

  _delKcDialog({required KingsCord cord, required Church commuinity}) =>
      showModalBottomSheet(
          context: context,
          builder: (ctx) => BlocProvider<CommuinityBloc>(
              create: (_) => CommuinityBloc(
                  callRepository: ctx.read<CallRepository>(),
                  churchRepository: ctx.read<ChurchRepository>(),
                  storageRepository: ctx.read<StorageRepository>(),
                  authBloc: ctx.read<AuthBloc>(),
                  userrRepository: ctx.read<UserrRepository>()),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                        onPressed: () {
                          ctx
                              .read<CommuinityBloc>()
                              .delKc(cord: cord, commuinity: commuinity);
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Remove ${cord.cordName}",
                          style: TextStyle(color: Colors.red),
                        )),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Nevermind, keep ${cord.cordName}",
                          style: TextStyle(color: Colors.green),
                        )),
                  ],
                ),
              )));

  Widget contentPreview(Post post) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(
            CommuinityFeedScreen.routeName,
            arguments: CommuinityFeedScreenArgs(commuinity: widget.commuinity)),
        child: Container(
          height: 80,
          width: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                    image: post.imageUrl != null
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(post.imageUrl!),
                            fit: BoxFit.fill)
                        : post.thumbnailUrl != null
                            ? DecorationImage(
                                image: CachedNetworkImageProvider(
                                    post.thumbnailUrl!),
                                fit: BoxFit.fill)
                            : null,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10))),
              ),
              SizedBox(width: 10),
              Flexible(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.author.username,
                    style: TextStyle(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                  ),
                  Text(
                    'Posted to',
                    style: TextStyle(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                  ),
                  Text(
                    widget.commuinity.name,
                    style: TextStyle(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                  ),
                  // Text(post.date.toString(), style: TextStyle(fontWeight: FontWeight.w400),maxLines: 1, overflow: TextOverflow.fade,)
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }

  // Widget leaveBtn(bool isMemberGetter) =>

  Stack joinBtn(CommuinityState state) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 40,
          child: TextButton(
            child: Text(
              "JOINNN",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => _onJoinCommuinity(),
          ),
          decoration: BoxDecoration(
              color: Colors.grey[800], borderRadius: BorderRadius.circular(10)),
        ),
        PositionedDirectional(
          start: 0,
          child: Container(
            width: 5,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10))),
          ),
        )
      ],
    );
  }

  Padding ContentContaner(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(
              CommuinityFeedScreen.routeName,
              arguments:
                  CommuinityFeedScreenArgs(commuinity: widget.commuinity)),
          child: Text("Content")),
    );
  }

  Padding callTile(BuildContext context, CallModel call) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Container(
            height: 43,
            decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(5.0)),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 10.0),
                  SizedBox(
                    width: (MediaQuery.of(context).size.width / 1.8),
                    child: Text(
                      call.name,
                      style: Theme.of(context).textTheme.bodyText1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 5.0),
                  Text("${call.allMembersIds.length.toString()}/5 In Call")
                ],
              ),
            ),
          ),
          PositionedDirectional(
              end: 0,
              child: Container(
                height: 50,
                width: 30,
                decoration: BoxDecoration(
                    color: call.hasDilled ? Colors.green[400] : Colors.red[700],
                    borderRadius: BorderRadius.circular(5.0)),
              ))
        ],
      ),
    );
  }

  GestureDetector _new_call() {
    return GestureDetector(
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "VVR will be added shortly in an update"))), //_new_call_sheet(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Container(
            height: 25,
            width: 25,
            child: RiveAnimation.asset('assets/icons/add_icon.riv'),
          ),
        ));
  }

  _new_call_sheet() => showModalBottomSheet(
      context: context,
      builder: (context) => BlocProvider<BuildchurchCubit>(
          create: (context) => BuildchurchCubit(
              callRepository: context.read<CallRepository>(),
              churchRepository: context.read<ChurchRepository>(),
              storageRepository: context.read<StorageRepository>(),
              authBloc: context.read<AuthBloc>(),
              userrRepository: context.read<UserrRepository>()),
          child: Container(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 8.0),
                Center(
                    child: Text(
                  "Name For New Voice / Audio Call",
                  style: TextStyle(color: Colors.green[400]),
                )),
                SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: TextField(
                      decoration:
                          InputDecoration(hintText: "aye yooo, Enter a name"),
                      onChanged: (value) => _txtController.text = value),
                ),
                SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                      width: (double.infinity * .70),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Colors.green[400]),
                          onPressed: () {
                            if (_txtController.value.text.length != 0) {
                              context.read<BuildchurchCubit>().makeCallModel(
                                  commuinity: widget.commuinity,
                                  callName: _txtController.text);
                              Navigator.of(context).pop();
                              _txtController.clear();
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                        //title
                                        title: const Text("mmm, err my boi"),
                                        //content
                                        content: const Text(
                                            "be sure you add a name for the Channel room you are making"),
                                        //actions
                                        actions: [
                                          TextButton(
                                            child: Text(
                                              "Ok",
                                              style: TextStyle(
                                                  color: Colors.green[400]),
                                            ),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                          )
                                        ],
                                      ));
                            }
                          },
                          child: Text("Done"))),
                )
              ],
            ),
          )));

  GestureDetector new_kingscord() {
    return GestureDetector(
        onTap: () => new_kingsCord_sheet(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Container(
            height: 25,
            width: 25,
            child: RiveAnimation.asset('assets/icons/add_icon.riv'),
          ),
        ));
  }

  new_kingsCord_sheet() => showModalBottomSheet(
      context: context,
      builder: (context) => BlocProvider<BuildchurchCubit>(
          create: (context) => BuildchurchCubit(
              callRepository: context.read<CallRepository>(),
              churchRepository: context.read<ChurchRepository>(),
              storageRepository: context.read<StorageRepository>(),
              authBloc: context.read<AuthBloc>(),
              userrRepository: context.read<UserrRepository>()),
          child: Container(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 8.0),
                Center(
                    child: Text(
                  "Name For New Chat Room",
                  style: TextStyle(color: Colors.blue[300]),
                )),
                SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: TextField(
                      decoration: InputDecoration(hintText: "Enter a name"),
                      onChanged: (value) => _txtController.text = value),
                ),
                SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                      width: (double.infinity * .70),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Colors.blue[300]),
                          onPressed: () {
                            if (_txtController.value.text.length != 0) {
                              context.read<BuildchurchCubit>().makeKingsCord(
                                  commuinity: widget.commuinity,
                                  cordName: _txtController.text);
                              Navigator.of(context).pop();
                              _txtController.clear();
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                        //title
                                        title: const Text("mmm, err my boi"),
                                        //content
                                        content: const Text(
                                            "be sure you add a name for the Channel room you are making"),
                                        //actions
                                        actions: [
                                          TextButton(
                                            child: Text(
                                              "Ok",
                                              style: TextStyle(
                                                  color: Colors.blue[300]),
                                            ),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                          )
                                        ],
                                      ));
                            }
                          },
                          child: Text("Done"))),
                )
              ],
            ),
          )));

  _settingsBtn() {
    return IconButton(
        onPressed: () async {
          // final usersInCommuiinity = await context.read<BuildchurchCubit>().commuinityParcticipatents(ids: widget.commuinity.memberIds);
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return Container(
                  height: MediaQuery.of(context).size.height / 2,
                  decoration: BoxDecoration(
                    color: Colors.black,
                  ),
                  child: Column(
                    children: [
                      //child one is a tab bar
                      TabBar(
                        controller: _tabController,
                        tabs: [
                          Tab(text: "Participants"),
                          Tab(text: "Edit"),
                        ],
                      ),
                      //child 2 is the child of tab
                      Expanded(
                        //height: MediaQuery.of(context).size.height / 2.3,
                        child:
                            TabBarView(controller: _tabController, children: [
                          _participantsView(widget.commuinity.members.keys.toList()),
                          _editView(commuinity: widget.commuinity)
                        ]),
                      )
                    ],
                  ),
                );
              });
        },
        icon: Icon(Icons.settings));
  }

  Widget _inviteButton() {
    return IconButton(
        icon: Icon(Icons.person_add),
        onPressed: () async {
          final following =
              await context.read<BuildchurchCubit>().grabCurrFollowing();
          _inviteBottomSheet(following);
        });
  }

  //TODO ADMIN WHERE 2==2
  Widget _participantsView(List<Userr> users) {
    return ListView.builder(
      itemCount: widget.commuinity.members.length,
      itemBuilder: (BuildContext context, int index) {
        final participant = users[index];
        if (!participant.id.startsWith('del_')) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(
                    ProfileScreen.routeName,
                    arguments: ProfileScreenArgs(userId: participant.id)),
                child: ListTile(
                    leading: ProfileImage(
                      pfpUrl: participant.profileImageUrl,
                      radius: 25,
                    ),
                    title: Text(
                      participant.username,
                      style: 2 == 2
                          ? TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w700,
                            )
                          : null,
                      overflow: TextOverflow.fade,
                    ),
                    trailing: _moreOptinos(user: participant))),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  //TODO THE ADMIN
  Widget _moreOptinos({required Userr user}) {
    //check to see if the curr id is a admin or not
    //final isAdmin = context.read<BuildchurchCubit>().isAdmin(commuinity: widget.commuinity);
    final isAdmin = true;
    //widget.commuinity.memberInfo[context.read<AuthBloc>().state.user!.uid]['isAdmin']
    return IconButton(
      icon: Icon(Icons.more_vert),
      onPressed: () async {
        if (isAdmin) if (context.read<AuthBloc>().state.user!.uid == user.id)
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("You are the admin alredy...")));
        else
          return _adminsOptions(
              commuinity: widget.commuinity, participatant: user);
        else
          return _nonAdminOptions();
      },
    );
  }

  // TODO ADMIN
  Future<dynamic> _adminsOptions(
      {required Church commuinity, required Userr participatant}) {
    bool isParticipatantAdmin = true;
    return showDialog(
        context: context,
        builder: (context) {
          if (!isParticipatantAdmin) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                      onPressed: () {
                        context.read<BuildchurchCubit>().makeAdmin(
                            user: participatant, commuinity: commuinity);
                        Navigator.of(context).pop();
                        setState(() {});
                      },
                      child: FittedBox(
                          child: Text(
                        "Promote ${participatant.username} to an admin",
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyText1,
                      ))),
                  TextButton(
                      onPressed: () {
                        context.read<ChurchRepository>().leaveCommuinity(
                            commuinity: commuinity, currId: participatant.id);
                        Navigator.of(context).pop();
                        setState(() {});
                      },
                      child: FittedBox(
                          child: Text(
                              "Remove ${participatant.username} from ${widget.commuinity.name}",
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyText1))),
                ],
              ),
            );
          } else {
            return AlertDialog(
                content: Text(
              "${participatant.username} is alredy an Admin",
              overflow: TextOverflow.fade,
            ));
          }
        });
  }

  Future<dynamic> _nonAdminOptions() {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
                content: Text(
              "You not the admin",
              style: Theme.of(context).textTheme.bodyText1,
            )));
  }

  Widget _editView({required Church commuinity}) {
    return BlocProvider<BuildchurchCubit>(
        create: (context) => BuildchurchCubit(
            callRepository: context.read<CallRepository>(),
            churchRepository: context.read<ChurchRepository>(),
            storageRepository: context.read<StorageRepository>(),
            authBloc: context.read<AuthBloc>(),
            userrRepository: context.read<UserrRepository>()),
        child: Column(children: [
          ListTile(
              title: Text("Update Commuinity name",
                  style: Theme.of(context).textTheme.bodyText1),
              onTap: () async => _updateCommuinityName(
                  commuinity: commuinity, context: context)),
          ListTile(
            title: Text("Update Commuinity ImageUrl",
                style: Theme.of(context).textTheme.bodyText1),
            trailing: ProfileImage(radius: 25, pfpUrl: commuinity.imageUrl),
            onTap: () => _updateCommuinityImage(
              commuinity: commuinity,
            ),
          ),
          ListTile(
            title: Text("Update The About",
                style: Theme.of(context).textTheme.bodyText1),
            onTap: () async => _updateTheAbout(commuinity: commuinity),
          ),
          ElevatedButton(
              child:
                  Text('Update!', style: Theme.of(context).textTheme.bodyText1),
              onPressed: () => _updateEditView(context, commuinity))
        ]));
  }

  void _updateEditView(BuildContext context, Church commuinity) {
    var state = context.read<BuildchurchCubit>().state;
    print("okay we are in the submit func via the update! btn");
    print("This is the state name ${state.name}");
    print("This is the commuinity name ${commuinity.name}");
    //context.read<BuildchurchCubit>().submit();
    //print(commuinity.name);
  }

  Future<dynamic> _updateCommuinityName(
          {required Church commuinity, required BuildContext context}) async =>
      showModalBottomSheet(
          context: context,
          builder: (context) => BlocProvider<BuildchurchCubit>(
                create: (context) => BuildchurchCubit(
                    callRepository: context.read<CallRepository>(),
                    churchRepository: context.read<ChurchRepository>(),
                    storageRepository: context.read<StorageRepository>(),
                    authBloc: context.read<AuthBloc>(),
                    userrRepository: context.read<UserrRepository>()),
                child: Container(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 8.0),
                      Center(
                          child: Text(
                        "New Name For Commuinity",
                        style: TextStyle(color: Colors.white),
                      )),
                      SizedBox(height: 8.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: TextField(
                            decoration:
                                InputDecoration(hintText: "Enter a name"),
                            onChanged: (value) => _txtController.text = value),
                      ),
                      SizedBox(height: 8.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                            width: (double.infinity * .70),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.white),
                                onPressed: () {
                                  var state =
                                      context.read<BuildchurchCubit>().state;
                                  if (_txtController.value.text.length != 0) {
                                    context
                                        .read<BuildchurchCubit>()
                                        .onNameChanged(_txtController.text);
                                    context
                                        .read<BuildchurchCubit>()
                                        .lightUpdate(commuinity.id);
                                    Navigator.of(context).pop();
                                    this.setState(() {});
                                    _txtController.clear();
                                  } else {
                                    print(state.name);
                                    //  showDialog(
                                    //      context: context,
                                    //      builder: (BuildContext context) =>
                                    //          AlertDialog(
                                    //            //title
                                    //            title: const Text("mmm, err my boi"),
                                    //            //content
                                    //            content: const Text("be sure you add a name for the commuinity you are updating"),
                                    //            //actions
                                    //            actions: [
                                    //              TextButton(
                                    //                child: Text("Ok",style: TextStyle(color: Colors.green[400]),),
                                    //                onPressed: () =>Navigator.of(context).pop(),
                                    //              )
                                    //            ],
                                    //          ));
                                  }
                                },
                                child: Text(
                                  "Done, Upadate The Name!",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ))),
                      )
                    ],
                  ),
                ),
              ));

  Future<dynamic> _updateCommuinityImage({required Church commuinity}) async =>
      showModalBottomSheet(
          context: context,
          builder: (context) => BlocProvider<BuildchurchCubit>(
              create: (context) => BuildchurchCubit(
                  callRepository: context.read<CallRepository>(),
                  churchRepository: context.read<ChurchRepository>(),
                  storageRepository: context.read<StorageRepository>(),
                  authBloc: context.read<AuthBloc>(),
                  userrRepository: context.read<UserrRepository>()),
              child: StatefulBuilder(
                builder: (BuildContext context, setState) {
                  return Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final pickedFile =
                                await ImageHelper.pickImageFromGallery(
                                    context: context,
                                    cropStyle: CropStyle.rectangle,
                                    title: 'New Commuinity Avatar');
                            if (pickedFile != null)
                              context
                                  .read<BuildchurchCubit>()
                                  .onImageChanged(File(pickedFile.path));
                            setState(() {});
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height / 3.5,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                image: context
                                            .read<BuildchurchCubit>()
                                            .state
                                            .imageFile ==
                                        null
                                    ? DecorationImage(
                                        image: CachedNetworkImageProvider(
                                            commuinity.imageUrl),
                                        fit: BoxFit.fitWidth)
                                    : DecorationImage(
                                        image: FileImage(context
                                            .read<BuildchurchCubit>()
                                            .state
                                            .imageFile!),
                                        fit: BoxFit.fitWidth)),
                          ),
                        )
                      ],
                    ),
                  );
                },
              )));

  Future<dynamic> _updateTheAbout({required Church commuinity}) async =>
      showBottomSheet(
          context: context,
          builder: (context) => BlocProvider<BuildchurchCubit>(
                create: (context) => BuildchurchCubit(
                    callRepository: context.read<CallRepository>(),
                    churchRepository: context.read<ChurchRepository>(),
                    storageRepository: context.read<StorageRepository>(),
                    authBloc: context.read<AuthBloc>(),
                    userrRepository: context.read<UserrRepository>()),
                child: Container(
                  child:
                      Text("come back and add an expandable text form field"),
                ),
              ));

  Future<dynamic> _inviteBottomSheet(List<Userr> following) async =>
      showModalBottomSheet(
          context: context,
          builder: (context) => BlocProvider<BuildchurchCubit>(
                create: (context) => BuildchurchCubit(
                    callRepository: context.read<CallRepository>(),
                    churchRepository: context.read<ChurchRepository>(),
                    storageRepository: context.read<StorageRepository>(),
                    authBloc: context.read<AuthBloc>(),
                    userrRepository: context.read<UserrRepository>()),
                child: Container(
                  height: 200,
                  child: Column(
                    children: [
                      Container(
                        height: 25,
                        width: double.infinity,
                        color: Colors.grey[900],
                        child: Text("Invite fam to ${widget.commuinity.name}",
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyText1,
                            textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: following.length,
                          itemBuilder: (context, index) {
                            final user = following[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 5.0),
                              child: ListTile(
                                leading: ProfileImage(
                                    pfpUrl: user.profileImageUrl, radius: 25),
                                title: Text(user.username),
                                trailing: IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () => _showInviteDialog(user),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ));

  _showInviteDialog(Userr user) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Invite ${user.username}???",
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyText1),
            actions: [
              TextButton(
                child: Text("Nope, my b"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text("Yezzz!"),
                onPressed: () async {
                  await context.read<BuildchurchCubit>().inviteToCommuinity(
                      toUserId: user.id, commuinity: widget.commuinity);
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  _onJoinCommuinity() {
    context
        .read<CommuinityBloc>()
        .onJoinCommuinity(commuinity: widget.commuinity);
  }

  _onLeaveCommuinity() {
    context
        .read<CommuinityBloc>()
        .onLeaveCommuinity(commuinity: widget.commuinity);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "left! you may need to refresh home screen")));

  }

  showLeaveCommuinity() => showModalBottomSheet(
      context: context,
      builder: (context) => Container(
            //height: 200,
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  //height: 200,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.red),
                      onPressed: () {
                        _onLeaveCommuinity();
                        Navigator.popUntil(context,
                            ModalRoute.withName(Navigator.defaultRouteName));
                      },
                      child: Text("... I sad bye")),
                ),
                Container(
                  child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(primary: Colors.green),
                      child: Text("Chill, I wana stay fam")),
                )
              ],
            ),
          ));
}
