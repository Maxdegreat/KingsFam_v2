// this is the commuinity screen here we shold be able to acess many screens including some settings maybe if ur admin tho
// on the main room we need to pass a list of member ids which this, the church / commuinity contains. so will extract it and make the main room

//esentally this has the main room, events, storyes ,calls

import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helpers/helpers.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/extensions/hexcolor.dart';

import 'package:kingsfam/helpers/helpers.dart';
import 'package:kingsfam/helpers/navigator_helper.dart';

import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/roles/role_types.dart';
import 'package:kingsfam/screens/build_church/cubit/buildchurch_cubit.dart';
import 'package:kingsfam/screens/commuinity/bloc/commuinity_bloc.dart';
import 'package:kingsfam/screens/commuinity/screens/kings%20cord/kingscord.dart';
import 'package:kingsfam/screens/commuinity/screens/roles/roles_screen.dart';
import 'package:kingsfam/extensions/date_time_extension.dart';

import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/widgets/widgets.dart';
import 'package:rive/rive.dart';
import 'package:flutter/src/painting/gradient.dart' as paint;
import 'package:kingsfam/screens/commuinity/actions.dart' as cmActions;

import 'package:video_player/video_player.dart';

import '../profile/bloc/profile_bloc.dart';
import 'helper.dart';

