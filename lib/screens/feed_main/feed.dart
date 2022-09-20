import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/cubits/cubits.dart';
import 'package:kingsfam/helpers/ad_helper.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/post/post_repository.dart';
import 'package:kingsfam/screens/commuinity/screens/feed/bloc/feed_bloc.dart';
import 'package:kingsfam/widgets/widgets.dart';

class FeedScreenWidget extends StatefulWidget {
  const FeedScreenWidget({Key? key, required this.tabController})
      : super(key: key);
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
  // make a ad declared
  late BannerAd _bannerAd;
  // make a bool declared
  bool _isBannerAdLoaded = false;
  late Size size;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      size = MediaQuery.of(context).size;
      _ceateBanneAd();
    });
    super.initState();
  }

  void _ceateBanneAd() {
    _bannerAd = BannerAd(
        size: AdSize.getLandscapeInlineAdaptiveBannerAdSize(size.width.toInt()),
        adUnitId: AdHelper.bannerAdUnitId,
        listener: BannerAdListener(onAdLoaded: (_) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        }, onAdFailedToLoad: (ad, error) {
          ad.dispose();
          log("!!!!!!!!!!!!!!!!!! - bottom Ad Error In Cm Feed - !!!!!!!!!!!!!!!!!!!!!!!!!");
          log("chatsScreen ad error: ${error.toString()}");
          log("!!!!!!!!!!!!!!!!!! - bottom Ad Error In Cm Feed - !!!!!!!!!!!!!!!!!!!!!!!!!");
        }),
        request: AdRequest());
    _bannerAd.load();
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
                    ? pageViewForPost(state) // listviewsinglePost(state)
                    : Center(
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              "Follow Some Fam With Post First To Have A Feed"),
                          IconButton(
                            icon: Icon(Icons.refresh),
                            onPressed: () =>
                                context.read<FeedBloc>().add(FeedFetchPosts()),
                          ),
                        ],
                      )));
        }
      },
    );
  }

  pageViewForPost(FeedState state) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      onPageChanged: (pageNum) {
        if (pageNum == state.posts.length - 1) {
          context.read<FeedBloc>()..add(FeedPaginatePosts());
        }
      },
      itemCount: state.posts.length,
      itemBuilder: (context, index) {
        if (state.posts[index]?.author == Post.empty.author) {
          return PostSingleView(post: null, isLiked: false, onLike: (){}, adWidget: AdWidget(ad: _bannerAd), recentlyLiked: true,);
        } else {
                    final Post? post = state.posts[index];
          if (post != null) {
            // ignore: non_constant_identifier_names
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
        }
      },
    );
  }
}

