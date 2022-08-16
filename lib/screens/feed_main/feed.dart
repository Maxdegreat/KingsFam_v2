import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/cubits/cubits.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/post/post_repository.dart';
import 'package:kingsfam/screens/commuinity/screens/feed/bloc/feed_bloc.dart';
import 'package:kingsfam/widgets/widgets.dart';

class FeedScreenWidget extends StatefulWidget {
  const FeedScreenWidget({Key? key}) : super(key: key);

  @override
  _FeedScreenWidgetState createState() => _FeedScreenWidgetState();
}

class _FeedScreenWidgetState extends State<FeedScreenWidget>
    with AutomaticKeepAliveClientMixin {
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
      )..add(FeedFetchPosts()),
      child: _buildBody(size: size),
    );
  }
}

class _buildBody extends StatefulWidget {
  const _buildBody({
    Key? key,
    required this.size,
  }) : super(key: key);

  final Size size;

  @override
  __buildBodyState createState() => __buildBodyState();
}

class __buildBodyState extends State<_buildBody> {
  @override
  ScrollController scrollController = ScrollController();
  void initState() {
    scrollController.addListener(listenToScrolling);
    super.initState();
  }

  void listenToScrolling() {
   log("the position of the scroll controller for the feed is: ${scrollController.position.pixels}");
    // log("The view port of the scroll controller is: ${scrollController.position.viewportDimension}");
    // TODO you need to add this later make it a p1 requirment
    if (scrollController.position.atEdge) {
      if (scrollController.position.pixels != 0.0 &&
          scrollController.position.maxScrollExtent ==
              scrollController.position.pixels) {
        //  const snackBar = SnackBar(content: Text('Yay! A SnackBar!'));
        //  ScaffoldMessenger.of(context).showSnackBar(snackBar);
        // _createInlineBannerAd();
        context.read<FeedBloc>()..add(FeedPaginatePosts());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeedBloc, FeedState>(
      listener: (context, state) {},
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
                child: state.posts.length > 0
                    ? pageViewForPost(state)// listviewsinglePost(state)
                    : Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Follow Some Fam With Post First To Have A Feed"),
                            IconButton(icon: Icon(Icons.refresh), onPressed: () => context.read<FeedBloc>().add(FeedFetchPosts()),),
                          ],
                        )));
        }
      },
    );
  }

  pageViewForPost(FeedState state) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: state.posts.length,
      itemBuilder: (context, index) {
        if (index == state.posts.length) {
          context.read<FeedBloc>()..add(FeedPaginatePosts());
        }
        final Post? post = state.posts[index];
        if (post != null) {
          final LikedPostState = context.watch<LikedPostCubit>().state;
          final isLiked = LikedPostState.likedPostsIds.contains(post.id!);
          final recentlyLiked =
              LikedPostState.recentlyLikedPostIds.contains(post.id!);
          return PostSingleView(
            isLiked: isLiked,
            post: post,
            recentlyLiked: recentlyLiked,
            onLike: () {
              if (isLiked) {
                context.read<LikedPostCubit>().unLikePost(post: post);
              } else {
                context.read<LikedPostCubit>().likePost(post: post);
              }
            },
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}

// ListView listviewsinglePost(FeedState state) {
  //   return ListView.builder(
  //     shrinkWrap: false,
  //     controller: scrollController,
  //     itemCount: state.posts.length,
  //     itemBuilder: (BuildContext context, int index) {
  //       if (index == state.posts.length) {
  //         // TODO call paginate post
  //       }
  //       final Post? post = state.posts[index];
  //       if (post != null) {
  //         final LikedPostState = context.watch<LikedPostCubit>().state;
  //         final isLiked = LikedPostState.likedPostsIds.contains(post.id!);
  //         final recentlyLiked =
  //             LikedPostState.recentlyLikedPostIds.contains(post.id!);
  //         return PostSingleView(
  //           scrollController: scrollController,
  //           isLiked: isLiked,
  //           post: post,
  //           recentlyLiked: recentlyLiked,
  //           onLike: () {
  //             if (isLiked) {
  //               context.read<LikedPostCubit>().unLikePost(post: post);
  //             } else {
  //               context.read<LikedPostCubit>().likePost(post: post);
  //             }
  //           },
  //         );
  //       }
  //       return SizedBox.shrink();
  //     },
  //   );
  // }
  

// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter/material.dart';
// import 'package:kingsfam/blocs/auth/auth_bloc.dart';
// import 'package:kingsfam/cubits/cubits.dart';
// import 'package:kingsfam/repositories/post/post_repository.dart';
// import 'package:kingsfam/screens/commuinity/screens/feed/bloc/feed_bloc.dart';
// import 'package:kingsfam/widgets/widgets.dart';

// class FeedMain extends StatefulWidget {
//   const FeedMain({Key? key}) : super(key: key);

//   static const String routeName = 'FeedMain';
//   static Route route = MaterialPageRoute(
//       settings: const RouteSettings(name: routeName),
//       builder: (context) => BlocProvider<FeedBloc>(
//             create: (_) => FeedBloc(
//                 postsRepository: context.read<PostsRepository>(),
//                 authBloc: context.read<AuthBloc>(),
//                 likedPostCubit: context.read<LikedPostCubit>()),
//           ));

//   @override
//   State<FeedMain> createState() => _FeedMainState();
// }

// class _FeedMainState extends State<FeedMain> {
//   ScrollController scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     scrollController.addListener(listenToScrolling);
//   }

//   void listenToScrolling() {
//     if (scrollController.position.atEdge) {
//       if (scrollController.position.pixels != 0.0 &&
//           scrollController.position.maxScrollExtent ==
//               scrollController.position.pixels) {
//         //  const snackBar = SnackBar(content: Text('Yay! A SnackBar!'));
//         //  ScaffoldMessenger.of(context).showSnackBar(snackBar);

//         context.read<FeedBloc>()..add(FeedPaginatePosts());
//       }
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return FeedUi(context: context);
//   }
//   Widget FeedUi({required BuildContext context}) => Expanded(
//         flex: 1,
//         child: RefreshIndicator(
//           onRefresh: () async =>
//               context.read<FeedBloc>()..add(FeedFetchPosts()),
//           child: ListView.builder(
//             shrinkWrap: false,
//             controller: scrollController,
//             itemCount: state.posts.length + (_isInLineBannerAdLoaded ? 1 : 0),
//             itemBuilder: (BuildContext context, int index) {
//               if (_isInLineBannerAdLoaded && index == _inLineAdIndex) {
//                 return Padding(
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
//                   child: Container(
//                     height: AdSize.fullBanner.height.toDouble(),
//                     width: double.infinity,
//                     child: AdWidget(ad: _inLineBannerAd),
//                   ),
//                 );
//               } else {
//                 final Post? post = state.posts[_getListViewIndex(index)];
//                 if (post != null) {
//                   final LikedPostState = context.watch<LikedPostCubit>().state;
//                   final isLiked =
//                       LikedPostState.likedPostsIds.contains(post.id!);
//                   final recentlyLiked =
//                       LikedPostState.recentlyLikedPostIds.contains(post.id!);
//                   return PostSingleView(
//                     isLiked: isLiked,
//                     post: post,
//                     recentlyLiked: recentlyLiked,
//                     onLike: () {
//                       if (isLiked) {
//                         context.read<LikedPostCubit>().unLikePost(post: post);
//                       } else {
//                         context.read<LikedPostCubit>().likePost(post: post);
//                       }
//                     },
//                   );
//                 }
//               }
//               return SizedBox.shrink();
//             },
//           ),
//         ),
//       );

// }
