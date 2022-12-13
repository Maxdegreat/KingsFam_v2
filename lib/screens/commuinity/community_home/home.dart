import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/models/church_model.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/commuinity/bloc/commuinity_bloc.dart';
import 'package:kingsfam/screens/profile/widgets/prayer_chunck.dart';
import 'package:kingsfam/widgets/roundContainerWithImgUrl.dart';
import 'package:kingsfam/widgets/snackbar.dart';

import '../../../config/constants.dart';
import '../commuinity_screen.dart';

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
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).iconTheme.color,
              )),
              title: Text(widget.cm.name, style: Theme.of(context).textTheme.bodyText1),
            ),
            body: widget.cmB == null
                ? BlocProvider<CommuinityBloc>(
                    create: (context) => CommuinityBloc(
                      authBloc: context.read<AuthBloc>(),
                      callRepository: context.read<CallRepository>(),
                      churchRepository: context.read<ChurchRepository>(),
                      storageRepository: context.read<StorageRepository>(),
                      userrRepository: context.read<UserrRepository>(),
                    )..add(CommunityInitalEvent(
                        commuinity: widget.cm,
                      )),
                    child: BlocConsumer<CommuinityBloc, CommuinityState>(
                      listener: (context, state) {
                        if (state.status == CommuintyStatus.error) {
                          log("!!!!!!! error in commuinityBloc. found from home page");
                        }
                      },
                      builder: (context, state) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              ContainerWithURLImg(
                                  height: 210,
                                  width: double.infinity,
                                  imgUrl: widget.cm.imageUrl),
                              SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.all(11.0),
                                  child: Text("Members: ${widget.cm.size}", style: Theme.of(context).textTheme.caption,),
                                ),
                              ),
                              joinLeaveBtn(
                                  state: state,
                                  context: context,
                                  cm: widget.cm),
                              Container(
                                width: double.infinity,
                                color: Theme.of(context).colorScheme.secondary,
                                child: GestureDetector(
                                  onTap: () {
                                    PrayerChunk(context, widget.cm.about, null);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(11.0),
                                    child: Text(
                                      "About: ${widget.cm.about}", style: Theme.of(context).textTheme.caption,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                              // SizedBox(height: 20),
                              // Text("Shared Content"),
                              // SizedBox(
                              //   height: 5,
                              // ),
                              // SizedBox(
                              //   height: 100,
                              //   width: double.infinity,
                              //   child: ListView.builder(
                              //       scrollDirection: Axis.horizontal,
                              //       itemCount: 3,
                              //       itemBuilder: (context, builder) {
                              //         return Padding(
                              //           padding: const EdgeInsets.all(8.0),
                              //           child: Container(
                              //               height: 111,
                              //               width: 111,
                              //               decoration: BoxDecoration(
                              //                   borderRadius:
                              //                       BorderRadius.circular(7),
                              //                   image: DecorationImage(
                              //                       image:
                              //                           CachedNetworkImageProvider(
                              //                               widget.cm.imageUrl),
                              //                       fit: BoxFit.cover))),
                              //         );
                              //       }),
                              // )
                            ],
                          ),
                        );
                      },
                    ),
                  )
                : BlocProvider.value(
                    value: widget.cmB!,
                    child: BlocConsumer<CommuinityBloc, CommuinityState>(
                      listener: (context, state) {
                        if (state.status == CommuintyStatus.error) {
                          log("!!!!!!! error in commuinityBloc. found from home page");
                        }
                      },
                      builder: (context, state) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              ContainerWithURLImg(
                                  height: 210,
                                  width: double.infinity,
                                  imgUrl: widget.cm.imageUrl),
                              SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.all(11.0),
                                  child: Text("Members: ${widget.cm.size}", style: Theme.of(context).textTheme.caption,),
                                ),
                              ),
                              joinLeaveBtn(
                                  state: state,
                                  context: context,
                                  cm: widget.cm),
                              Container(
                                width: double.infinity,
                                color: Theme.of(context).colorScheme.secondary,
                                child: GestureDetector(
                                  onTap: () {
                                    PrayerChunk(context, widget.cm.about, null);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(11.0),
                                    child: Text(
                                      "About: ${widget.cm.about}", style: Theme.of(context).textTheme.caption,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                              // SizedBox(height: 20),
                              // Text("Shared Content"),
                              // SizedBox(
                              //   height: 5,
                              // ),
                              // SizedBox(
                              //   height: 100,
                              //   width: double.infinity,
                              //   child: ListView.builder(
                              //       scrollDirection: Axis.horizontal,
                              //       itemCount: 3,
                              //       itemBuilder: (context, builder) {
                              //         return Padding(
                              //           padding: const EdgeInsets.all(8.0),
                              //           child: Container(
                              //               height: 111,
                              //               width: 111,
                              //               decoration: BoxDecoration(
                              //                   borderRadius:
                              //                       BorderRadius.circular(7),
                              //                   image: DecorationImage(
                              //                       image:
                              //                           CachedNetworkImageProvider(
                              //                               widget.cm.imageUrl),
                              //                       fit: BoxFit.cover))),
                              //         );
                              //       }),
                              // )
                            ],
                          ),
                        );
                      },
                    ),
                  )));
  }

// this is the join btn ____________________________________
  Widget joinLeaveBtn(
      {required CommuinityState state,
      required BuildContext context,
      required Church cm}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        state.isMember == null
            ? SizedBox.shrink()
            : state.isMember != false
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Container(
                      height: 30,
                      width: 200,
                      child: ElevatedButton(
                          onPressed: () {
                            if (!context
                                .read<CommuinityBloc>()
                                .state
                                .role["permissions"]
                                .contains("*")) {

                              context
                                  .read<CommuinityBloc>()
                                  .onLeaveCommuinity(commuinity: cm);
                              cm.members.remove(context
                                  .read<CommuinityBloc>()
                                  .state
                                  .currUserr);
                              
                              context
                                  .read<CommuinityBloc>()..add(CommunityInitalEvent(commuinity: cm));
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
                    child: joinBtn(
                        b: context.read<CommuinityBloc>(),
                        cm: cm,
                        context: context),
                  ),
        SizedBox(width: 10),
        Text("${cm.size} members")
      ],
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