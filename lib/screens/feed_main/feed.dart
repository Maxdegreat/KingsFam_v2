import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/cubits/buid_cubit/buid_cubit.dart';
import 'package:kingsfam/cubits/cubits.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/post/post_repository.dart';
import 'package:kingsfam/screens/commuinity/screens/feed/bloc/feed_bloc.dart';
import 'package:kingsfam/widgets/widgets.dart';

class FeedScreenWidget extends StatefulWidget {
  const FeedScreenWidget({Key? key, required this.tabController}) : super(key: key);
  final TabController tabController;

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
        buidCubit: context.read<BuidCubit>(),
        authBloc: context.read<AuthBloc>(),
        likedPostCubit: context.read<LikedPostCubit>(),
        postsRepository: context.read<PostsRepository>(),
      )..add(FeedFetchPosts()),
      child: _buildBody(size: size, tabCtrl: widget.tabController),
    );
  }
}

class _buildBody extends StatefulWidget {
  const _buildBody({
    Key? key,
    required this.size,
    required this.tabCtrl,
  }) : super(key: key);

  final Size size;
  final TabController tabCtrl;

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
      onPageChanged: (pageNum) {
        if (pageNum == state.posts.length - 1) {
          context.read<FeedBloc>()..add(FeedPaginatePosts());
        }
      },
      itemBuilder: (context, index) {
        
        final Post? post = state.posts[index];
        if (post != null) {
          final LikedPostState = context.watch<LikedPostCubit>().state;
          final isLiked = LikedPostState.likedPostsIds.contains(post.id!);
          final recentlyLiked =
              LikedPostState.recentlyLikedPostIds.contains(post.id!);
              // there is also a PostSingleViewPfp used for the profile screen
          return PostSingleView(
            tabCtrl: widget.tabCtrl,
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
