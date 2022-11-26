part of 'package:kingsfam/screens/commuinity/commuinity_screen.dart';


// On Leave A Community
onLeaveCommuinity(
    {required CommuinityBloc b,
    required BuildContext context,
    required Church cm}) {
  showLeaveCommuinity(b: b, context: context, cm: cm);
}

showLeaveCommuinity(
        {required CommuinityBloc b,
        required BuildContext context,
        required Church cm}) =>
    showModalBottomSheet(
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
                          cm.members.remove(b.state.currUserr);
                          b..add(CommunityInitalEvent(commuinity: cm));
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
Widget joinBtn(
    {required CommuinityBloc b,
    required Church cm,
    required BuildContext context}) {
  return Container(
    height: 30,
    width: 200,
    child: ElevatedButton(
        onPressed: () {
          _onJoinCommuinity(b: b, cm: cm, c: context);
        },
        child: Text(
          "Join",
          style: TextStyle(color: Colors.green),
        ),
        style: ElevatedButton.styleFrom(
            shape: StadiumBorder(),
            primary: Color(hc.hexcolorCode("#141829")))),
  );
}

_onJoinCommuinity(
    {required CommuinityBloc b, required Church cm, required BuildContext c}) {
  b.onJoinCommuinity(commuinity: cm, context: c);
}

// content preview: This holds the post
Widget contentPreview({required Post post, required BuildContext context, required Church cm}) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
    child: GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
          CommuinityFeedScreen.routeName,
          arguments: CommuinityFeedScreenArgs(commuinity: cm)).then((_) => context.read<BottomnavbarCubit>().showBottomNav(true)),
      child: Container(
      
        height: 80,
        width: 200,
        decoration: BoxDecoration(
          color: Color(hc.hexcolorCode("#141829")),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: .5, color: Colors.blue[900]!),
          gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Color(hc.hexcolorCode("#20263c")),
                Color(hc.hexcolorCode("#141829"))
              ]),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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
                    'shared',
                    style: TextStyle(fontWeight: FontWeight.w500),
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
Widget new_kingscord(
    {required CommuinityBloc cmBloc,
    required BuildContext context,
    required Church cm}) {
  // REQUIRES ACTION: NEWKINGSCORD
  // # (ADMIN) IS ALLOWED
  // * (CREATOR) IS ALLOWED
  // cmActions.Actions actions = cmActions.Actions();

  if (cmBloc.state.role["permissions"].contains("*") ||
      cmBloc.state.role["permissions"].contains("#") ||
      cmBloc.state.role["permissions"].contains(CmActions.makeRoom)) {
    return GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(CreateRoom.routeName,
            arguments: CreateRoomArgs(cmBloc: cmBloc, cm: cm)),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Icon(Icons.add)));
  } else
    return SizedBox.shrink();
}

// this is a widget used to del a kingscord or an event
_delKcDialog({
  required KingsCord cord,
  required Church commuinity,
  required BuildContext context,
}) =>
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
memberBtn(
    {required CommuinityBloc cmBloc,
    required Church cm,
    required BuildContext context,
    required,
    String? currRole}) {
  return Padding(
      padding: const EdgeInsets.only(left: 10.0, top: 10),
      child: Container(

        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(10)
        ),

        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: IconButton(
            onPressed: () async {
              // final usersInCommuiinity = await context.read<BuildchurchCubit>().commuinityParcticipatents(ids: widget.commuinity.memberIds);
              Navigator.of(context).pushNamed(ParticipantsView.routeName,
                  arguments: ParticipantsViewArgs(cmBloc: cmBloc, cm: cm));
            },
            icon: Icon(Icons.people_alt_sharp),
          ),
        ),
      ));
}

