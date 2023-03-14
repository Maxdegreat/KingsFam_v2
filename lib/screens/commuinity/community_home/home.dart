import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/helpers/dynamic_links.dart';
import 'package:kingsfam/models/church_model.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/chats/bloc/chatscreen_bloc.dart';
import 'package:kingsfam/screens/commuinity/bloc/commuinity_bloc.dart';
import 'package:kingsfam/widgets/mainDrawer/main_drawer.dart';
import 'package:kingsfam/widgets/roundContainerWithImgUrl.dart';
import 'package:kingsfam/widgets/snackbar.dart';

import '../../../config/constants.dart';

class CommunityHomeArgs {
  final Church cm;
  final CommuinityBloc? cmB;
  CommunityHomeArgs({required this.cm, required this.cmB});
}

class CommunityHome extends StatefulWidget {
  final Church cm;
  final CommuinityBloc? cmB;
  const CommunityHome({Key? key, required this.cm, required this.cmB})
      : super(key: key);
  static const String routeName = "communityHome_";
  static Route route({required CommunityHomeArgs args}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) {
        return CommunityHome(cm: args.cm, cmB: args.cmB);
      },
    );
  }

  @override
  State<CommunityHome> createState() => _CommunityHomemState();
}

class _CommunityHomemState extends State<CommunityHome> {
  late CommuinityBloc cmB;
  bool _initalized = false;
  bool _showFullAbout = false;

  @override
  void initState() {
    initCmB();
    super.initState();
  }

  Future<void> initCmB() async {
    cmB = await _getCmB();
    _initalized = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return !_initalized
        ? Center(child: CircularProgressIndicator())
        : SafeArea(
            child: Scaffold(
                appBar: AppBar(
                  actions: [
                    IconButton(onPressed: () async {
                String generatedDeepLink =
                    await FirebaseDynamicLinkService.createDynamicLink(
                        widget.cm, true);
                communityInvitePopUp(context, generatedDeepLink);
              }, icon: Icon(Icons.share))
                  ],
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  leading: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Theme.of(context).iconTheme.color,
                      )),
                ),
                body: BlocProvider.value(
                    value: cmB,
                    child: BlocConsumer<CommuinityBloc, CommuinityState>(
                      listener: (context, state) {
                        if (state.status == CommuintyStatus.error) {
                          log("!!!!!!! error in commuinityBloc. found from home page");
                        }
                      },
                      builder: ((context, state) {
                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Align(alignment: Alignment.topLeft, child: Text(widget.cm.name + " Home", style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 30))),
                                ),
                               Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                       ContainerWithURLImg(
                                      height: size.width / 3,
                                      width: size.width / 3,
                                      imgUrl: widget.cm.imageUrl, pc: null),
                                  SizedBox(height: 10),
                                  Text(widget.cm.name, style: Theme.of(context).textTheme.bodyText1,),
                                    ],
                                  ),
                                ),
                               ),
                                SizedBox(height: 10),
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                       color: Theme.of(context).colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: _aboutInfo(4),
                                    )),
                                  SizedBox(height: 10),
                                if (!_showFullAbout) ...[
                                  _memberInfo(),
                                SizedBox(height: 10),
                                _joinLeaveBtn(state),
                                ]
                              ],
                            ),
                          ),
                        );
                      }),
                    ))));
  }

  Future<dynamic> _showFullAboutSheet() {
    return showModalBottomSheet(
        backgroundColor: Colors.black45,
        context: (context),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                      child: Icon(Icons.drag_handle_outlined,
                          color: Colors.white24)),
                  SizedBox(height: 10),
                  _aboutInfo(null),
                ]),
          );
        });
  }

  _memberInfo() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(10)
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.people_alt_sharp,
                color: Theme.of(context).iconTheme.color,
              ),
              SizedBox(width: 5),
              Text(widget.cm.size.toString(),
                  style: Theme.of(context).textTheme.caption),
              SizedBox(width: 5),
              Text("Members", style: Theme.of(context).textTheme.caption),
            ]),
      ),
    );
  }

  Widget _aboutInfo(int? maxLines) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          _showFullAbout = true;
          setState(() {});
          _showFullAboutSheet()
              .then((value) => {_showFullAbout = false, setState(() {})});
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text(
            "About: " + widget.cm.about,
            style: maxLines != null
                ? Theme.of(context).textTheme.caption
                : Theme.of(context)
                    .textTheme
                    .caption!
                    .copyWith(color: Colors.white),
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            maxLines: maxLines != null ? maxLines : 100,textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Future<CommuinityBloc> _getCmB() async {
    if (widget.cmB == null) {
      return await CommuinityBloc(
        authBloc: context.read<AuthBloc>(),
        churchRepository: context.read<ChurchRepository>(),
        storageRepository: context.read<StorageRepository>(),
        userrRepository: context.read<UserrRepository>(),
      )
        ..add(CommunityInitalEvent(
          commuinity: widget.cm,
        ));
    } else {
      return await widget.cmB!;
    }
  }

  _joinLeaveBtn(CommuinityState state) {
    return cmB.state.isBaned
        ? showBaned()
        : cmB.state.status == CommuintyStatus.armormed
            ? showArmored(cmB: cmB, cm: widget.cm)
            : joinLeaveBtn(state: state, context: context, cm: widget.cm);
  }

  Widget showBaned() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
              "You are baned from this community, you can not join at the moment.",
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: Colors.red)),
        ),
        decoration: BoxDecoration(
            color: Color.fromARGB(76, 244, 67, 54),
            borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget showArmored({required CommuinityBloc cmB, required Church cm}) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    "This is an armored community. Place a request to join. You will be notified when admited",
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(color: Colors.blue)),
              ),
              decoration: BoxDecoration(
                  color: Color.fromARGB(75, 54, 114, 244),
                  borderRadius: BorderRadius.circular(15)),
            ),
            // ------------------
            SizedBox(height: 7),
            Icon(Icons.health_and_safety_outlined, size: 50),
            SizedBox(height: 7),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).colorScheme.secondary),
                onPressed: () {
                  cmB.state.requestStatus == RequestStatus.pending
                      ? snackBar(
                          snackMessage: "Your Request is pending",
                          context: context)
                      : cmB.requestToJoin(
                          cm, context.read<AuthBloc>().state.user!.uid);
                },
                child: cmB.state.requestStatus == RequestStatus.pending
                    ? Text("Pending ...")
                    : Text("Request To Join")),
          ],
        ));
  }

