import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/cubits/liked_post/liked_post_cubit.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/prayer_repo/prayer_repo.dart';
import 'package:kingsfam/repositories/repositories.dart';
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
  final VideoPlayerController? vidCtrl;
  ProfileScreenArgs({required this.userId, this.vidCtrl});
}

class ProfileScreen extends StatefulWidget {
  //const ProfileScreen({Key? key}) : super(key: key);

  static const String routeName = '/profileScreen';

  final String ownerId;
  const ProfileScreen({
    required this.ownerId,
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
                  chatRepository: context.read<ChatRepository>())
                ..add(ProfileLoadUserr(
                    userId: args.userId, vidCtrl: null)),
              child: ProfileScreen(
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


  // void listenToScrolling() {
  //   //TODO you need to add this later make it a p1 requirment
  //   if (scrollController.position.atEdge) {
  //     if (scrollController.position.pixels != 0.0 &&
  //         scrollController.position.maxScrollExtent ==
  //             scrollController.position.pixels) {
  //       // snackBar(snackMessage: "yay a snack bar", context: context);
  //       log("This is a log");
  //       context.read<ProfileBloc>()
  //         ..add(ProfilePaginatePosts(
  //             userId: widget.ownerId)); // ----------------- TODO This is why ur pag does not work properly. use a dynamic id. cant pag someone else w/ ur id
  //       log("HEY I AM CALLING A PAGINATION MAX!!!");
  //     }
  //   }
  // }

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
        return RefreshIndicator( // ---------------- LOOK HERE NEEDS SOME INTERNAL WORK TODO
            onRefresh: () async => context
                .read<ProfileBloc>()
                .add(ProfileLoadUserr(userId: state.userr.id)),
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  title: Text(state.userr.username),
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
                          padding: state.userr.bio.isNotEmpty ? EdgeInsets.symmetric(vertical: 10) : EdgeInsets.symmetric(vertical: 0),
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
                        CommuinityContainer(cms: state.cms, ownerId: widget.ownerId),
                        GestureDetector(
                          onTap: () => state.prayer != null ? PrayerChunk(context, state.prayer!, state.userr) : null,
                          child: prayerSnipit(state.prayer, hexcolor.hexcolorCode(state.userr.colorPref))),

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
                            child: CenterdText(
                                text:
                                    "${state.userr.username} Has No Post To Display Fam"))
              ],
            ));
    }
  }

  // John 3:16 for God so loved the world that he gave his one and only son that whoever believes in him should not parish but have
  // eternal life. Amen.

  imageGrids({required ProfileState state}) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0, // x axis
              mainAxisSpacing: 10.0, // y axis
              mainAxisExtent: 205.0, // -> 230
            ),
            primary: false,
            shrinkWrap: true,
            itemCount: state.post.length,
            itemBuilder: (BuildContext context, int index) {
              Post? post = state.post[index];
              return Column(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed(
                        ProfilePostView.routeName,
                        arguments: ProfilePostViewArgs(
                            posts: state.post,
                            startIndex: index,
                             currUsrId: widget.ownerId,
                            isFromPfpScreen: true)),
                    //Navigator.of(context).pushNamed(FeedNewScreen.routeName, arguments: FeedNewScreenArgs(startIndex: index, posts: state.post)),
                    child: Container(
                      height: 100,
                      width: 130,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          image: post!.imageUrl != null
                              ? DecorationImage(
                                  image:
                                      CachedNetworkImageProvider(post.imageUrl!),
                                  fit: BoxFit.cover)
                              : DecorationImage(
                                  image: CachedNetworkImageProvider(
                                      post.thumbnailUrl!),
                                  fit: BoxFit.cover),
                          borderRadius: BorderRadius.circular(18)),
                    ),
                  ),
                   SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      commuinity_pf_img(post.author.profileImageUrl, 35, 35),
                      SizedBox(width: 5),
                      Flexible(
                          child: Text(
                        post.author.username.length > 18 ? post.author.username.substring(0, 18) : post.author.username,
                        style: Theme.of(context).textTheme.bodyText1,
                        overflow: TextOverflow.fade,
                      ))
                    ],
                  )
                ],
              );
            },
          ),
        ),
      );
}