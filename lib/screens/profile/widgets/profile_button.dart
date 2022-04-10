import 'package:flutter/material.dart';
import 'package:kingsfam/screens/edit_profile/edit_profile_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/screens/profile/bloc/profile_bloc.dart';

class ProfileButton extends StatelessWidget {
  final bool isCurrentUserr;
  final bool isFollowing;
  const ProfileButton({
    Key? key,
    required this.isCurrentUserr,
    required this.isFollowing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextStyle style = TextStyle(
        color: Colors.white, fontSize: 13, fontWeight: FontWeight.w400);
    final TextStyle styleFalse = TextStyle(
        color: Colors.black, fontSize: 15, fontWeight: FontWeight.w400);
    return isCurrentUserr
        ? EditPf(style, context)
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
                      : context
                          .read<ProfileBloc>()
                          .add(ProfileFollowUserr());
                }),
            SizedBox(width: 10.0),
            _btnRow(label: 'Message', style: style, onP: () {}),
          ],
        );
  }

  Container EditPf(TextStyle style, BuildContext context) {
    return Container(
          height: 29.0,
          width: 180,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.red[400]),
          child: TextButton(
            child: Text('Edit Profile', style: style),
            onPressed: () { Navigator.of(context).pushNamed(EditProfileScreen.routeName, arguments: EditProfileScreenArgs(context: context)); }
            //Navigator.of(context).pushNamed(EditProfileScreen.routeName, arguments: EditProfileScreenArgs(context: context));
          ),
        );
  }
}

class _btnRow extends StatelessWidget {
  final String label;
  final TextStyle style;
  final VoidCallback onP;
  const _btnRow({
    Key? key,
    required this.label,
    required this.style,
    required this.onP,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.0),
      child: Container(
          width: 80,
          height: 29.0,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0), color: Colors.red[400]),
          child: TextButton(
            style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0))),
            child: Text(label, style: style),
            onPressed: onP,
          )),
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