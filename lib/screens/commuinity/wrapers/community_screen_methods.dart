part of 'package:kingsfam/widgets/mainDrawer/main_drawer.dart';

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
          _onJoinCommuinity(b: b, cm: cm, c: context).then((value) {
            Navigator.of(context).pop();
            scaffoldKey.currentState!.closeDrawer();
            Future.delayed((Duration(milliseconds: 0)))
                .then((value) => scaffoldKey.currentState!.openDrawer());
          });
        },
        child: Text(
          "Join",
          style: TextStyle(color: Color.fromARGB(255, 49, 125, 51)),
        ),
        style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: StadiumBorder(),
            primary: Color.fromARGB(37, 50, 235, 62))),
  );
}

Future<bool> _onJoinCommuinity(
    {required CommuinityBloc b,
    required Church cm,
    required BuildContext c}) async {
  await b.onJoinCommuinity(commuinity: cm, context: c);
  return true;
}

// Widget nativeAdWidget(NativeAd ad, bool hasAdLoaded, BuildContext context) {
//   return hasAdLoaded
//       ? Container(
//           height: 50,
//           width: MediaQuery.of(context).size.width / 2.1,
//           child: Padding(
//             padding: const EdgeInsets.all(5.0),
//             child: AdWidget(ad: ad),
//           ),
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.secondary,
//             borderRadius: BorderRadius.circular(10),
//           ),
//         )
//       : SizedBox.shrink();
// }

// content preview: This holds the post
Widget contentPreview(
    {required Post post, required BuildContext context, required Church cm}) {
  String url = post.imageUrl != null ? post.imageUrl! : post.thumbnailUrl!;
  return GestureDetector(
    onTap: () => Navigator.of(context).pushNamed(CommuinityFeedScreen.routeName,
        arguments: CommuinityFeedScreenArgs(commuinity: cm, passedPost: null)),
    child: SizedBox(
      // width: MediaQuery.of(context).size.width / 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: Theme.of(context).colorScheme.secondary,
                  image: DecorationImage(
                      image: CachedNetworkImageProvider(url),
                      fit: BoxFit.cover)),
              height: 50,
              width: 50,
            ),
            SizedBox(height: 2),
            Flexible(
              child: Container(
                width: 55,
                child: Center(
                  child: Text(
                    post.author.username,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
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

  if (cmBloc.state.role["kfRole"] == "Lead" ||
      cmBloc.state.role["kfRole"] == "Admin" ||
      cmBloc.state.role["kfRole"] == "Mod") {
    return IconButton(
        onPressed: () {
          Navigator.of(context).pushNamed(CreateRoom.routeName,
              arguments: CreateRoomArgs(cmBloc: cmBloc, cm: cm));
        },
        icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary));
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

dynamic showCmOptions(
    {required CommuinityBloc cmBloc,
    required Church cm,
    required BuildContext context}) {
  return showModalBottomSheet(
      context: context,
      builder: (_) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                "View members, pending and baned",
                style: Theme.of(context).textTheme.bodyText1,
                overflow: TextOverflow.fade,
              ),
              trailing: cmBloc.state.cmHasRequest
                  ? CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      radius: 7)
                  : const SizedBox.shrink(),
              onTap: () => Navigator.of(context).pushNamed(
                  ParticipantsView.routeName,
                  arguments: ParticipantsViewArgs(cmBloc: cmBloc, cm: cm)),
            ),
            ListTile(
              title: Text(
                "View home and invite link",
                style: Theme.of(context).textTheme.bodyText1,
                overflow: TextOverflow.fade,
              ),
              trailing: Icon(Icons.home),
              onTap: () => Navigator.of(context).pushNamed(
                  CommunityHome.routeName,
                  arguments: CommunityHomeArgs(cm: cm, cmB: null)),
            ),
            if (cmBloc.state.role["kfRole"] == "Lead" ||
                cmBloc.state.role["kfRole"] == "Admin") ...[
              ListTile(
                  title: Text("Update community name",
                      style: Theme.of(context).textTheme.bodyText1),
                  trailing: Icon(Icons.notes),
                  onTap: () async => _updateCommuinityName(
                      commuinity: cm,
                      context: context,
                      buildchurchCubit: context.read<BuildchurchCubit>())),
              ListTile(
                title: Text(
                  "Update the about",
                  style: Theme.of(context).textTheme.bodyText1,
                  overflow: TextOverflow.fade,
                ),
                trailing: Icon(Icons.note_alt_sharp),
                onTap: () async => _updateTheAbout(
                    commuinity: cm,
                    buildchurchCubit: context.read<BuildchurchCubit>(),
                    context: context),
              ),
              ListTile(
                title: Text("Update community image",
                    overflow: TextOverflow.fade,
                    style: Theme.of(context).textTheme.bodyText1),
                trailing: ProfileImage(radius: 15, pfpUrl: cm.imageUrl),
                onTap: () => _updateCommuinityImage(
                    context: context,
                    commuinity: cm,
                    buildchurchCubit: context.read<BuildchurchCubit>()),
              ),
              ListTile(
                title: Text("Update community privacy"),
                trailing: Icon(Icons.lock),
                onTap: () => Navigator.of(context).pushNamed(
                    UpdatePrivacyCm.routeName,
                    arguments: UpdatePrivacyCmArgs(cm: cm)),
              )
            ],
          ],
        );
      });
}

// This is a method for inviting users to the Cm
Widget inviteButton({required BuildContext context, required Church cm}) {
  return Padding(
    padding: const EdgeInsets.only(left: 10.0, top: 10),
    child: Container(
      decoration: BoxDecoration(
          color: Colors.black12, borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () async {
              final following =
                  await context.read<BuildchurchCubit>().grabCurrFollowing();
              _inviteBottomSheet(
                  following: following, cm: cm, context: context);
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
                        fillColor: Theme.of(context).colorScheme.secondary,
                        filled: true,
                        focusColor: Theme.of(context).colorScheme.secondary,
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
                      decoration: InputDecoration(
                          fillColor: Theme.of(context).colorScheme.secondary,
                          filled: true,
                          focusColor: Theme.of(context).colorScheme.secondary,
                          hintText: "Enter a name"),
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

communityInvitePopUp(BuildContext context, String deepLink) {
  return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.drag_handle),
              SizedBox(height: 5),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.amber, width: 2),
                  borderRadius: BorderRadius.circular(7),
                  color: Theme.of(context).colorScheme.background,
                ),
                child: Center(
                  child: Text(deepLink,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText1),
                ),
              ),
              SizedBox(height: 5),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: Colors.amber,
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.amber),
                  child: Text("Copy share link",
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    copyTextToClip(deepLink);
                    snackBar(
                        snackMessage: "Share link coppied",
                        context: context,
                        bgColor: Colors.green);
                  },
                ),
              ),
              SizedBox(height: 5),
              Text(
                  "Copy this share link and send it to a friend. They can then join this community. If they do not have the app they will be directed to the app store.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.caption),
            ],
          ),
        );
      });
}
