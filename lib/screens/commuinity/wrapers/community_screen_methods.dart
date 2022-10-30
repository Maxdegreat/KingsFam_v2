
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
                          ..add(CommuinityLoadCommuinity(
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
 Widget new_kingscord({required CommuinityBloc cmBloc, required String? currRole, required BuildContext context, required Church cm}) {

    cmActions.Actions actions = cmActions.Actions();
    if ((currRole != null && currRole == Roles.Owner) ||
        (currRole != null &&
            actions.hasAccess(
                role: currRole,
                action: cmActions.Actions.communityActions[4]))) {
      return GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(CreateRoom.routeName,
              arguments: CreateRoomArgs(cmBloc: cmBloc, cm: cm)),
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
            
            showModalBottomSheet(
              isDismissible: true,
              isScrollControlled: true,
               backgroundColor: Colors.transparent,
                context: context,
                builder: (context) {
          
                  return Container(
                    height: MediaQuery.of(context).size.height / 1.75,
                    decoration: BoxDecoration(
                      color: Color(hc.hexcolorCode('#141829')),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Icon(Icons.drag_handle),
                          ),
                        ),
                        //child one is a tab bar
                        TabBar(
                          controller: tabcontrollerForCmScreen,
                          tabs: [
                            Tab(text: "Participants"),
                            Tab(text: "Edit"),
                          ],
                        ),
                        //child 2 is the child of tab
                        Expanded(
                          //height: MediaQuery.of(context).size.height / 2.3,
                          child:
                              TabBarView(controller: tabcontrollerForCmScreen, children: [
                            cmBloc.state.currUserr != null
                                ? _participantsView(
                                  cm: cm,
                                  currUserr: cmBloc.state.currUserr,
                                  memberInfo: cm.members,
                                  users: cm.members.keys.toList())
                                : Center(
                                  child: Text("Must be apart of this community to view the members"),
                                ),
                            _editView(
                                txtController: TextEditingController(),
                                cmBloc: cmBloc,
                                commuinity: cm,
                                buildchurchCubit: context.read<BuildchurchCubit>(),
                                communitiyBloc: context.read<CommuinityBloc>(),
                                currRole: currRole, context: context )
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



  // this is a widget for the participant view.
  // ignore: todo
  //TODO ADMIN WHERE 2==2
  Widget _participantsView({
    required List<Userr> users, 
    required Map<Userr, dynamic> memberInfo, 
    required Userr currUserr,
    required Church cm,
  }
      ) {
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
                      context: context,
                      cm: cm,
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

  // part of the participants view. this shows more options when deciding to ptomote a user or not
  Widget _moreOptinos({ 

      required BuildContext context,
      required Userr participant,
      required Map<Userr, dynamic> memberInfo,
      required Userr currUserr,
      required Church cm
      }) {
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
              context: context,
                cm: cm,
                participatant: participant,
                role: role);
          }
        } else
          return _nonAdminOptions(role: role, context: context);
      },
    );
  }

  // extension of the moreoptions
  // ignore: todo
  // TODO ADMIN
  Future<dynamic> _adminsOptions({
    required Church cm,
    required BuildContext context,
      required Userr participatant,
      required String role}) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          if (role == Roles.Admin || role == Roles.Owner) {
            return changRolePopUp(context, participatant, cm);
          } else {
            return Text(
              "${participatant.username} is alredy an Admin",
            );
          }
        });
  }

  // extension of the moreoptions
  Column changRolePopUp(
      BuildContext context, Userr participatant, Church cm) {
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
                  commuinityId: cm.id!,
                  role: Roles.Admin);
              Navigator.of(context).pop();
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
                  commuinityId: cm.id!,
                  role: Roles.Elder);
              Navigator.of(context).pop();
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
                  commuinityId: cm.id!,
                  role: Roles.Member);
              Navigator.of(context).pop();

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
                    commuinity: cm, leavingUserId: participatant.id);
                Navigator.of(context).pop();
              } catch (e) {
                log("err: " + e.toString());
              }

              Navigator.of(context).pop();
            },
            child: FittedBox(
                child: Text(
                    "Remove ${participatant.username} from ${cm.name}",
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyText1))),
        TextButton(
            onPressed: () {
              if (cm.members[participatant]['role'] == Roles.Owner) {
                snackBar(
                    snackMessage: "You can not ban the community owner",
                    context: context,
                    bgColor: Colors.red);
                return;
              }
              context.read<ChurchRepository>().banFromCommunity(
                  community: cm, baningUserId: participatant.id);
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

  // extension of the moreoptions
  Future<dynamic> _nonAdminOptions({required String role, required BuildContext context}) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
                content: Text(
              "your role is $role so you can not access these options",
              style: Theme.of(context).textTheme.bodyText1,
            )));
  }

  Widget _editView({
      required TextEditingController txtController,
      required BuildContext context,
      required CommuinityBloc cmBloc,
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
            title: Text("please view pending request", style: Theme.of(context).textTheme.bodyText1),
            onTap: () => Navigator.of(context).pushNamed(ReviewPendingRequest.routeName, arguments: ReviewPendingRequestArgs(cm: commuinity))
            
          ),
          ListTile(
              title: Text("Update the Community name".toLowerCase(),
                  style: Theme.of(context).textTheme.bodyText1),
              onTap: () async => _updateCommuinityName(context: context,
              txtController: txtController,
                  commuinity: commuinity,
                  buildchurchCubit: context.read<BuildchurchCubit>())),
          ListTile(
            title: Text("Update Community ImageUrl".toLowerCase(),
                overflow: TextOverflow.fade,
                style: Theme.of(context).textTheme.bodyText1),
            trailing: ProfileImage(radius: 25, pfpUrl: commuinity.imageUrl),
            onTap: () => _updateCommuinityImage(
                commuinity: commuinity, buildchurchCubit: buildchurchCubit, context: context),
          ),
          ListTile(
            title: Text("Update the Community privacy".toLowerCase(),
             style: Theme.of(context).textTheme.bodyText1),
             onTap: () => _updateCommunityPrivacy(context:context,
              buildC: buildchurchCubit, cm: commuinity,)
             ),
          ListTile(
            title: Text(
              "Update the community Theme Pack".toLowerCase(),
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
              "Update The About".toLowerCase(),
              style: Theme.of(context).textTheme.bodyText1,
              overflow: TextOverflow.fade,
            ),
            onTap: () async => _updateTheAbout(
              txtController: txtController,
              context: context,
                commuinity: commuinity,
                buildchurchCubit: context.read<BuildchurchCubit>()),
          ),
          ListTile(
              title: Text(
                "Manage & Update Roles".toLowerCase(),
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
              "Baned Users".toLowerCase(),
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

  // part of the settings allows update of the cm name
  Future<dynamic> _updateCommuinityName({
          required TextEditingController txtController,
          required BuildContext context,
          required Church commuinity,
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
                    onChanged: (value) => txtController.text = value),
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
                          if (txtController.value.text.length != 0) {
                            if (txtController.value.text.length <= 19) {
                              buildchurchCubit
                                  .onNameChanged(txtController.text);
                              buildchurchCubit.lightUpdate(commuinity.id!,
                                  1); // ----------- The method that calls thr update
                              Navigator.of(context).pop();
                              txtController.clear();
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

  Future <dynamic>  _updateCommunityPrivacy({
    required BuildchurchCubit buildC, required Church cm, required BuildContext context}) {
      return Navigator.of(context).pushNamed(UpdatePrivacyCm.routeName, arguments: UpdatePrivacyCmArgs(cm: cm));
    }
  Future<dynamic> _updateTheAbout(
          {required Church commuinity,
          required BuildContext context,
          required TextEditingController txtController,
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
                        onChanged: (value) => txtController.text = value),
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
                              if (txtController.value.text.length != 0) {
                                buildchurchCubit
                                    .onAboutChanged(txtController.text);
                                buildchurchCubit.lightUpdate(commuinity.id!,
                                    3); // ----------- The method that calls thr update
                                Navigator.of(context).pop();
                                
                                txtController.clear();
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