import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kingsfam/config/constants.dart';
import 'package:kingsfam/screens/edit_profile/edit_profile_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/screens/profile/bloc/profile_bloc.dart';

import '../../search/search_screen.dart';

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
    final TextStyle style = TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w400);
    final TextStyle styleFalse = TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w400);
    
    return isCurrentUserr
        ? Padding(
          padding: const EdgeInsets.only(right: 10),
          child: editPf(style, context),
        )
        : _btnRow(
            label: !isFollowing ? 'Follow' : 'Unfollow',
            style: style,
            onP: () {
              isFollowing
                  ? context
                      .read<ProfileBloc>()
                      .add(ProfileUnfollowUserr())
                  : context.read<ProfileBloc>().add(ProfileFollowUserr());
            }, );
  }

  Widget editPf(TextStyle style, BuildContext context) {
    //HexColor hexcolor = HexColor();
    return TextButton(onPressed: () => Navigator.of(context).pushNamed(
            EditProfileScreen.routeName,
            arguments: EditProfileScreenArgs(context: context)),
             child: Text("Edit"));
  }
}

class _btnRow extends StatelessWidget {
  final String label;
  final TextStyle style;
  final VoidCallback onP;
  final Icon? icon_;
  const _btnRow({
    Key? key,
    required this.label,
    required this.style,
    required this.onP,
    this.icon_,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 3.3,
      child: ElevatedButton(
        onPressed: onP,
        child: Text(label, style: style),
        style: ElevatedButton.styleFrom(
            elevation: 3.5,
            shadowColor: Color.fromARGB(255, 36, 39, 90),
            ),
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