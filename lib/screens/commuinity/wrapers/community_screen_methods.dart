
part of 'package:kingsfam/screens/commuinity/commuinity_screen.dart';

  // On Leave A Community
 onLeaveCommuinity({required CommuinityBloc b, required BuildContext context, required Church cm}) {
    showLeaveCommuinity(b: b, context: context, cm: cm);
  }
  showLeaveCommuinity({required CommuinityBloc b, required BuildContext context, required Church cm}) => showModalBottomSheet(
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
                        b.onLeaveCommuinity(commuinity: cm);
                        cm.members.remove(
                            b.state.currUserr);
                        b
                          ..add(CommunityInitalEvent(
                              commuinity: cm));
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

  // on Join A Community
   Widget joinBtn({required CommuinityBloc b, required Church cm, required BuildContext context}) {
    return Container(
      height: 30,
      width: 200,
      child: ElevatedButton(
        onPressed: () {
          _onJoinCommuinity(b:b, cm:cm, c:context);
        },
        child: Text(
          "Join",
          style: TextStyle(color: Colors.white),
        ),
        style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            backgroundColor:
                MaterialStateProperty.all<Color>(Colors.transparent),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: BorderSide(color: Colors.white)))),
      ),
    );
  }

  _onJoinCommuinity({required CommuinityBloc b, required Church cm, required BuildContext c}) {
    b.onJoinCommuinity(commuinity: cm, context: c);
  }

// content preview: This holds the post
 Widget contentPreview({required Post post, required BuildContext context, required Church cm}) {

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(
            CommuinityFeedScreen.routeName,
            arguments: CommuinityFeedScreenArgs(commuinity: cm)),
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
                    cm.name,
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

// collapsed or expand. this is a btn used to expand cms or collapse cms
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

// used to make a new kingscord or event
 Widget new_kingscord({required CommuinityBloc cmBloc, required BuildContext context, required Church cm}) {
    // REQUIRES ACTION: NEWKINGSCORD
    // # (ADMIN) IS ALLOWED
    // * (CREATOR) IS ALLOWED
    // cmActions.Actions actions = cmActions.Actions();

    if (cmBloc.state.role["permissions"].contains("*") || cmBloc.state.role["permissions"].contains("#") || cmBloc.state.role["permissions"].contains(CmActions.makeCord)) {
      return GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(CreateRoom.routeName,
              arguments: CreateRoomArgs(cmBloc: cmBloc, cm: cm)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Icon(Icons.add)
          ));
    } else
      return SizedBox.shrink();
  }

// this is a widget used to del a kingscord or an event
 _delKcDialog({required KingsCord cord, required Church commuinity, required BuildContext context, }) =>
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

// This is for the settings button
 settingsBtn({required CommuinityBloc cmBloc, required Church cm, required BuildContext context, required TabController tabcontrollerForCmScreen, String? currRole}) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, top: 10),
      child: IconButton(
          onPressed: () async {
            // final usersInCommuiinity = await context.read<BuildchurchCubit>().commuinityParcticipatents(ids: widget.commuinity.memberIds);
            Navigator.of(context).pushNamed(ParticipantsView.routeName, arguments: ParticipantsViewArgs(cmBloc: cmBloc, cm: cm));
 }, icon: Icon(Icons.people_alt_sharp),)
    );
  }
  

  // This is a method for inviting users to the Cm
  Widget inviteButton({required BuildContext context, required Church cm}) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, top: 10),
      child: IconButton(
          icon: Icon(Icons.person_add),
          onPressed: () async {
            final following =
                await context.read<BuildchurchCubit>().grabCurrFollowing();
            _inviteBottomSheet(following: following, cm: cm, context: context);
          }),
    );
  }




  Future<dynamic> _inviteBottomSheet({
    required Church cm,
    required List<Userr> following, required BuildContext context}) async =>
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
                        child: Text("Invite fam to ${cm.name}",
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
                                  icon: Icon(
                                    Icons.add,
                                  ),
                                  onPressed: () => _showInviteDialog(cm: cm, user: user, context: context),
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

  _showInviteDialog({ required Userr user, required BuildContext context, required Church cm}) {
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
                      toUserId: user.id, commuinity: cm);
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }