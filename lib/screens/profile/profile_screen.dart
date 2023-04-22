import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/constants.dart';
import 'package:kingsfam/config/global_keys.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/cubits/buid_cubit/buid_cubit.dart';
import 'package:kingsfam/cubits/liked_post/liked_post_cubit.dart';
import 'package:kingsfam/enums/bottom_nav_items.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/prayer_repo/prayer_repo.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/nav/cubit/bottomnavbar_cubit.dart';
import 'package:kingsfam/screens/profile/bloc/profile_bloc.dart';
import 'package:kingsfam/screens/profile/widgets/commuinity_container.dart';
import 'package:kingsfam/screens/profile/widgets/container_w_children.dart';
import 'package:kingsfam/screens/profile/widgets/loadingUserScreen.dart';
import 'package:kingsfam/screens/profile/widgets/prayer_chunck.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/widgets/prayer/prayer_snipit.dart';
import 'package:kingsfam/widgets/roundContainerWithImgUrl.dart';
import 'package:kingsfam/widgets/widgets.dart';

import 'widgets/widgets.dart';

class ProfileScreenArgs {
  final String userId;
  final bool initScreen;
  ProfileScreenArgs({required this.userId, required this.initScreen});
}

class ProfileScreen extends StatefulWidget {
  //const ProfileScreen({Key? key}) : super(key: key);

  static const String routeName = '/profileScreen';

  final String ownerId;
  final bool initScreen;
  const ProfileScreen({
    required this.ownerId,
    required this.initScreen,
  });

