import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  const ProfileStats({
    Key? key,
    required this.profileBloc,
    required this.username,
    required this.posts,
    required this.followers,
    required this.following,
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
                      followingInfoBtn(context)
                ],
              ),
            ),
          ],
        ));
  }

  GestureDetector followingInfoBtn(context) => GestureDetector(onTap:(){_showFollowing(context); profileBloc.add(ProfileLoadFollowingUsers(lastStringId: null));}, child: Text("$following Following", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)));

  GestureDetector followersInfoBtn(context) => GestureDetector(onTap:(){_showFollowers(context); profileBloc.add(ProfileLoadFollowersUsers(lastStringId: null));},child: Text("$followers Followers", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)));

  _showFollowing(BuildContext context) async {
    return showModalBottomSheet(context: context, 
    builder: (context) => BlocProvider<ProfileBloc>.value(
      value: profileBloc,
      child: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          
          children: [
            Text("FOLLOWING"),
            Expanded(
              flex: 1 ,
              child: ListView.builder(
                itemCount: context.read<ProfileBloc>().state.followingUserList.length,
                itemBuilder: (BuildContext context, int index) {
                  final Userr user = context.read<ProfileBloc>().state.followingUserList[index];
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: ProfileImage(radius: 30, pfpUrl: user.profileImageUrl),
                        title: Text(user.username),
                        trailing: Text("followers: ${user.followers}"),
                        onTap: ()=> Navigator.of(context).pushNamed(ProfileScreen.routeName, arguments: ProfileScreenArgs(userId: user.id)),
                      ),
                      SizedBox(height: 7,)
                    ],
                  );
                }
              ),
            ),
          ],
        ),
      ),
    ));
  }

  _showFollowers(BuildContext context) {
    return showModalBottomSheet(context: context, builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          
          children: [
            Text("FOLLOWERS"),
            Expanded(
              flex: 1,
              child: ListView.builder(
                itemCount: profileBloc.state.followersUserList.length,
                itemBuilder: (BuildContext context, int index) {
                  final Userr user = profileBloc.state.followersUserList[index];
                  return ListTile(
                    leading: ProfileImage(radius: 30, pfpUrl: user.profileImageUrl),
                    title: Text(user.username),
                    trailing: Text('followers: ${user.followers}'),
                    onTap: ()=> Navigator.of(context).pushNamed(ProfileScreen.routeName, arguments: ProfileScreenArgs(userId: user.id)),
                  );
                }
              ),
            ),
          ],
        ),
      );
    });
  }
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
