import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/cubits/cubits.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/post/post_repository.dart';
import 'package:kingsfam/screens/commuinity/screens/feed/bloc/feed_bloc.dart';
import 'package:kingsfam/widgets/widgets.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class FeedScreenWidget extends StatefulWidget {
  const FeedScreenWidget({Key? key}) : super(key: key);

  @override
  _FeedScreenWidgetState createState() => _FeedScreenWidgetState();
}

class _FeedScreenWidgetState extends State<FeedScreenWidget> with AutomaticKeepAliveClientMixin  {
  @override
  bool get wantKeepAlive => true;
  @override


  Widget build(BuildContext context) {
    super.build(context);
    Size size = MediaQuery.of(context).size;
    return BlocProvider<FeedBloc>(
      create: (_) => FeedBloc(
        authBloc: context.read<AuthBloc>(),
        likedPostCubit: context.read<LikedPostCubit>(),
        postsRepository: context.read<PostsRepository>(),
      ),
      child: _buildBody(size: size),
    );
  }
}


class _buildBody extends StatefulWidget {
  const _buildBody({ Key? key,  required this.size,}) : super(key: key);

  final Size size;

  @override
  __buildBodyState createState() => __buildBodyState();
}

class __buildBodyState extends State<_buildBody> {
    @override
  void initState() {
    
    super.initState();
    context.read<FeedBloc>().add(FeedFetchPosts());
    context.read<LikedPostCubit>().clearAllLikedPosts();
  }
  @override
  Widget build(BuildContext context) {
    ItemScrollController itemController = ItemScrollController();
    return BlocConsumer<FeedBloc, FeedState>(
      listener: (context, state) {

      },
      builder: (context, state) {
        switch (state.status) {
          case FeedStatus.loading:
            return Column(
              children: [
                const LinearProgressIndicator(color: Colors.red),
              ],
            );
          default: 
            return RefreshIndicator(
              onRefresh: () async {
                context.read<FeedBloc>().add(FeedFetchPosts());
                context.read<LikedPostCubit>().clearAllLikedPosts();
              },
              child: ScrollablePositionedList.builder(
              itemScrollController: itemController,
              itemCount: state.posts!.length,
              itemBuilder: (BuildContext context, int index) {
                if (index == state.posts!.length) {
                  // TODO call paginate post 
                }
                final Post? post = state.posts![index];
                if (post != null) {
                    final ctx = context.read<FeedBloc>();
                    final likedPost = context.read<FeedBloc>().state.likedPostIds;

                  return GestureDetector(
                    onDoubleTap: () {
                     if (likedPost.contains(post.id)) {
                       // todo unlike
                     } else {
                       context.read<FeedBloc>()..add(FeedLikePost(lkedPost: post));
                     }
                    },
                    child: PostSingleView(post: post, recentlyLiked: likedPost.contains(post.id))
                  );
                }
                print(post);
                return Text("post is null");
              },
            ));
        }
      },
    );
  }










              // child: ListView.builder(
              //   itemCount: state.posts!.length,
              //   itemBuilder: (BuildContext context, int index) {
              //     final Post? post = state.posts![index];
              //     final likedPostsState = context.watch<LikedPostCubit>().state;
              //     final isLiked = likedPostsState.likedPostsIds.contains(post!.id);
              //     final recentlyLiked =
              //     likedPostsState.recentlyLikedPostIds.contains(post.id);
              //      final ctx = context.read<LikedPostCubit>();
              //     return oldTackyColumnOfPost(post, isLiked, ctx, recentlyLiked, context);
              //   },
              // ),

  // Column oldTackyColumnOfPost(Post post, bool isLiked, LikedPostCubit ctx, bool recentlyLiked, BuildContext context) {
  //   return Column(
  //     children: [
  //       SizedBox(height: 7.0),
  //       leading_pfp_info(post),
  //       SizedBox(height: 5.0),
  //       body_post_info(isLiked, ctx, post),
  //       SizedBox(height: 5),
  //        postBottom(isLiked, recentlyLiked, post, context)
  //     ],
  //   );
  // }

  // ConstrainedBox body_post_info(bool isLiked, LikedPostCubit ctx, Post post) {
  //   return ConstrainedBox(
  //       constraints: BoxConstraints(maxHeight: widget.size.height / 1.4),
  //       child: GestureDetector(
  //         onDoubleTap: () {
  //           if (isLiked){
  //             ctx.unLikePost(post: post);
  //           } 
  //           else 
  //           ctx.likePost(post: post);
  //         },
  //         child: Container(
  //           child: // 1 if the post.imageUrl is not null
  //             post.imageUrl != null
  //             ? imageDisplay(post)
  //             // 2 if post.videoUrl is not null
  //             : post.videoUrl != null
  //             ? VidoeDisplay(videoUrl: post.videoUrl!)
  //             // 3 else quote is not null
  //             : SizedBox.shrink() // this will be for sounds later
  //           ),
  //       ),
  //     );
  // }

  // Widget leading_pfp_info(Post post) {
  //   return GestureDetector(
  //     onTap: () => Navigator.of(context).pushNamed(ProfileScreen.routeName, arguments: ProfileScreenArgs(userId: post.author.id)),
  //     child: FancyListTile(
  //         username: post.author.username, 
  //         imageUrl: post.author.profileImageUrl, 
  //         onTap: null, 
  //         isBtn: false, 
  //         BR: 5, 
  //         height: 16, 
  //         width: 18,
  //       ),
  //   );
  // }

  // Container postBottom(bool isLiked, bool recentlyLiked, Post post, BuildContext context) {
  //   return Container(
  //               padding: const EdgeInsets.symmetric(vertical: 5.0),
  //               child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   children: [
  //                     //add like and comment icons / functionality
  //                     Container(
  //                         child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.start,
  //                       children: [
  //                         IconButton(
  //                             onPressed: () {},
  //                             icon: isLiked
  //                                 ? Icon(
  //                                     Icons.favorite,
  //                                     color: Colors.deepPurple[700],
  //                                   )
  //                                 : Icon(Icons.favorite)),
  //                         Text(recentlyLiked
  //                             ? "${post.likes + 1}"
  //                             : "${post.likes}"),
  //                         SizedBox(
  //                             width: MediaQuery.of(context).size.width / 5),
  //                         IconButton(
  //                             onPressed: () {},
  //                             icon: FaIcon(FontAwesomeIcons.comment)),
  //                         SizedBox(
  //                             width: MediaQuery.of(context).size.width / 5),
  //                         //Text(post!.date.timeAgo())
  //                         Text("post columns")
  //                       ],
  //                     ))
  //                   ]));
  // }

  //  Padding imageDisplay(Post post) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 10.0),
  //     child: ConstrainedBox(
  //       constraints: BoxConstraints(minHeight: 900),
  //       child: Container(
  //           width: double.infinity,
  //           child: DecoratedBox(
  //             child: CachedNetworkImage(imageUrl: post.imageUrl!),
  //             decoration: BoxDecoration(
  //                 image: DecorationImage(
  //                     fit: BoxFit.contain,
  //                     //if error on loading image throw here
  //                     image: CachedNetworkImageProvider(post.imageUrl!))),
  //           )),
  //     ),
  //   );
  // }
}