  static Route route({required ProfileScreenArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => BlocProvider<ProfileBloc>(
              create: (context) => ProfileBloc(
                authBloc: context.read<AuthBloc>(),
                churchRepository: context.read<ChurchRepository>(),
                likedPostCubit: context.read<LikedPostCubit>(),
                postRepository: context.read<PostsRepository>(),
                prayerRepo: context.read<PrayerRepo>(),
                userrRepository: context.read<UserrRepository>(),
              ),
              child: ProfileScreen(
                initScreen: args.initScreen,
                ownerId: args.userId,
              ),
            ));
  }

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
  }

  bool hasSeen = false;
  @override
  Widget build(BuildContext context) {
    //----------------------------------------------------------bloc consumer
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.error) {
          //showDialog
          showDialog(
              context: context,
              builder: (context) => ErrorDialog(
                    content: 'Profile Screen: ${state.failure.message}',
                  ));
        }
      },
      builder: (context, state) {
        if (context.read<BottomnavbarCubit>().state.selectedItem == BottomNavItem.profile && widget.ownerId == context.read<AuthBloc>().state.user!.uid) {
          if (!hasSeen) {
            hasSeen = true;
                context.read<ProfileBloc>()
            ..add(ProfileLoadUserr(userId: context.read<AuthBloc>().state.user!.uid, vidCtrl: null));
          }
        } else if (widget.ownerId != context.read<AuthBloc>().state.user!.uid &&
            widget.initScreen) {
          if (!hasSeen) {
            context.read<ProfileBloc>()
              ..add(ProfileLoadUserr(userId: widget.ownerId, vidCtrl: null));
            hasSeen = true;
          }
        }
        //----------------------------------------scaffold starts here
        return Scaffold(
            appBar: AppBar(
              title: Text(
                state.userr.username,
                style: Theme.of(context).textTheme.bodyText1,
              ),
              // leading: IconButton(onPressed: () => scaffoldKey.currentState!.openDrawer(), icon: Icon(Icons.menu)),
              actions: [
                if (!state.isCurrentUserr)
                  GestureDetector(
                      onTap: () {
                        _showOptions();
                      },
                      child: Icon(Icons.more_vert)),
              ],
            ),
            //---------------------------------------------------body path
            body: _bodyBabbyyyy(state));
      },
    );
  }

  _showOptions() {
    return showModalBottomSheet(
        context: context,
        builder: ((context) {
          bool isBlocked =
              context.read<BuidCubit>().state.buids.contains(widget.ownerId);
          return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.ownerId !=
                    context.read<AuthBloc>().state.user!.uid) ...[
                  ListTile(
                    onTap: () {
                      Map<String, dynamic> info = {
                        "userId": widget.ownerId,
                        "what": "post",
                        "continue": FirebaseFirestore.instance
                            .collection(Paths.users)
                            .doc(widget.ownerId),
                      };
                      Navigator.of(context).pushNamed(
                          ReportContentScreen.routeName,
                          arguments: RepoetContentScreenArgs(info: info));
                    },
                    leading: Icon(Icons.report_gmailerrorred,
                        color: Colors.red[400]),
                    title: Text(
                      "Report user",
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1!
                          .copyWith(color: Colors.red[400]),
                    ),
                  ),
                  SizedBox(height: 7),
                  ListTile(
                    leading: Icon(Icons.block, color: Colors.red[400]),
                    title: isBlocked
                        ? Text("Unblock user",
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(color: Colors.red[400]))
                        : Text("Block user",
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(color: Colors.red[400])),
                    onTap: () {
                      // add userId to systemdb of blocked uids

                      context.read<BuidCubit>().onBlockUser(widget.ownerId);

                      isBlocked
                          ? snackBar(
                              snackMessage:
                                  "KingsFam will show content from this user if in same community.",
                              context: context)
                          : snackBar(
                              snackMessage:
                                  "KingsFam will hide content from this user next time.",
                              context: context);
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ]);
        }));
  }

  //---------------------------------------------------------body widget extracted
  Widget _bodyBabbyyyy(ProfileState state) {
    switch (state.status) {
      case ProfileStatus.initial:
        return Center(child: CircularProgressIndicator(color: Colors.red[400]));
      default:
        return RefreshIndicator(
            // ---------------- LOOK HERE NEEDS SOME INTERNAL WORK TODO
            onRefresh: () async => context
                .read<ProfileBloc>()
                .add(ProfileLoadUserr(userId: state.userr.id)),
            child: 
            state.userr == Userr.empty ?

            loadingUserScreen(context)

            :

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if ((widget.ownerId !=
                              context.read<AuthBloc>().state.user!.uid &&
                          context
                              .read<BuidCubit>()
                              .state
                              .buids
                              .contains(widget.ownerId))) ...[
                        ListTile(
                          leading: Icon(
                            Icons.remove_red_eye,
                            color: Colors.redAccent,
                          ),
                          title: Text(
                            "You blocked this user",
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(color: Colors.redAccent),
                          ),
                          trailing: Icon(Icons.cancel_outlined,
                              color: Colors.redAccent),
                          onTap: () {
                            context
                                .read<BuidCubit>()
                                .onBlockUser(widget.ownerId);
                            snackBar(
                                snackMessage: "KingsFam will unblock this user",
                                context: context);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                      Stack(
                        children: [
                          BannerImage(
                            isOpasaty: false,
                            bannerImageUrl: state.userr.bannerImageUrl,
                          ),
                          Positioned(
                            right:
                                (MediaQuery.of(context).size.shortestSide / 2) -
                                    40,
                            left:
                                (MediaQuery.of(context).size.shortestSide / 2) -
                                    40,
                            height: 55,
                            bottom: -20,
                            child: ContainerWithURLImg(
                                imgUrl: state.userr.profileImageUrl,
                                width: 50,
                                height: 50,
                                pc: Theme.of(context).scaffoldBackgroundColor),
                          ),
                        ],
                        clipBehavior: Clip.none,
                      ),
                      const SizedBox(height: 40),
                      containerWChildren([
                        Text(state.userr.username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyLarge),
                        Divider(
                            color:
                                Theme.of(context).colorScheme.inversePrimary),
                        if (state.userr.bio.isNotEmpty) ...[
                          Text(state.userr.bio,
                              style: Theme.of(context).textTheme.caption),
                          Divider(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary),
                        ],
                        if (state.userr != Userr.empty) ...[
                          ProfileStats(
                            followers: state.userr.followers,
                            following: state.userr.following,
                            profileBloc: context.read<ProfileBloc>(),
                            ctxFromPf: context),
                        ]
                      ],
                          Color(hc.hexcolorCode(state.userr.colorPref)),
                          Theme.of(context).colorScheme.secondary,
                          double.infinity),
                      const SizedBox(height: 40),
                      containerWChildren([
                        if (state.post.isNotEmpty ||
                            state.prayer != null ||
                            state.cms.isNotEmpty) ...[
                          if (state.cms.isNotEmpty) ...[
                            CommuinityContainer(
                                cms: state.cms, ownerId: widget.ownerId),
                            Divider(
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary),
                          ],
                          if (state.prayer != null) ...[
                            GestureDetector(
                                onTap: () => state.prayer != null
                                    ? PrayerChunk(
                                        context, state.prayer!, state.userr)
                                    : null,
                                child: prayerSnipit(
                                    state.prayer,
                                    hexcolor
                                        .hexcolorCode(state.userr.colorPref),
                                    context)),
                            Divider(
                                color: Theme.of(context)
                                    .colorScheme
                                    .inversePrimary),
                          ],
                          if (state.post.isNotEmpty) ...[
                            imageGrids(state: state)
                          ]
                        ] else ...[
                          Center(
                            child: Text(
                              "Hmmm, well looks like theres nothing to see here",
                              style: Theme.of(context).textTheme.caption,
                            ),
                          )
                        ]
                      ],
                          Color(hc.hexcolorCode(state.userr.colorPref)),
                          Theme.of(context).colorScheme.secondary,
                          double.infinity),
                      const SizedBox(height: 40),
                    ]),
              ),
            )
        );
    }
  }

  // John 3:16 for God so loved the world that he gave his one and only son that whoever believes in him should not parish but have
  // eternal life. Amen.

  imageGrids({required ProfileState state}) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0, top: 5),
              child: Text(
                state.userr.username + " Post's",
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(fontSize: 15, fontWeight: FontWeight.normal),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(ProfilePostView.routeName,
                      arguments: ProfilePostViewArgs(
                          startIndex: 0,
                          posts: state.post,
                          currUsrId: context.read<AuthBloc>().state.user!.uid));
                },
                child: Text(
                  "View all Posts",
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(fontSize: 15, fontWeight: FontWeight.normal),
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.shortestSide / 3,
              width: double.infinity,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.post.length,
                itemBuilder: (context, index) {
                  Post? post = state.post[index];
                  if (post != null)
                    return displayPfpPost(post, index, state.post, state);
                  return SizedBox.shrink();
                },
              ),
            )
          ],
        ),
      );

  Widget displayPfpPost(
      Post post, int index, List<Post?> lst, ProfileState state) {
    String displayImg = (post.imageUrl ?? post.thumbnailUrl)!;
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(ProfilePostView.routeName,
          arguments: ProfilePostViewArgs(
              startIndex: index,
              posts: lst,
              currUsrId: context.read<AuthBloc>().state.user!.uid)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: EdgeInsets.only(bottom: 2.0),
          decoration: BoxDecoration(
            color: Color(hc.hexcolorCode(state.userr.colorPref)),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Container(
              height: MediaQuery.of(context).size.shortestSide / 4,
              width: MediaQuery.of(context).size.shortestSide / 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                image: DecorationImage(
                    image: CachedNetworkImageProvider(displayImg),
                    fit: BoxFit.cover),
              )),
        ),
      ),
    );
  }
}
