import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/helpers/navigator_helper.dart';
import 'package:kingsfam/models/user_model.dart';
import 'package:kingsfam/screens/profile/bloc/profile_bloc.dart';
import 'package:kingsfam/screens/profile/profile_screen.dart';
import 'package:kingsfam/widgets/profile_image.dart';

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
    NavHelper().navToShowFollowing(context, profileBloc.state.userr.id, profileBloc, ctxFromPf, Paths.following);
  }, child: Text("$following Following", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)));

  GestureDetector followersInfoBtn(context) => GestureDetector(onTap:(){
    NavHelper().navToShowFollowing(context, profileBloc.state.userr.id, profileBloc, ctxFromPf, Paths.followers);
  },child: Text("$followers Followers", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)));


}

class _stats extends StatelessWidget {
  final int count;
  final String label;
  const _stats({
    Key? key,
    required this.count,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count.toString(),
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.white)),
        Text(label, style: TextStyle(color: Colors.white))
      ],
    );
  }
}