Widget settingsBtn(
    {required CommuinityBloc cmBloc,
    required Church cm,
    required BuildContext context}) {
  return Container(

        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(10)
        ),
    child: Padding(
      padding: const EdgeInsets.all(4.0),
      child: IconButton(
          onPressed: () {

            if ( context
                                    .read<CommuinityBloc>()
                                    .state
                                    .role["permissions"]
                                    .contains("*") ||
                                context
                                    .read<CommuinityBloc>()
                                    .state
                                    .role["permissions"]
                                    .contains("#")
                            ) {
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        //  update the cm name
                        ListTile(
                            title: Text("Update the Community name",
                                style: Theme.of(context).textTheme.bodyText1),
                            onTap: () async => _updateCommuinityName(
                                commuinity: cm,
                                context: context,
                                buildchurchCubit:
                                    context.read<BuildchurchCubit>())),
                        ListTile(
                          title: Text(
                            "Update The About",
                            style: Theme.of(context).textTheme.bodyText1,
                            overflow: TextOverflow.fade,
                          ),
                          onTap: () async => _updateTheAbout(
                              commuinity: cm,
                              buildchurchCubit: context.read<BuildchurchCubit>(),
                              context: context),
                        ),
                        ListTile(
                          title: Text("Update Community ImageUrl",
                              overflow: TextOverflow.fade,
                              style: Theme.of(context).textTheme.bodyText1),
                          trailing: ProfileImage(radius: 25, pfpUrl: cm.imageUrl),
                          onTap: () => _updateCommuinityImage(
                              context: context,
                              commuinity: cm,
                              buildchurchCubit: context.read<BuildchurchCubit>()),
                        ),
                        ListTile(
                          title: Text("Update Cm Privacy"),
                          onTap: () => Navigator.of(context).pushNamed(
                              UpdatePrivacyCm.routeName,
                              arguments: UpdatePrivacyCmArgs(cm: cm)),
                        )
                      ],
                    ),
                  );
                });

                            } else {
                              snackBar(snackMessage: "You must be admin to access the settings", context: context);
                            }

          },
          icon: Icon(Icons.settings)),
    ),
  );
}

// This is a method for inviting users to the Cm
Widget inviteButton({required BuildContext context, required Church cm}) {
  return Padding(
    padding: const EdgeInsets.only(left: 10.0, top: 10),
    child: Container(

        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(10)
        ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () async {
              final following =
                  await context.read<BuildchurchCubit>().grabCurrFollowing();
              _inviteBottomSheet(following: following, cm: cm, context: context);
            }),
      ),
    ),
  );
}

Future<dynamic> _inviteBottomSheet(
        {required Church cm,
        required List<Userr> following,
        required BuildContext context}) async =>
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
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: ListTile(
                              leading: ProfileImage(
                                  pfpUrl: user.profileImageUrl, radius: 25),
                              title: Text(user.username),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.add,
                                ),
                                onPressed: () => _showInviteDialog(
                                    cm: cm, user: user, context: context),
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

_showInviteDialog(
    {required Userr user, required BuildContext context, required Church cm}) {
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
                await context
                    .read<BuildchurchCubit>()
                    .inviteToCommuinity(toUserId: user.id, commuinity: cm);
                Navigator.pop(context);
              },
            )
          ],
        );
      });
}

// _-/\______|-=[}}]}]}]>>>>>>>|\<>\>\\|\<>.<<><<<<<<<<<<<<<
// Below here is the settings methods to the cm:

Future<dynamic> _updateCommuinityImage(
        {required Church commuinity,
        required BuildContext context,
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
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                      overflow: TextOverflow.fade),
                                ),
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height / 3.5,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      image: buildchurchCubit.state.imageFile ==
                                              null
                                          ? DecorationImage(
                                              image: CachedNetworkImageProvider(
                                                  commuinity.imageUrl),
                                              fit: BoxFit.fitWidth)
                                          : DecorationImage(
                                              image: FileImage(buildchurchCubit
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
    required BuildchurchCubit buildchurchCubit,
    required BuildContext context}) async {
  TextEditingController _txtController = TextEditingController();
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
                        style: ElevatedButton.styleFrom(primary: Colors.white),
                        onPressed: () {
                          var state = buildchurchCubit.state;
                          if (_txtController.value.text.length != 0) {
                            buildchurchCubit
                                .onAboutChanged(_txtController.text);
                            buildchurchCubit.lightUpdate(commuinity.id!,
                                3); // ----------- The method that calls thr update
                            _txtController.dispose();
                            Navigator.of(context).pop();
                          } else {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
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
}

// can and will seperate this code later
Future<dynamic> _updateCommuinityName({
  required Church commuinity,
  required BuildchurchCubit buildchurchCubit,
  required BuildContext context,
}) async {
  TextEditingController _txtController = TextEditingController();
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
                          style:
                              ElevatedButton.styleFrom(primary: Colors.white),
                          onPressed: () {
                            var state = buildchurchCubit.state;
                            if (_txtController.value.text.length != 0) {
                              if (_txtController.value.text.length <= 19) {
                                buildchurchCubit
                                    .onNameChanged(_txtController.text);
                                buildchurchCubit.lightUpdate(commuinity.id!,
                                    1); // ----------- The method that calls thr update
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
                                  builder: (BuildContext context) =>
                                      AlertDialog(
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
          ));
}