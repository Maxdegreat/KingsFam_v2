
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kingsfam/screens/edit_profile/edit_profile_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/screens/profile/bloc/profile_bloc.dart';


class ProfileButton extends StatelessWidget {
  final bool isCurrentUserr;
  final bool isFollowing;
  final String? profileOwnersId;
  const ProfileButton({
    Key? key,
    required this.isCurrentUserr,
    required this.isFollowing,
    this.profileOwnersId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    
    return isCurrentUserr
        ? Padding(
          padding: const EdgeInsets.only(right: 10),
          child: editPf(context),
        )
        : _btnRow(
            label: !isFollowing ? 'Follow' : 'Unfollow',
            onP: () {
              isFollowing
                  ? context
                      .read<ProfileBloc>()
                      .add(ProfileUnfollowUserr())
                  : context.read<ProfileBloc>().add(ProfileFollowUserr());
            }, );
  }

  Widget editPf(BuildContext context) {
    //HexColor hexcolor = HexColor();
    return TextButton(onPressed: () => Navigator.of(context).pushNamed(
            EditProfileScreen.routeName,
            arguments: EditProfileScreenArgs(context: context)),
             child: Text("Edit", style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Theme.of(context).colorScheme.primary),));
  }
}

class _btnRow extends StatelessWidget {
  final String label;
  final VoidCallback onP;
  final Icon? icon_;
  const _btnRow({
    Key? key,
    required this.label,
    required this.onP,
    this.icon_,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 3.3,
      child: TextButton(
        onPressed: onP,
        child: Text(label, style: Theme.of(context).textTheme.subtitle1),
      ),
    );
  }
}


//Container(
//            height: 35.0,
//            color: isFollowing ? Colors.red[400] : Colors.red[50],
//            child: TextButton(
//              child: isFollowing
//                  ? Text('Unfollow', style: style)
//                  : Text('Follow', style: styleFalse),
//              onPressed: () {},
//            ),
//          );