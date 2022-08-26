import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/cubits/cubits.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/profile/bloc/profile_bloc.dart';
import 'package:kingsfam/screens/screens.dart';

import '../../../models/user_model.dart';
import '../../../widgets/widgets.dart';

class ShowFollowingListArgs {
  final String usrId;
  final ProfileBloc bloc;
  final BuildContext ctxFromPf;
  ShowFollowingListArgs(
      {required this.usrId, required this.bloc, required this.ctxFromPf});
}

class ShowFollowingList extends StatefulWidget {
  ShowFollowingList(
      {Key? key, required this.currUsrId, required this.ctxFromPf})
      : super(key: key);
  String currUsrId;
  BuildContext ctxFromPf;
  static const String routeName = "/showFollowingList";
  static Route route(ShowFollowingListArgs args) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (_) {
          return BlocProvider<ProfileBloc>(
            create: (context) {
              return ProfileBloc(
                  userrRepository: context.read<UserrRepository>(),
                  authBloc: context.read<AuthBloc>(),
                  postRepository: context.read<PostsRepository>(),
                  likedPostCubit: context.read<LikedPostCubit>(),
                  churchRepository: context.read<ChurchRepository>(),
                  chatRepository: context.read<ChatRepository>());
            },
            child: ShowFollowingList(
                currUsrId: args.usrId, ctxFromPf: args.ctxFromPf),
          );
        });
  }

  @override
  State<ShowFollowingList> createState() => _ShowFollowingListState();
}

class _ShowFollowingListState extends State<ShowFollowingList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: BlocConsumer< ProfileBloc,  ProfileState>(
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
              Text("FOLLOWERS"),
              Expanded(
                flex: 1,
                child: ListView.builder(
                    itemCount: context
                        .read<ProfileBloc>()
                        .state
                        .followersUserList
                        .length,
                    itemBuilder: (BuildContext _, int index) {
                      final Userr user = context
                          .read<ProfileBloc>()
                          .state
                          .followersUserList[index];
                      return ListTile(
                        leading: ProfileImage(
                            radius: 30, pfpUrl: user.profileImageUrl),
                        title: Text(user.username),
                        trailing: Text('followers: ${user.followers}'),
                        onTap: () => Navigator.of(context).pushNamed(
                            ProfileScreen.routeName,
                            arguments: ProfileScreenArgs(userId: user.id)),
                      );
                    }),
              ),
            ],
          ),
        );
      },
    )));
  }
}
