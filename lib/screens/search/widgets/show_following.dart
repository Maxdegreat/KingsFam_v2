import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/cubits/cubits.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/profile/bloc/profile_bloc.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/screens/search/cubit/follow_cubit.dart';

import '../../../models/user_model.dart';
import '../../../widgets/widgets.dart';

class ShowFollowingListArgs {
  final String usrId;
  final ProfileBloc bloc;
  final BuildContext ctxFromPf;
  final String type;
  ShowFollowingListArgs(
      {required this.usrId,
      required this.bloc,
      required this.ctxFromPf,
      required this.type});
}

class ShowFollowingList extends StatefulWidget {
  ShowFollowingList(
      {Key? key,
      required this.currUsrId,
      required this.ctxFromPf,
      required this.bloc,
      required this.type})
      : super(key: key);
  String currUsrId;
  BuildContext ctxFromPf;
  ProfileBloc bloc;
  String type;
  static const String routeName = "/showFollowingList";
  static Route route(ShowFollowingListArgs args) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (_) {
          return BlocProvider(
            create: (context) =>
                FollowCubit(userrRepository: context.read<UserrRepository>()),
            child: ShowFollowingList(
              currUsrId: args.usrId,
              ctxFromPf: args.ctxFromPf,
              bloc: args.bloc,
              type: args.type,
            ),
          );
        });
  }

  @override
  State<ShowFollowingList> createState() => _ShowFollowingListState();
}

class _ShowFollowingListState extends State<ShowFollowingList> {
  late ScrollController _scrollController;
  String? lastStringId;
  Set<String> seen = Set();
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels != 0.0 &&
            _scrollController.position.maxScrollExtent ==
                _scrollController.position.pixels) {
          if (widget.type == Paths.following) {
            if (!seen.contains(
                context.read<FollowCubit>().state.following.last.id)) {
              if (context.read<FollowCubit>().state.following.length > 0) {
                log("len g 0, checking");
                context.read<FollowCubit>().getFollowing(
                    userId: widget.currUsrId,
                    lastStringId:
                        context.read<FollowCubit>().state.following.last.id);
              }
            }
          } else {
            if (!seen.contains(context.read<FollowCubit>().state.followers.last.id)) {
        if (context.read<FollowCubit>().state.followers.length > 0) {
          context.read<FollowCubit>().getFollowing(userId: widget.currUsrId, lastStringId: context.read<FollowCubit>().state.followers.last.id);
        }
      }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == Paths.following) {
      context
        .read<FollowCubit>()
        .getFollowing(userId: widget.currUsrId, lastStringId: null);
    } else{
      context
        .read<FollowCubit>()
        .getFollowers(userId: widget.currUsrId, lastStringId: null);
    }
    return Scaffold(
        appBar: AppBar(
            title: Text(widget.bloc.state.userr.username + "\'s ${widget.type}")),
        body: SafeArea(
            child: BlocConsumer<FollowCubit, FollowState>(
          listener: (context, state) {
            // TODO: implement listener
          },
          builder: (context, state) {
            return Container(
                height: MediaQuery.of(widget.ctxFromPf).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: ListView.builder(
                          controller: _scrollController,
                          itemCount: widget.type == Paths.following ? state.following.length : state.followers.length,
                          itemBuilder: (BuildContext _, int index) {
                            final Userr user = widget.type == Paths.following ? state.following[index] : state.followers[index];
                            log("does seen contatin the last String id? ${seen.contains(lastStringId)}");

                            return Column(
                              children: [
                                ListTile(
                                  leading: ProfileImage(
                                      radius: 30, pfpUrl: user.profileImageUrl),
                                  title: Text(user.username),
                                  trailing:
                                      Text('followers: ${user.followers}'),
                                  onTap: () => Navigator.of(context).pushNamed(
                                      ProfileScreen.routeName,
                                      arguments:
                                          ProfileScreenArgs(userId: user.id)),
                                ),
                                SizedBox(height: 2),
                                Divider(),
                                SizedBox(height: 3),
                              ],
                            );
                          }),
                    ),
                  ],
                ));
          },
        )));
  }
}
