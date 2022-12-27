import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/cubits/liked_post/liked_post_cubit.dart';
import 'package:kingsfam/enums/bottom_nav_items.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/prayer_repo/prayer_repo.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/nav/cubit/bottomnavbar_cubit.dart';
import 'package:kingsfam/screens/profile/bloc/profile_bloc.dart';
import 'package:kingsfam/screens/profile/widgets/commuinity_container.dart';
import 'package:kingsfam/screens/profile/widgets/prayer_chunck.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/widgets/prayer/prayer_snipit.dart';
import 'package:kingsfam/widgets/widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../helpers/navigator_helper.dart';
import '../../widgets/videos/asset_video.dart';
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
              create: (_) => ProfileBloc(
                  prayerRepo: context.read<PrayerRepo>(),
                  churchRepository: context.read<ChurchRepository>(),
                  likedPostCubit: context.read<LikedPostCubit>(),
                  userrRepository: context.read<UserrRepository>(),
                  authBloc: context.read<AuthBloc>(),
                  postRepository: context.read<PostsRepository>(),
                  chatRepository: context.read<ChatRepository>()
                  // ..add(ProfileLoadUserr(userId: args.userId, vidCtrl: null)
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
  // controllers

  ScrollController scrollController = ScrollController();
  // late VideoPlayerController _perkedVideoPlayerController;
  @override
  void initState() {
    super.initState();

    // scrollController.addListener(listenToScrolling);
  }

  initializeProfileScreen(BuildContext context) {
    if (widget.initScreen == true || hasSeen == true)
      context.read<ProfileBloc>()
        ..add(ProfileLoadUserr(userId: widget.ownerId, vidCtrl: null));
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
        if (context.read<BottomnavbarCubit>().state.selectedItem == BottomNavItem.profile) {
          if (!hasSeen) {
            hasSeen = true;
            initializeProfileScreen(context);
          }
        } else if (widget.ownerId != context.read<AuthBloc>().state.user!.uid && widget.initScreen) {
          if (!hasSeen) {
            initializeProfileScreen(context);
            hasSeen = true;
          }
        }
        //----------------------------------------scaffold starts here
        return Scaffold(

            //---------------------------------------------------body path
            body: _bodyBabbyyyy(state));
      },
    );
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
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  title: Text(
                    state.userr.username,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  actions: [
                    // if (state.isCurrentUserr)
                    //    GestureDetector(
                    // onTap: () => NavHelper().navToSnackBar(context, state.userr.id),
                    // child: VisibilityDetector(
                    //   key: ObjectKey(_perkedVideoPlayerController),
                    //   onVisibilityChanged: (vis) {
                    //     vis.visibleFraction > 0
                    //         ? _perkedVideoPlayerController.play()
                    //         : _perkedVideoPlayerController.pause();
                    //   },
                    //   child: Container(
                    //       child: AssetVideoPlayer(
                    //     controller: _perkedVideoPlayerController,
                    //   )),
                    // )),
                  ],
                  // expandedHeight: 200,
                ),
                SliverToBoxAdapter(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height / 5,
                              width: double.infinity,
                            ),
                            BannerImage(
                              isOpasaty: false,
                              bannerImageUrl: state.userr.bannerImageUrl,
                              passedColor:
                                  hexcolor.hexcolorCode(state.userr.colorPref),
                            ),
                            Positioned(
                              top: 50,
                              left: 20,
                              child: ProfileImage(
                                radius: 45,
                                pfpUrl: state.userr.profileImageUrl,
                              ),
                            ),
                            Positioned(
                              top: 105,
                              right: state.isCurrentUserr ? 0 : 10,
                              child: ProfileButton(
                                isCurrentUserr: state.isCurrentUserr,
                                isFollowing: state.isFollowing,
                                colorPref: state.userr.colorPref,
                                profileOwnersId: widget.ownerId,
                              ),
                            )
                          ],
                          clipBehavior: Clip.none,
                        ),

                        Padding(
                          padding: state.userr.bio.isNotEmpty
                              ? EdgeInsets.symmetric(vertical: 10)
                              : EdgeInsets.symmetric(vertical: 0),
                          child: BigBoyBio(
                              username: state.userr.username,
                              bio: state.userr.bio),
                        ),

                        ProfileStats(
                            username: state.userr.username,
                            posts: state.post.length,
                            followers: state.userr.followers,
                            following: state.userr.following,
                            profileBloc: context.read<ProfileBloc>(),
                            ctxFromPf: context),

                        // add a linked list of commuinitys that I am in ... lol im done with this alredy but linked list dont make me laugh
                        CommuinityContainer(
                            cms: state.cms, ownerId: widget.ownerId),
                        GestureDetector(
                            onTap: () => state.prayer != null
                                ? PrayerChunk(
                                    context, state.prayer!, state.userr)
                                : null,
                            child: prayerSnipit(
                                state.prayer,
                                hexcolor.hexcolorCode(state.userr.colorPref),
                                context)),
                      ]),
                ),
                state.loadingPost
                    ? SliverToBoxAdapter(
                        child: LinearProgressIndicator(
                        color: Colors.blue,
                      ))
                    : state.post.length > 0
                        ? imageGrids(state: state)
                        : SliverToBoxAdapter(
                            child: Center(
                                child: Text(
                                    "${state.userr.username} Has No Post To Display Fam",
                                    style:
                                        Theme.of(context).textTheme.caption)))
              ],
            ));
    }
  }

  // John 3:16 for God so loved the world that he gave his one and only son that whoever believes in him should not parish but have
  // eternal life. Amen.

  imageGrids({required ProfileState state}) => SliverToBoxAdapter(
          child: Padding(
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
              height: MediaQuery.of(context).size.height / 3,
              width: double.infinity,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.post.length,
                itemBuilder: (context, index) {
                  Post? post = state.post[index];
                  if (post != null)
                    return displayPfpPost(post, index, state.post);
                  return SizedBox.shrink();
                },
              ),
            )
          ],
        ),
      ));

  Widget displayPfpPost(Post post, int index, List<Post?> lst) {
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
          height: MediaQuery.of(context).size.height / 5,
          width: MediaQuery.of(context).size.width * .70,
          child: Container(
              height: MediaQuery.of(context).size.height / 5,
              width: MediaQuery.of(context).size.width * .70,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: CachedNetworkImageProvider(displayImg),
                    fit: BoxFit.cover),
              )),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(context).colorScheme.primary,
                  ]),
              border: Border.all(color: Colors.amber, width: 1),
              borderRadius: BorderRadius.circular(2.0)),
        ),
      ),
    );
  }
}
