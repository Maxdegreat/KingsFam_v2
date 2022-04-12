import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/cubits/liked_post/liked_post_cubit.dart';
import 'package:kingsfam/models/models.dart';

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
          onRefresh: () async => context.read<ProfileBloc>().add(ProfileLoadUserr(userId: state.userr.id)),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                title: Text(state.userr.username),
                  actions: [
                    if (state.isCurrentUserr)
                      IconButton(
                        icon: Icon(Icons.settings),
                        //onLongPress: () async => context.read<AuthBloc>().add(AuthLogoutRequested()),
                        onPressed: () => Navigator.of(context).pushNamed(EditProfileScreen.routeName, arguments: EditProfileScreenArgs(context: context))
                        ),
                  ],
                 // expandedHeight: 200,
                  
              ), 

              SliverToBoxAdapter(
                child: 
                  Column(
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
                                top: 105, right: state.isCurrentUserr ? 40 : 5,
                                child: ProfileButton(isCurrentUserr: state.isCurrentUserr, isFollowing: state.isFollowing, colorPref: state.userr.colorPref,),
                              )
                            ],
                            clipBehavior: Clip.none,
                          ),

          
              
                       ProfileStats( username: state.userr.username, posts: state.post.length, followers: state.userr.followers, following: state.userr.following),


                      // add a linked list of commuinitys that I am in
                      CommuinityContainer(userId: state.userr.id, username: state.userr.username,),
                  ]
                ),
              ),
                imageGrids(state: state)

            ],
          )
            
          
          
        );
    }
  }
  imageGrids({required ProfileState state}) => SliverToBoxAdapter(
    child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                mainAxisExtent: 320.0,
              ),
              primary: false,
              shrinkWrap: true,
              itemCount: state.post.length,
              itemBuilder: (BuildContext context, int index) {
                Post? post = state.post[index];
                return Column(
                  children: [
                    Stack(
                      children: 
                        [
                          Container(
                          height: 240, width: 300, 
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color> [
                                Colors.transparent,
                                Colors.black12,
                                Colors.black45,
                                Colors.black87,
                              ]
                            ),
                            color: Colors.green,
                            image: DecorationImage(image: CachedNetworkImageProvider(post!.imageUrl!), fit: BoxFit.cover),
                            borderRadius: BorderRadius.circular(18)
                          ),
                        ),
                       
                      ],
                    ),
                    SizedBox(height: 10),
                    ListTile(leading: commuinity_pf_img(post.author.profileImageUrl, 40, 40), title: Text(post.author.username, style: Theme.of(context).textTheme.bodyText1,),)
                  ],
                );
              },
  
            ),
  );
}






















                // this is the commuinty list            -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        //       Column(
        //         children: [

                        

        //               Divider(height: 15, color: Colors.white, thickness: 3,),
        //               // BigBoyBio(
        //                 // username: state.userr.username,
        //                 // bio: state.userr.bio,
        //               // )
        //             ],
        //           ),
               
        //       // this is a sizxed box
        //       SizedBox(
        //       height: 5.0,
        //       ),
        //       // SliverGrid(
              
        //       //     delegate: SliverChildBuilderDelegate(
                  
        //       //       (context, index) {
        //       //         final post = state.post[index];
        //       //         final likedPostState = context.watch<LikedPostCubit>().state;
        //       //         final isLiked = likedPostState.likedPostsIds.contains(post!.id);
        //       //         final recentlyLiked = likedPostState.recentlyLikedPostIds.contains(post.id);
        //       //         final ctx = context.read<LikedPostCubit>();
        //       //         return GestureDetector(
        //       //           onTap: () {
        //       //             Navigator.of(context)
        //       //                 .pushNamed(ProfilePostView.routeName,
        //       //                     arguments: ProfilePostViewArgs(
        //       //                         posts: state.post,
        //       //                         indexAt: index,
        //       //                         isLiked: isLiked,
        //       //                         onLike: () {
        //       //                           if (isLiked)
        //       //                             ctx.unLikePost(post: post);
        //       //                           else
        //       //                             ctx.likePost(post: post);
        //       //                         },
        //       //                         recentlyLiked: recentlyLiked));
        //       //           },
        //       //           child: Container(
        //       //               height: 100,
        //       //               width: 100,
        //       //               decoration: BoxDecoration(
        //       //                   borderRadius: BorderRadius.circular(5.0),
        //       //                   image: post.imageUrl != null
        //       //                       ? DecorationImage(
        //       //                           image: CachedNetworkImageProvider(
        //       //                               post.imageUrl!),
        //       //                           fit: BoxFit.cover)
        //       //                       : null),
        //       //               child: post.quote != null
        //       //                   ? Center(child: Text(post.quote!))
        //       //                   : post.videoUrl != null
        //       //                       ? Text("Video url")
        //       //                       : null),
        //       //         );
        //       //       },
        //       //       childCount: state.post.length,
        //       //     ),
        //       //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //       //         crossAxisCount: 3,
        //       //         mainAxisSpacing: 3.0,
        //       //         crossAxisSpacing: 2.0))
              
              
        //       //    -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-           
        //       Container(
        //         height: MediaQuery.of(context).size.height / 3.7 ,
        //         decoration: BoxDecoration(
        //           color: Colors.transparent
        //         ),
        //         // -0=-=-=--=-=-=-0-
        //         child: 
        // )
                   
        //         ],
        //       ),