// this is the join btn ____________________________________
  Widget joinLeaveBtn(
      {required CommuinityState state,
      required BuildContext context,
      required Church cm}) {
    return state.isMember == null
        ? SizedBox.shrink()
        : state.isMember != null && state.isMember!
            ? Padding(
                padding: const EdgeInsets.all(8.00),
                child: Container(
                  child: ElevatedButton(
                      onPressed: () {
                        if (!context
                            .read<CommuinityBloc>()
                            .state
                            .role["kfRole"] == "Lead") {
                          context
                              .read<CommuinityBloc>()
                              .onLeaveCommuinity(commuinity: cm)
                              .then((value) {
                            context
                                .read<ChatscreenBloc>()
                                .removeCmFromJoinedCms(leftCmId: cm.id!);
                          });
                          cm.members.remove(context
                              .read<CommuinityBloc>()
                              .state
                              .currUserr);

                          cmB..add(CommunityInitalEvent(commuinity: cm));
                          setState(() {});
                          Navigator.of(context).pop();
                        } else {
                          snackBar(
                              snackMessage: "Owners can not abandon ship",
                              context: context,
                              bgColor: Colors.red);
                        }
                      },
                      child: Text(
                        "Leave",
                        style: TextStyle(color: Colors.red),
                      ),
                      style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          primary:
                              Theme.of(context).colorScheme.secondary)),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: joinBtn(b: cmB, cm: cm, context: context),
              );
  }

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

                            // b..add(CommunityInitalEvent(commuinity: cm));
                            Navigator.of(_context).pop();
                          },
                          child: Text("... I said bye")),
                    ),
                    Container(
                      child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style:
                              ElevatedButton.styleFrom(primary: Colors.green),
                          child: Text("Chill, I wana stay fam")),
                    )
                  ],
                ),
              ));
}

  
                      //ContentContaner(context)