import 'package:flutter/material.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/screens/profile/bloc/profile_bloc.dart';
import 'package:kingsfam/screens/profile/widgets/show_follows.dart';

class ProfileStats extends StatelessWidget {
  final int posts;
  final int followers;
  final int following;
  final String username;
  final ProfileBloc profileBloc;
  final BuildContext ctxFromPf;
  const ProfileStats({
    Key? key,
    required this.profileBloc,
    required this.username,
    required this.posts,
    required this.followers,
    required this.following,
    required this.ctxFromPf,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container( //FlexFit.loose fits for the flexible children (using Flexible rather than Expanded)
    
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
              
                      followersInfoBtn(context),
                      SizedBox(width: 10),
                      followingInfoBtn(ctxFromPf)
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

