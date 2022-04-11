import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/cubits/liked_post/liked_post_cubit.dart';

import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/repositories/sounds/sounds_recorder_repository.dart';
import 'package:kingsfam/screens/profile/bloc/profile_bloc.dart';
import 'package:kingsfam/screens/profile/widgets/commuinity_container.dart';
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
    var post_img_vid_size = MediaQuery.of(context).size.height / 5;
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
          child: 
              // this is the commuinty list
              Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                          Stack(
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height / 5,
                                width: double.infinity,
                                color: Colors.transparent,
                              ),
                              BannerImage(
                                isOpasaty: false,
                                bannerImageUrl: state.userr.bannerImageUrl,
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
                                top: 105, right: 65,
                                child: ProfileButton(isCurrentUserr: state.isCurrentUserr, isFollowing: state.isFollowing),
                              )
                            ],
                            clipBehavior: Clip.none,
                          ),

          
              
                      ProfileStats( username: state.userr.username, posts: state.post.length, followers: state.userr.followers, following: state.userr.following),


                      // add a linked list of commuinitys that I am in
                      CommuinityContainer(userId: state.userr.id,),
                        

                      Divider(height: 15, color: Colors.white, thickness: 3,),
                      // BigBoyBio(
                        // username: state.userr.username,
                        // bio: state.userr.bio,
                      // )
                    ],
                  ),
               
              // this is a sizxed box
              SizedBox(
              height: 5.0,
              ),
              // SliverGrid(
              
              //     delegate: SliverChildBuilderDelegate(
                  
              //       (context, index) {
              //         final post = state.post[index];
              //         final likedPostState = context.watch<LikedPostCubit>().state;
              //         final isLiked = likedPostState.likedPostsIds.contains(post!.id);
              //         final recentlyLiked = likedPostState.recentlyLikedPostIds.contains(post.id);
              //         final ctx = context.read<LikedPostCubit>();
              //         return GestureDetector(
              //           onTap: () {
              //             Navigator.of(context)
              //                 .pushNamed(ProfilePostView.routeName,
              //                     arguments: ProfilePostViewArgs(
              //                         posts: state.post,
              //                         indexAt: index,
              //                         isLiked: isLiked,
              //                         onLike: () {
              //                           if (isLiked)
              //                             ctx.unLikePost(post: post);
              //                           else
              //                             ctx.likePost(post: post);
              //                         },
              //                         recentlyLiked: recentlyLiked));
              //           },
              //           child: Container(
              //               height: 100,
              //               width: 100,
              //               decoration: BoxDecoration(
              //                   borderRadius: BorderRadius.circular(5.0),
              //                   image: post.imageUrl != null
              //                       ? DecorationImage(
              //                           image: CachedNetworkImageProvider(
              //                               post.imageUrl!),
              //                           fit: BoxFit.cover)
              //                       : null),
              //               child: post.quote != null
              //                   ? Center(child: Text(post.quote!))
              //                   : post.videoUrl != null
              //                       ? Text("Video url")
              //                       : null),
              //         );
              //       },
              //       childCount: state.post.length,
              //     ),
              //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              //         crossAxisCount: 3,
              //         mainAxisSpacing: 3.0,
              //         crossAxisSpacing: 2.0))
                         
              Container(
                height: MediaQuery.of(context).size.height / 3.7 ,
                decoration: BoxDecoration(
                  color: Colors.transparent
                ),
                // -0=-=-=--=-=-=-0-
                child: 
                    // breaks bc below
                    //TextButton(onPressed: () {print("${state.post.length}");}, child: Text("Test the psots"))
                    state.post.length == 1 ? 
                    // show the one post
                    Container(
                      height: 100, width: 100, 
                      decoration: BoxDecoration(image: DecorationImage(image: CachedNetworkImageProvider(state.post.first!.imageUrl!), fit: BoxFit.cover), borderRadius: BorderRadius.circular(12)),
                    ) :

                    state.post.length >= 2 ?

                    Stack(
                      children: [

                        Positioned(
                          top: 45, right: 40,
                          child: Container(
                            height: post_img_vid_size * 1.1, width: post_img_vid_size * 1.5, 
                            decoration: BoxDecoration(image: DecorationImage(image: CachedNetworkImageProvider(state.post.first!.imageUrl!), fit: BoxFit.cover), borderRadius: BorderRadius.circular(12)),
                          ),
                        ),

                        Positioned(
                          top: 10, left: 10,
                          child: Container(
                            height: post_img_vid_size * 1.1, width: post_img_vid_size * 1.6, 
                            decoration: BoxDecoration(image: DecorationImage(image: CachedNetworkImageProvider(state.post.first!.imageUrl!), fit: BoxFit.cover), borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    )  :

                    SizedBox.shrink()

                   
               
              )
                ],
              ),
          
          
        );
    }
  }


  
}


