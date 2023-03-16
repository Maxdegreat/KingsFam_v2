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

  @override
  void initState() {
    initCmB();
    super.initState();
  }

  Future<void> initCmB() async {
    cmB = await _getCmB();
    cmB.getRooms(cmB.state.cmId);
    cmB.updateCmId(widget.cm.id!, widget.cm);
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
                IconButton(
                    onPressed: () async {
                      String generatedDeepLink =
                          await FirebaseDynamicLinkService.createDynamicLink(
                              widget.cm, true);
                      communityInvitePopUp(context, generatedDeepLink);
                    },
                    icon: Icon(
                      Icons.share,
                      color: Theme.of(context).iconTheme.color,
                    ))
              ],
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
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 9,
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: ContainerWithURLImg(
                                        height: size.width / 3,
                                        width: size.width / 3,
                                        imgUrl: widget.cm.imageUrl,
                                        pc: null),
                                  ),
                                  const SizedBox(height: 20),
                                  Align(
                                      alignment: Alignment.center,
                                      child: Text(widget.cm.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1!
                                              .copyWith(
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.bold))),
                                  const SizedBox(height: 10),
                                  _aboutInfo(),
                                  const SizedBox(height: 10),
                                  _memberInfo(),
                                  const SizedBox(height: 10),
                                  Text("Rooms", style: Theme.of(context).textTheme.bodyText1!.copyWith(fontWeight: FontWeight.bold)),

                                ]..addAll(_listOfRooms(cmB)),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: _joinLeaveBtn(state),
                              ),
                            ],
                          ),
                        )
                      ],
                    );
                  }),
                )),
          ));
  }

  _memberInfo() {
    return Container(
      padding: const EdgeInsets.only(right: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(7)),
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
      ),
    );
  }

  List<Widget> _listOfRooms(CommuinityBloc cmB) {
    log("cm id: ${cmB.state.cmId}"); 
    cmB.getRooms(cmB.state.cmId);
    List<Widget> bucket = [];
    cmB.state.otherRooms.forEach((element) {
      bucket.add(Padding(
        padding: const EdgeInsets.all(4.0),
        child: Text(element!.cordName,
            style: Theme.of(context).textTheme.bodyText1),
      ));
    });
    return bucket;
  }

  Widget _aboutInfo() {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Text(
          widget.cm.about,
          style: Theme.of(context).textTheme.subtitle1,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          maxLines: 100,
          textAlign: TextAlign.center,
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
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(10), shape: StadiumBorder()),
          onPressed: () {
            cmB.state.requestStatus == RequestStatus.pending
                ? snackBar(
                    snackMessage: "Your Request is pending", context: context)
                : cmB.requestToJoin(
                    cm, context.read<AuthBloc>().state.user!.uid);
          },
          child: cmB.state.requestStatus == RequestStatus.pending
              ? Text("Pending ...",
                  style: Theme.of(context).textTheme.bodyText1)
              : Text("Request To Join",
                  style: Theme.of(context).textTheme.bodyText1)),
    );
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
                        if (!(context
                                .read<CommuinityBloc>()
                                .state
                                .role["kfRole"] ==
                            "Lead")) {
                          context
                              .read<CommuinityBloc>()
                              .onLeaveCommuinity(commuinity: cm)
                              .then((value) {
                            context
                                .read<ChatscreenBloc>()
                                .removeCmFromJoinedCms(leftCmId: cm.id!);
                          });
                          cm.members.remove(
                              context.read<CommuinityBloc>().state.currUserr);

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
                          primary: Theme.of(context).colorScheme.secondary)),
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