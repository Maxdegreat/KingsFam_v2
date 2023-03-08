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
    final TextStyle style = TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w400);
    final TextStyle styleFalse = TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w400);
    
    return isCurrentUserr
        ? Padding(
          padding: const EdgeInsets.only(right: 10),
          child: editPf(style, context),
        )
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
                  }, colorpref: colorPref,),
              SizedBox(width: 7.0),
              // _btnRow(
              //   label: 'Message',
              //   style: style,
              //   onP: () async {
              //     if (profileOwnersId != null) {
              //       context
              //           .read<ProfileBloc>()
              //           .add(ProfileDm(profileOwnersId: profileOwnersId!, ctx: context));
              //     }
              //   },
              //   icon_: null, colorpref: colorPref,
              // ),
            ],
          );
  }

  Widget editPf(TextStyle style, BuildContext context) {
    //HexColor hexcolor = HexColor();
    return Container(
      width: MediaQuery.of(context).size.width / 3,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: StadiumBorder(),
          primary: Theme.of(context).colorScheme.secondary
        ),
        onPressed: () => Navigator.of(context).pushNamed(
            EditProfileScreen.routeName,
            arguments: EditProfileScreenArgs(context: context)),
        child: Text("Edit", style: Theme.of(context).textTheme.caption,),
      ),
    );
  }
}

class _btnRow extends StatelessWidget {
  final String label;
  final TextStyle style;
  final VoidCallback onP;
  final Icon? icon_;
  final String colorpref;
  const _btnRow({
    Key? key,
    required this.label,
    required this.style,
    required this.onP,
    this.icon_,
    required this.colorpref,
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
            shadowColor: Color.fromARGB(255, 36, 39, 90),
            primary: Color(hexcolor.hexcolorCode(colorpref))),
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