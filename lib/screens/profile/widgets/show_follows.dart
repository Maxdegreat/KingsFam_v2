import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/userr/userr_repository.dart';
import 'package:kingsfam/screens/profile/profile_screen.dart';
import 'package:kingsfam/screens/search/cubit/follow_cubit.dart';
import 'package:kingsfam/widgets/widgets.dart';

class ShowFollowsArgs {
  final Userr u;
  final String path;
  const ShowFollowsArgs({
    required this.u,
    required this.path,
  });
}

class ShowFollowsScreen extends StatefulWidget {
  final Userr u;
  final String path;
  const ShowFollowsScreen({super.key, required this.u, required this.path});

  static const String routeName = "showFollowScreen";
  static Route route({required ShowFollowsArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: ((context) => BlocProvider<FollowCubit>(
              create: (context) => FollowCubit(
                userrRepository: context.read<UserrRepository>()
              ),
              child: ShowFollowsScreen(
                u: args.u,
                path: args.path,
              ),
            )));
  }

  @override
  State<ShowFollowsScreen> createState() => _ShowFollowsScreenState();
}

class _ShowFollowsScreenState extends State<ShowFollowsScreen> {
  List<Userr> lst = [];
  @override
  void initState() {
    log("IN thr init now");
    if (widget.path == Paths.followers)
      context
          .read<FollowCubit>()
          .getFollowers(userId: widget.u.id, lastStringId: null);
    else
      context
          .read<FollowCubit>()
          .getFollowing(userId: widget.u.id, lastStringId: null);
    super.initState();
  }

  

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.u.username + "\'s " + widget.path,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
        body: BlocConsumer<FollowCubit, FollowState>(
          listener: (context, state) {
            //
          },
          builder: (context, state) {
            return Container(
              child: ListView.builder(
                itemCount: widget.path == Paths.followers
                    ? state.followers.length
                    : state.following.length,
                itemBuilder: (BuildContext context, int index) {
                  Userr u = Paths.followers == widget.path ? state.followers[index] : state.following[index];
                  return ListTile(
                    leading: ProfileImage(pfpUrl: u.profileImageUrl, radius: 22,),
                    title: Text(u.username),
                    onTap: (() => Navigator.of(context).pushNamed(ProfileScreen.routeName, arguments: ProfileScreenArgs(userId: u.id, initScreen: false))),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
