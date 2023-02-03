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
  final String currUsrId;
  final BuildContext ctxFromPf;
  final ProfileBloc bloc;
  final String type;
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
    log("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    bool isListEmpty = true;
    if (widget.type == Paths.following) {
      context.read<FollowCubit>().state.following.isNotEmpty ? isListEmpty = false : null;
    } else {
      context.read<FollowCubit>().state.followers.isNotEmpty ? isListEmpty = false : null;
      
    }
    return Scaffold(
        appBar: AppBar(
            title: Text(widget.bloc.state.userr.username + "\'s ${widget.type}", style: Theme.of(context).textTheme.bodyText1,)),
        body: SafeArea(
            child: BlocConsumer<FollowCubit, FollowState>(
          listener: (context, state) {
          
          },
          builder: (context, state) {
            return Container(
                height: MediaQuery.of(widget.ctxFromPf).size.height,
                child: 
                
                isListEmpty ? 

                Center(
                  child: Text("umm, nothing to see right now", style: Theme.of(context).textTheme.bodyLarge),
                )
                :
                ListView.builder(
                    controller: _scrollController,
                    itemCount: widget.type == Paths.following ? state.following.length : state.followers.length,
                    itemBuilder: (BuildContext _, int index) {
                      final Userr user = widget.type == Paths.following ? state.following[index] : state.followers[index];
                      

                      return Column(
                        children: [
                          ListTile(
                            leading: ProfileImage(
                                radius: 22, pfpUrl: user.profileImageUrl),
                            title: Text(user.username),
                            trailing:
                                Text('followers: ${user.followers}'),
                            onTap: () => Navigator.of(context).pushNamed(
                                ProfileScreen.routeName,
                                arguments:
                                    ProfileScreenArgs(userId: user.id, initScreen: true)),
                          ),
                          
                          Divider(),
                          
                        ],
                      );
                    }));
          },
        )));
  }
}
