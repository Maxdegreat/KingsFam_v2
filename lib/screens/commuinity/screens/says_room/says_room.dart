import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/config/global_keys.dart';
import 'package:kingsfam/cubits/liked_says/liked_says_cubit.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/models/says_model.dart';
import 'package:kingsfam/screens/chats/bloc/chatscreen_bloc.dart';
import 'package:kingsfam/screens/commuinity/screens/says_room/says_view.dart';
import 'package:kingsfam/screens/commuinity/screens/says_room/screens/create_says.dart';
import 'package:kingsfam/widgets/roundContainerWithImgUrl.dart';
import 'package:kingsfam/widgets/says_container.dart';

import 'bloc/says_bloc.dart';

class SaysRoom extends StatefulWidget {
  final Church cm;
  final String kcName;
  final String kcId;
  final Userr currUsr;
  const SaysRoom(
      {Key? key,
      required this.cm,
      required this.kcName,
      required this.kcId,
      required this.currUsr})
      : super(key: key);

  @override
  State<SaysRoom> createState() => _SaysRoomState();
}

class _SaysRoomState extends State<SaysRoom> {
  @override
  void initState() {
    context
        .read<SaysBloc>()
        .add(SaysFetchSays(cmId: widget.cm.id!, kcId: widget.kcId));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              // backgroundColor: Color(hc.hexcolorCode("#141829")),
              title: Text(widget.kcName,
                  style: Theme.of(context).textTheme.bodyText1),
              leading: Padding(
                padding: const EdgeInsets.all(4.0),
                child: GestureDetector(
                    onTap: () {
                      scaffoldKey.currentState!.openDrawer();
                    },
                    child: ContainerWithURLImg(
                      imgUrl: context
                          .read<ChatscreenBloc>()
                          .state
                          .selectedCh!
                          .imageUrl,
                      height: 15,
                      width: 15,
                    )),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Church _cmLim = Church.empty;
                      Navigator.of(context)
                          .pushNamed(CreateSays.routeName,
                              arguments: CreateSaysArgs(
                                  currUsr: widget.currUsr,
                                  chLim: _cmLim.copyWith(
                                      id: widget.cm.id!, name: widget.cm.name),
                                  kcId: widget.kcId))
                          .then((_) {
                        context.read<SaysBloc>().add(SaysFetchSays(
                            cmId: widget.cm.id!, kcId: widget.kcId));
                      });
                    },
                    child: Text("Create Forum",
                        style: Theme.of(context).textTheme.bodyText1))
              ],
            ),
            body: BlocConsumer<SaysBloc, SaysState>(
              listener: (context, state) {
                // TODO: implement listener
              },
              builder: (context, state) {
                return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 1),
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: state.says.isNotEmpty
                          ? ListView.builder(
                              // itemCount: state.status == SaysStatus.loading
                              // ? state.says.length + 1 : state.says.length,
                              itemCount: state.says.length,
                              itemBuilder: (context, index) {
                                Says says = state.says[index]!;
                                return Column(
                                  children: [
                                    // SizedBox(height: 4),
                                    GestureDetector(
                                        onLongPress: () {
                                          if (context
                                                  .read<AuthBloc>()
                                                  .state
                                                  .user!
                                                  .uid ==
                                              says.author!.id) {
                                            showModalBottomSheet(
                                                context: context,
                                                builder: (context) {
                                                  return Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      ListTile(
                                                        leading:
                                                            Icon(Icons.delete),
                                                        title: Text(
                                                          "Delete",
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyText1,
                                                        ),
                                                        onTap: () => context
                                                            .read<SaysBloc>()
                                                            .deleteSays(
                                                                s: says,
                                                                cmId: widget
                                                                    .cm.id!),
                                                      )
                                                    ],
                                                  );
                                                });
                                          }
                                        },
                                        onTap: () {
                                          Navigator.of(context).pushNamed(
                                              SaysView.routeName,
                                              arguments: SaysViewArgs(
                                                  s: says,
                                                  cmId: widget.cm.id!,
                                                  kcId: widget.kcId));
                                        },
                                        child: SaysContainer(
                                            cmId: widget.cm.id!,
                                            says: says,
                                            context: context,
                                            localLikesSays: context
                                                .read<LikedSaysCubit>()
                                                .state
                                                .localLikedSaysIds)),
                                    // SizedBox(height: 4),
                                  ],
                                );
                              })
                          : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                                child: Text(
                                  "well... there are currently no public forms to view.",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.caption,
                                ),
                              ),
                          ),
                    ));
              },
            )));
  }
}
