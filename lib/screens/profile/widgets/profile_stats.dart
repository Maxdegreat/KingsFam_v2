import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/screens/profile/bloc/profile_bloc.dart';
import 'package:kingsfam/screens/profile/widgets/profile_button.dart';
import 'package:kingsfam/screens/profile/widgets/show_follows.dart';

class ProfileStats extends StatelessWidget {
  final int followers;
  final int following;
  final ProfileBloc profileBloc;
  final BuildContext ctxFromPf;
  const ProfileStats({
    Key? key,
    required this.profileBloc,
    required this.followers,
    required this.following,
    required this.ctxFromPf,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isCurrUser = context.read<AuthBloc>().state.user!.uid == profileBloc.state.userr.id;
    return Container( //FlexFit.loose fits for the flexible children (using Flexible rather than Expanded)
    
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
              
                      followersInfoBtn(context),
                      SizedBox(width: 10),
                      followingInfoBtn(ctxFromPf),
                      Spacer(),
                      ProfileButton(isCurrentUserr: isCurrUser, isFollowing: profileBloc.state.isFollowing)

                ],
              ),
            ),
          ],
        ));
  }

  GestureDetector followingInfoBtn(context) => GestureDetector(onTap:(){
    Navigator.of(context).pushNamed(ShowFollowsScreen.routeName, arguments: ShowFollowsArgs(u: profileBloc.state.userr, path: Paths.following));
  }, child: Text("$following Following", style: Theme.of(context).textTheme.caption));

  GestureDetector followersInfoBtn(context) => GestureDetector(onTap:(){
   Navigator.of(context).pushNamed(ShowFollowsScreen.routeName, arguments: ShowFollowsArgs(u: profileBloc.state.userr, path: Paths.followers));
  },child: Text("$followers Followers", style: Theme.of(context).textTheme.caption));


}

