import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kingsfam/screens/chat_room/chat_room.dart';
import 'package:kingsfam/screens/edit_profile/edit_profile_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/screens/profile/bloc/profile_bloc.dart';

class ProfileButton extends StatelessWidget {
  final bool isCurrentUserr;
  final bool isFollowing;
  final String colorPref;
  final String? profileOwnersId;
  const ProfileButton({
    Key? key,
    required this.isCurrentUserr,
    required this.isFollowing,
    required this.colorPref,
    this.profileOwnersId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextStyle style = TextStyle(
        color: Colors.white, fontSize: 13, fontWeight: FontWeight.w400);
    final TextStyle styleFalse = TextStyle(
        color: Colors.black, fontSize: 15, fontWeight: FontWeight.w400);
    return isCurrentUserr
        ? editPf(style, context)
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //mainAxisSize: MainAxisSize.min,
            children: [
              _btnRow(
                  label: !isFollowing ? 'Follow' : 'Unfollow',
                  style: style,
                  onP: () {
                    isFollowing
                        ? context
                            .read<ProfileBloc>()
                            .add(ProfileUnfollowUserr())
                        : context.read<ProfileBloc>().add(ProfileFollowUserr());
                  }),
              SizedBox(width: 7.0),
              _btnRow(
                label: 'Message',
                style: style,
                onP: () async {
                  if (profileOwnersId != null) {
                    context
                        .read<ProfileBloc>()
                        .add(ProfileDm(profileOwnersId: profileOwnersId!, ctx: context));
                  }
                },
                icon_: null,
              ),
            ],
          );
  }

  Widget editPf(TextStyle style, BuildContext context) {
    //HexColor hexcolor = HexColor();
    return Container(
      width: MediaQuery.of(context).size.width / 3,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pushNamed(
            EditProfileScreen.routeName,
            arguments: EditProfileScreenArgs(context: context)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Edit Profile', style: style),
            SizedBox(width: 5),
            Icon(
              Icons.settings,
              size: 15,
            )
          ],
        ),
        style: ElevatedButton.styleFrom(
            elevation: 3.5,
            shadowColor: Colors.white,
            primary: Colors.red[600]),
      ),
    );
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: style),
            SizedBox(width: 5),
            icon_ != null ? icon_! : SizedBox.shrink()
          ],
        ),
        style: ElevatedButton.styleFrom(
            elevation: 3.5,
            shadowColor: Colors.white,
            primary: Colors.red[600]),
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