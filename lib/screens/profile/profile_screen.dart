import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/cubits/liked_post/liked_post_cubit.dart';

import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/profile/bloc/profile_bloc.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/widgets/widgets.dart';

import 'widgets/widgets.dart';

class ProfileScreenArgs {
  final String userId;
  ProfileScreenArgs({required this.userId});
}

class ProfileScreen extends StatefulWidget {
  //const ProfileScreen({Key? key}) : super(key: key);

  static const String routeName = '/profileScreen';

  static Route route({required ProfileScreenArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => BlocProvider<ProfileBloc>(
              create: (_) => ProfileBloc(
                  likedPostCubit: context.read<LikedPostCubit>(),
                  userrRepository: context.read<UserrRepository>(),
                  authBloc: context.read<AuthBloc>(),
                  postRepository: context.read<PostsRepository>())
                ..add(ProfileLoadUserr(userId: args.userId)),
              child: ProfileScreen(),
            ));
  }

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
                    content: state.failure.message,
                  ));
        }
      },
      builder: (context, state) {
        //----------------------------------------scaffold starts here
        return Scaffold(
            //--------------------------------------app bar
            appBar: AppBar(
              title: Text(state.userr.username),
              actions: [
                if (state.isCurrentUserr)
                  TextButton(
                    child: Text('logout',
                        style: Theme.of(context).textTheme.bodyText1),
                    onLongPress: () async =>
                        context.read<AuthBloc>().add(AuthLogoutRequested()),
                    onPressed: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              content:
                                  Text('hold logout for 3 seconds to log out'),
                            )),
                  )
              ],
            ),
            //---------------------------------------------------body path
            body: _bodyBabbyyyy(state));
      },
    );
  }

  //---------------------------------------------------------body widget extracted
  Widget _bodyBabbyyyy(ProfileState state) {
    switch (state.status) {
      case ProfileStatus.initial:
        return CircularProgressIndicator(color: Colors.red[400]);
      default:
        return RefreshIndicator(
          onRefresh: () async {
            context
                .read<ProfileBloc>()
                .add(ProfileLoadUserr(userId: state.userr.id));
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      children: [
                        BannerImage(
                          isOpasaty: false,
                          bannerImageUrl: state.userr.bannerImageUrl,
                        ),
                        Positioned(
                          top: 30,
                          left: 10,
                          child: ProfileImage(
                            radius: 40,
                            pfpUrl: state.userr.profileImageUrl,
                          ),
                        ),
                      ],
                      clipBehavior: Clip.none,
                    ),
                    const SizedBox(height: 25.0),
                    ProfileStats(
                        isCurrentUserr: state.isCurrentUserr,
                        isFollowing: state.isFollowing,
                        posts: state.post.length,
                        followers: state.userr.followers,
                        following: state.userr.following),
                    SizedBox(height: 10.0),
                    BigBoyBio(
                      username: state.userr.username,
                      bio: state.userr.bio,
                    )
                  ],
                ),
              ),
              SliverToBoxAdapter(
                  child: SizedBox(
                height: 25.0,
              )),
              SliverGrid(
                
                  delegate: SliverChildBuilderDelegate(
                    
                    (context, index) {
                      final post = state.post[index];
                      final likedPostState = context.watch<LikedPostCubit>().state;
                      final isLiked = likedPostState.likedPostsIds.contains(post!.id);
                      final recentlyLiked = likedPostState.recentlyLikedPostIds.contains(post.id);
                      final ctx = context.read<LikedPostCubit>();
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(ProfilePostView.routeName,
                                  arguments: ProfilePostViewArgs(
                                      posts: state.post,
                                      indexAt: index,
                                      isLiked: isLiked,
                                      onLike: () {
                                        if (isLiked)
                                          ctx.unLikePost(post: post);
                                        else
                                          ctx.likePost(post: post);
                                      },
                                      recentlyLiked: recentlyLiked));
                        },
                        child: Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                image: post.imageUrl != null
                                    ? DecorationImage(
                                        image: CachedNetworkImageProvider(
                                            post.imageUrl!),
                                        fit: BoxFit.cover)
                                    : null),
                            child: post.quote != null
                                ? Center(child: Text(post.quote!))
                                : post.videoUrl != null
                                    ? Text("Video url")
                                    : null),
                      );
                    },
                    childCount: state.post.length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 3.0,
                      crossAxisSpacing: 2.0))
            ],
          ),
        );
    }
  }
}