HexColor hc = HexColor();

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
              )..add(CommuinityLoadCommuinity(
                  commuinity: args.commuinity,
                )),
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
  Map<String, dynamic> accessMap = {};
  String? currRole;

  @override
  void initState() {
    currRole = getAccessCmHelp(
        widget.commuinity, context.read<AuthBloc>().state.user!.uid);
    super.initState();
    _txtController = TextEditingController();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _txtController.dispose();
    // context.read<CommuinityBloc>().close();
    // context.read<CommuinityBloc>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final userId = context.read<AuthBloc>().state.user!.uid;
    return BlocConsumer<CommuinityBloc, CommuinityState>(
        listener: (context, state) {
      if (state.status == CommuintyStatus.error) {
        ErrorDialog(
          content:
              'hmm, something went worong. check your connection - ecode: commuinityScreenError: ${state.failure.code}',
        );
      }
    }, builder: (context, state) {
      return Scaffold(
          body: SafeArea(
        child: _mainScrollView(context, state),
      ));
    });
  }

  Padding _mainScrollView(
      BuildContext context, CommuinityState state) {
    Color primaryColor = Colors.white;
    Color secondaryColor = Color(hc.hexcolorCode('#141829'));
    Color backgoundColor = Color(hc.hexcolorCode('#20263c'));
    if (state.themePack != "none") {
      if (state.themePack == "assets/cm_backgrounds/2.svg") {
        // log("theme pack contains 1.svg");
        primaryColor = Colors.pink[700]!;
        secondaryColor = Colors.blue[700]!;
        backgoundColor = Color.fromARGB(255, 4, 34, 78);
      }
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomScrollView(slivers: <Widget>[
        cmSliverAppBar(context: context, cmBloc: context.read<CommuinityBloc>()),
        SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Stack(
          children: [
              Container(
                alignment: Alignment.topCenter,
                child: SvgPicture.asset(
                  state.themePack,
                  alignment: Alignment.topCenter,
                ),
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                decoration: BoxDecoration(color: backgoundColor),
              ),
              // Container(height: MediaQuery.of(context).size.height, width: double.infinity, color: Colors.black38,),
              Column(
                children: [
                  state.status == CommuintyStatus.loading
                      ? LinearProgressIndicator()
                      : SizedBox.shrink(),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      state.isMember == null
                          ? SizedBox.shrink()
                          : state.isMember != false
                              ? ElevatedButton(
                                  onPressed: () {
                                    if (currRole != Roles.Owner) {
                                      _onLeaveCommuinity();
                                    } else {
                                      snackBar(
                                          snackMessage:
                                              "Owners can not abandon ship",
                                          context: context,
                                          bgColor: Colors.red);
                                    }
                                  },
                                  child: Text(
                                    "...Leave ",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  style: ButtonStyle(
              
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.white),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.transparent),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius: BorderRadius.zero,
                                              side:
                                                  BorderSide(color: Colors.red)))),
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
                          color: primaryColor,
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
                        : Center(
                            child: state.status == CommuintyStatus.loading
                                ? Text("One Second ...")
                                : Text("Your Community Post Will Show Here")),
                  ),
                  //ContentContaner(context),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Chat Rooms",
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.fade,
                      ),
                      collapseOrExpand(context.read<CommuinityBloc>(), 'cord'),
                      new_kingscord(cmBloc: context.read<CommuinityBloc>()),
                    ],
                  ),
                  //TODO below should work if change name else use lib?
                  Column(
                    children: state.collapseCordColumn
                        ? [SizedBox.shrink()]
                        : state.kingCords.map((cord) {
                            if (cord != null) {
                              return GestureDetector(
                                  onTap: () {
                                    // handels the navigation to the kingscord screen and also handels the
                                    // deletion of a noti if it eist. we check if noty eist by through a function insde the bloc.
                                    log(
                                      "widget.cm for naving to cord: " +
                                          widget
                                              .commuinity
                                              .members[context
                                                  .read<ProfileBloc>()
                                                  .state
                                                  .userr]
                                              .toString(),
                                    );
                                    Navigator.of(context).pushNamed(
                                        KingsCordScreen.routeName,
                                        arguments: KingsCordArgs(
                                            commuinity: widget.commuinity,
                                            kingsCord: cord));

                                    if (state.mentionedMap[cord.id] != false) {
                                      // del the @ notification (del the mention)
                                      String currId =
                                          context.read<AuthBloc>().state.user!.uid;
                                      FirebaseFirestore.instance
                                          .collection(Paths.mention)
                                          .doc(currId)
                                          .collection(widget.commuinity.id!)
                                          .doc(cord.id)
                                          .delete();
                                    }
                                  },
                                  onLongPress: () => _delKcDialog(
                                      cord: cord, commuinity: widget.commuinity),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: 7,
                                        bottom: 7,
                                        left:
                                            MediaQuery.of(context).size.width / 7),
                                    child: Container(
                                      height: 55,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          color: secondaryColor,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(5),
                                              bottomLeft: Radius.circular(5))),
                                      child: Center(
                                          child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              cord.cordName,
                                              overflow: TextOverflow.fade,
                                              style: TextStyle(
                                                  color:
                                                      state.mentionedMap[cord.id] ==
                                                              true
                                                          ? Colors.amber
                                                          : Colors.white,
                                                  fontWeight:
                                                      state.mentionedMap[cord.id] ==
                                                              true
                                                          ? FontWeight.w900
                                                          : FontWeight.w700),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  cord.recentSender[1].length >= 10
                                                      ? cord.recentSender[1]
                                                          .substring(0, 10)
                                                      : cord.recentSender[1],
                                                  style: TextStyle(
                                                      color: primaryColor,
                                                      fontSize: 17),
                                                  overflow: TextOverflow.fade,
                                                ),
                                                SizedBox(
                                                  width: 7,
                                                ),
                                                Text(
                                                  cord.recentTimestamp.timeAgo(),
                                                  style: TextStyle(
                                                      color: Colors.grey[300],
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold),
                                                  overflow: TextOverflow.fade,
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      )),
                                    ),
                                  ));
                            } else {
                              return SizedBox.shrink();
                            }
                          }).toList(),
                  ),
                  SizedBox(height: 15),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                          "About This Community",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.fade,
                        ),
                  ),
                  SizedBox(height: 5),
                  ConstrainedBox(constraints: BoxConstraints(
                    minHeight: 75,
                    minWidth: double.infinity,
                  ), child: Container(
                    margin: Margin.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: widget.commuinity.about.isNotEmpty ? Text(widget.commuinity.about, textAlign: TextAlign.center) : Text("Nothing To See Here ..."),
                    ),
                    decoration: BoxDecoration(
                      color: Color(hc.hexcolorCode('#141829')),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),)
                ],
              ),
          ],
        ),
            ))
      ]),
    );
  }

  SliverAppBar cmSliverAppBar(
      {required BuildContext context, required CommuinityBloc cmBloc}) {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height / 3,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(widget.commuinity.name),
        background: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                        image: CachedNetworkImageProvider(
                            widget.commuinity.imageUrl),
                        fit: BoxFit.cover)),
              ),
            ),
            Container(
                height: MediaQuery.of(context).size.height / 2,
                padding: EdgeInsets.symmetric(horizontal: 5.0),
                alignment: Alignment.bottomCenter,
                decoration: const BoxDecoration(
                  gradient: paint.LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: <Color>[], 
                    // Gradient from https://learnui.design/tools/gradient-generator.html
                    tileMode: TileMode.mirror,
                  ),
                ))
          ],
        ),
      ),
      actions: [
        _settingsBtn(cmBloc: cmBloc),
        _inviteButton(),
        // _themePackButton()
      ],
    );
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
                  mainAxisSize: MainAxisSize.min,
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
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                          "Hey family. hint: You MUST have at least one chat room"),
                    )
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
                            fit: BoxFit.fitWidth)
                        : post.thumbnailUrl != null
                            ? DecorationImage(
                                image: CachedNetworkImageProvider(
                                    post.thumbnailUrl!),
                                fit: BoxFit.fitWidth)
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
              "JOIN!",
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

  Padding contentContaner(BuildContext context) {
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

  

  Widget new_kingscord({required CommuinityBloc cmBloc}) {
    cmActions.Actions actions = cmActions.Actions();
    if ((currRole != null && currRole == Roles.Owner) ||
        (currRole != null &&
            actions.hasAccess(
                role: currRole!,
                action: cmActions.Actions.communityActions[4]))) {
      return GestureDetector(
          onTap: () => new_kingsCord_sheet(cmBloc),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Container(
              height: 25,
              width: 25,
              child: RiveAnimation.asset('assets/icons/add_icon.riv'),
            ),
          ));
    } else
      return SizedBox.shrink();
  }

  new_kingsCord_sheet(CommuinityBloc cmBloc) => showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
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
                        style:
                            ElevatedButton.styleFrom(primary: Colors.blue[300]),
                        onPressed: () {
                          if (_txtController.value.text.length == 0) {
                            snackBar(
                                snackMessage:
                                    "be sure you add a name for the Chat Room you are making",
                                context: context,
                                bgColor: Colors.red[400]);
                          } else if (_txtController.value.text.length > 17) {
                            snackBar(
                                snackMessage:
                                    "Yo, Fam less than or equal to 17 chars please nd thanks",
                                context: context,
                                bgColor: Colors.red[400]);
                          } else {
                            // make a new channel
                            cmBloc.makeNewKc(
                                commuinity: widget.commuinity,
                                cordName: _txtController.value.text,
                                ctx: context);
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text("Done"))),
              )
            ],
          ),
        );
      });

  _settingsBtn({required CommuinityBloc cmBloc}) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, top: 10),
      child: IconButton(
          onPressed: () async {
            // final usersInCommuiinity = await context.read<BuildchurchCubit>().commuinityParcticipatents(ids: widget.commuinity.memberIds);
            Userr? currUserr;
            List<Userr> users = widget.commuinity.members.keys.toList();
            for (int i = 0; i < users.length; i++) {
              if (users[i].id == context.read<AuthBloc>().state.user!.uid) {
                currUserr = users[i];
              }
            }
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Container(
                    height: MediaQuery.of(context).size.height / 2,
                    decoration: BoxDecoration(
                      color: Color(hc.hexcolorCode('#141829')),
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
                            currUserr != null
                                ? _participantsView(
                                    widget.commuinity.members.keys.toList(),
                                    widget.commuinity.members,
                                    currUserr)
                                : SizedBox.shrink(),
                            _editView(
                                cmBloc: cmBloc,
                                commuinity: widget.commuinity,
                                buildchurchCubit:
                                    context.read<BuildchurchCubit>(),
                                communitiyBloc: context.read<CommuinityBloc>(),
                                currRole: currRole)
                          ]),
                        )
                      ],
                    ),
                  );
                });
          },
          icon: Icon(Icons.settings)),
    );
  }

  Widget _inviteButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, top: 10),
      child: IconButton(
          icon: Icon(Icons.person_add),
          onPressed: () async {
            final following =
                await context.read<BuildchurchCubit>().grabCurrFollowing();
            _inviteBottomSheet(following);
          }),
    );
  }

  Widget _themePackButton() {
    return TextButton(
        onPressed: () {
          NavHelper().navToUpdateCmTheme(
              context,
              context.read<CommuinityBloc>(),
              widget.commuinity.name,
              widget.commuinity.id!);
        },
        child: Text("ThemePack"));
  }

  //TODO ADMIN WHERE 2==2
  Widget _participantsView(
      List<Userr> users, Map<Userr, dynamic> memberInfo, Userr currUserr) {
    List<Userr> roleOrderedList = orderListByRole(memberInfo, users);
    return ListView.builder(
      itemCount: roleOrderedList.length,
      itemBuilder: (BuildContext context, int index) {
        final participant = roleOrderedList[index];

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
                    subtitle: Text(memberInfo[roleOrderedList[index]]['role']),
                    title: Text(
                      participant.username,
                      style: memberInfo[participant]['role'] == Roles.Owner
                          ? TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.w700,
                            )
                          : memberInfo[participant]['role'] == Roles.Admin
                              ? TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w700,
                                )
                              : memberInfo[participant]['role'] == Roles.Elder
                                  ? TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w700,
                                    )
                                  : null,
                      overflow: TextOverflow.fade,
                    ),
                    trailing: _moreOptinos(
                        participant: participant,
                        memberInfo: memberInfo,
                        currUserr: currUserr))),
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }

  //TODO THE ADMIN
  Widget _moreOptinos(
      {required Userr participant,
      required Map<Userr, dynamic> memberInfo,
      required Userr currUserr}) {
    //check to see if the curr id is a admin or not
    //final isAdmin = context.read<BuildchurchCubit>().isAdmin(commuinity: widget.commuinity);
    //widget.commuinity.memberInfo[context.read<AuthBloc>().state.user!.uid]['isAdmin']
    String role = memberInfo[currUserr]['role'];
    cmActions.Actions hasPermissions = cmActions.Actions();

    return IconButton(
      icon: Icon(Icons.more_vert),
      onPressed: () async {
        if (hasPermissions.hasAccess(
            role: role, action: cmActions.Actions.communityActions[3])) {
          if (context.read<AuthBloc>().state.user!.uid == participant.id) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("your role is $role, can not modify this")));
          } else {
            return _adminsOptions(
                commuinity: widget.commuinity,
                participatant: participant,
                role: role);
          }
        } else
          return _nonAdminOptions(role);
      },
    );
  }

  // TODO ADMIN
  Future<dynamic> _adminsOptions(
      {required Church commuinity,
      required Userr participatant,
      required String role}) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          if (role == Roles.Admin || role == Roles.Owner) {
            return changRolePopUp(context, participatant, commuinity);
          } else {
            return Text(
              "${participatant.username} is alredy an Admin",
            );
          }
        });
  }

  Column changRolePopUp(
      BuildContext context, Userr participatant, Church commuinity) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Text("Options: " + participatant.username),
        ),
        TextButton(
            onPressed: () {
              context.read<BuildchurchCubit>().changeRole(
                  user: participatant,
                  commuinityId: commuinity.id!,
                  role: Roles.Admin);
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
              context.read<BuildchurchCubit>().changeRole(
                  user: participatant,
                  commuinityId: commuinity.id!,
                  role: Roles.Elder);
              Navigator.of(context).pop();
              setState(() {});
            },
            child: FittedBox(
                child: Text(
              "Make ${participatant.username} an Elder",
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyText1,
            ))),
        TextButton(
            onPressed: () {
              context.read<BuildchurchCubit>().changeRole(
                  user: participatant,
                  commuinityId: commuinity.id!,
                  role: Roles.Member);
              Navigator.of(context).pop();
              setState(() {});
            },
            child: FittedBox(
                child: Text(
              "Make ${participatant.username} a Member",
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyText1,
            ))),
        TextButton(
            onPressed: () {
              try {
                context.read<ChurchRepository>().leaveCommuinity(
                    commuinity: commuinity, leavingUserId: participatant.id);
                Navigator.of(context).pop();
              } catch (e) {
                log("err: " + e.toString());
              }

              Navigator.of(context).pop();
            },
            child: FittedBox(
                child: Text(
                    "Remove ${participatant.username} from ${widget.commuinity.name}",
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyText1))),
        TextButton(
            onPressed: () {
              if (commuinity.members[participatant]['role'] == Roles.Owner) {
                snackBar(
                    snackMessage: "You can not ban the community owner",
                    context: context,
                    bgColor: Colors.red);
                return;
              }
              context.read<ChurchRepository>().banFromCommunity(
                  community: commuinity, baningUserId: participatant.id);
              Navigator.of(context).pop();
              snackBar(
                  snackMessage:
                      "Update will show onReload, user can no longer join",
                  context: context);
            },
            child: FittedBox(
                child: Text(
              "ban ${participatant.username}",
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyText1,
            )))
      ],
    );
  }

  Future<dynamic> _nonAdminOptions(String role) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
                content: Text(
              "your role is $role so you can not access these options",
              style: Theme.of(context).textTheme.bodyText1,
            )));
  }

  Widget _editView(
      {required CommuinityBloc cmBloc,
      required Church commuinity,
      required BuildchurchCubit buildchurchCubit,
      required CommuinityBloc communitiyBloc,
      required String? currRole}) {
    if (currRole != null &&
        (currRole == Roles.Admin || currRole == Roles.Owner)) {
      String assetNameForTheme = communitiyBloc.state.themePack == "none"
          ? "assets/cm_backgrounds/2.svg"
          : communitiyBloc.state.themePack;
      return SingleChildScrollView(
        child: Column(children: [
          ListTile(
              title: Text("Update the Community name",
                  style: Theme.of(context).textTheme.bodyText1),
              onTap: () async => _updateCommuinityName(
                  commuinity: commuinity,
                  buildchurchCubit: context.read<BuildchurchCubit>())),
          ListTile(
            title: Text("Update Community ImageUrl",
                overflow: TextOverflow.fade,
                style: Theme.of(context).textTheme.bodyText1),
            trailing: ProfileImage(radius: 25, pfpUrl: commuinity.imageUrl),
            onTap: () => _updateCommuinityImage(
                commuinity: commuinity, buildchurchCubit: buildchurchCubit),
          ),
          ListTile(
            title: Text(
              "Update the community Theme Pack",
              style: GoogleFonts.getFont('Montserrat'),
              overflow: TextOverflow.fade,
            ),
            trailing: Container(
              height: 50,
              width: 50,
              child: SvgPicture.asset(
                assetNameForTheme,
                fit: BoxFit.fill,
                allowDrawingOutsideViewBox: false,
                clipBehavior: Clip.hardEdge,
              ),
              decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(50)),
            ),
            onTap: () => NavHelper().navToUpdateCmTheme(
                context, cmBloc, commuinity.name, commuinity.id!),
          ),
          ListTile(
            title: Text(
              "Update The About",
              style: Theme.of(context).textTheme.bodyText1,
              overflow: TextOverflow.fade,
            ),
            onTap: () async => _updateTheAbout(
                commuinity: commuinity,
                buildchurchCubit: context.read<BuildchurchCubit>()),
          ),
          ListTile(
              title: Text(
                "Manage & Update Roles",
                style: Theme.of(context).textTheme.bodyText1,
                overflow: TextOverflow.fade,
              ),
              onTap: () {
                Church ch = Church.empty;
                Navigator.of(context).pushNamed(RolesScreen.routeName,
                    arguments: RoleScreenArgs(
                        community: ch.copyWith(
                      id: commuinity.id,
                      members: commuinity.members,
                      name: commuinity.name,
                    )));
              }),
          ListTile(
            title: Text(
              "Baned Users",
              style: Theme.of(context).textTheme.bodyText1,
              overflow: TextOverflow.fade,
            ),
            onTap: () {
              Navigator.of(context).pushNamed(ShowBanedUsers.routeName,
                  arguments:
                      ShowBanedUsersArgs(cmId: commuinity.id!, cmBloc: cmBloc));
            },
          )
        ]),
      );
    } else
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
              "Hey Fam you must be a Owner or Admin Role to access these settings"),
          Text("with great power comes a lot of responsibility yk yk")
        ],
      );
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
          {required Church commuinity,
          required BuildchurchCubit buildchurchCubit}) async =>
      showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 8.0),
              Center(
                  child: Text(
                "New Name For Community",
                style: TextStyle(color: Colors.white),
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
                        style: ElevatedButton.styleFrom(primary: Colors.white),
                        onPressed: () {
                          var state = buildchurchCubit.state;
                          if (_txtController.value.text.length != 0) {
                            if (_txtController.value.text.length <= 19) {
                              buildchurchCubit
                                  .onNameChanged(_txtController.text);
                              buildchurchCubit.lightUpdate(commuinity.id!,
                                  1); // ----------- The method that calls thr update
                              Navigator.of(context).pop();
                              this.setState(() {});
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
                                            "The name can not be longer than 19 chars"),
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
                          } else {
                            print(state.name);
                            showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                      //title
                                      title: const Text("mmm, err my boi"),
                                      //content
                                      content: const Text(
                                          "be sure you add a name for the commuinity you are updating"),
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
      );

  Future<dynamic> _updateCommuinityImage(
          {required Church commuinity,
          required BuildchurchCubit buildchurchCubit}) async =>
      showModalBottomSheet(
          context: context,
          builder: (context) => StatefulBuilder(
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
                                    title: 'New Commuinity wrap');
                            if (pickedFile != null)
                              buildchurchCubit
                                  .onImageChanged(File(pickedFile.path));
                            buildchurchCubit.lightUpdate(commuinity.id!, 2);
                            snackBar(
                                snackMessage:
                                    '${commuinity.name}\'s avatar is updated. leave and join back to see changes',
                                context: context);

                            setState(() {});
                          },
                          child: Container(
                              //height: MediaQuery.of(context).size.height / 3.5,
                              width: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Text(
                                        "Hey 👋🏾, Once you pick a Wrap or image ${commuinity.name} will be updated",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                        overflow: TextOverflow.fade),
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.height /
                                        3.5,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        image: buildchurchCubit
                                                    .state.imageFile ==
                                                null
                                            ? DecorationImage(
                                                image:
                                                    CachedNetworkImageProvider(
                                                        commuinity.imageUrl),
                                                fit: BoxFit.fitWidth)
                                            : DecorationImage(
                                                image: FileImage(
                                                    buildchurchCubit
                                                        .state.imageFile!),
                                                fit: BoxFit.fitWidth)),
                                  )
                                ],
                              )),
                        )
                      ],
                    ),
                  );
                },
              ));

  Future<dynamic> _updateTheAbout(
          {required Church commuinity,
          required BuildchurchCubit buildchurchCubit}) async =>
      showModalBottomSheet(
          context: context,
          builder: (context) {
            double textHeight = 35;
            return Container(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 8.0),
                  Center(
                      child: Text(
                    "Let others know what ${commuinity.name} is about!",
                    style: TextStyle(color: Colors.white),
                  )),
                  SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextField(
                        decoration: InputDecoration(
                            hintText: "Tell ${commuinity.name}'s story "),
                        onChanged: (value) => _txtController.text = value),
                  ),
                  SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                        width: (double.infinity * .70),
                        child: ElevatedButton(
                            style:
                                ElevatedButton.styleFrom(primary: Colors.white),
                            onPressed: () {
                              var state = buildchurchCubit.state;
                              if (_txtController.value.text.length != 0) {
                                buildchurchCubit
                                    .onAboutChanged(_txtController.text);
                                buildchurchCubit.lightUpdate(commuinity.id!,
                                    3); // ----------- The method that calls thr update
                                Navigator.of(context).pop();
                                this.setState(() {});
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
                                              "be sure you add a an about for the community you are updating"),
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
                            child: Text(
                              "Done, Upadate The About!",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ))),
                  )
                ],
              ),
            );
          });

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
    var ctxRead = context.read<CommuinityBloc>();
    ctxRead.onJoinCommuinity(commuinity: widget.commuinity, context: context);
  }

  _onLeaveCommuinity() {
    showLeaveCommuinity();
  }

  showLeaveCommuinity() => showModalBottomSheet(
      context: context,
      builder: (_context) => Container(
            //height: 200,
            color: Color(hc.hexcolorCode('#141829')),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  //height: 200,
                  // checking for role. a owner must not just leave

                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.red),
                      onPressed: () {
                        context
                            .read<CommuinityBloc>()
                            .onLeaveCommuinity(commuinity: widget.commuinity);
                        widget.commuinity.members.remove(
                            context.read<CommuinityBloc>().state.currUserr);
                        context.read<CommuinityBloc>()
                          ..add(CommuinityLoadCommuinity(
                              commuinity: widget.commuinity));
                        Navigator.of(_context).pop();
                      },
                      child: Text("... I said bye")),
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

collapseOrExpand(CommuinityBloc cmBloc, String type) {
  if (type == "cord") {
    return IconButton(
        onPressed: () => cmBloc.onCollapsedCord(),
        icon: !cmBloc.state.collapseCordColumn
            ? Icon(
                Icons.minimize,
                size: 35,
              )
            : Icon(
                Icons.expand_more_outlined,
                size: 35,
              ));
  } else {
    return IconButton(
        onPressed: () => cmBloc.onCollapsedVvrColumn(),
        icon: !cmBloc.state.collapseVvrColumn
            ? Icon(
                Icons.minimize,
                size: 35,
              )
            : Icon(
                Icons.expand_more_outlined,
                size: 35,
              ));
  }
}
