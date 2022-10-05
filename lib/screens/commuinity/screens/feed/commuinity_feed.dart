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

class CommuinityFeedScreenArgs {
  final Church commuinity;
  final List<Post>? passedPost;
  CommuinityFeedScreenArgs({required this.commuinity, this.passedPost});
}

class CommuinityFeedScreen extends StatefulWidget {
  // make the route name
  static const String routeName = '/CommuinityFeedScreen';
  // make the route function
  static Route route({required CommuinityFeedScreenArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => BlocProvider<FeedBloc>(
              create: (context) => FeedBloc(
                  postsRepository: context.read<PostsRepository>(),
                  authBloc: context.read<AuthBloc>(),
                  likedPostCubit: context.read<LikedPostCubit>())
                ..add(FeedCommuinityFetchPosts(passedPost: args.passedPost,
                    commuinityId: args.commuinity.id!, lastPostId: null)),
              child: CommuinityFeedScreen(
                commuinity: args.commuinity,
              ),
            ));
  }

  // class data
  final Church commuinity;

  const CommuinityFeedScreen({required this.commuinity});

  @override
  _CommuinityFeedScreenState createState() => _CommuinityFeedScreenState();
}

class _CommuinityFeedScreenState extends State<CommuinityFeedScreen> {
  // make a ad declared
  late BannerAd _bannerAd;
  // make a bool declared
  bool _isBannerAdLoaded = false;

  late Size size;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      size = MediaQuery.of(context).size;
      _ceateBanneAd();
    });
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
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
    // ignore: unused_local_variable
    Size size = MediaQuery.of(context).size;
    return BlocConsumer<FeedBloc, FeedState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        return Scaffold(
            appBar: AppBar(
              title: Text(
                "${widget.commuinity.name}\'s Content",
                overflow: TextOverflow.fade,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
            body: state.posts.length > 0
                ? SafeArea(
                    child: PageView.builder(
                        onPageChanged: (pageNum) {
                          if (pageNum == state.posts.length - 1) {
                            if (state.posts.length != 0) {
                              context.read<FeedBloc>()
                                ..add(CommunityFeedPaginatePost(
                                    commuinityId: widget.commuinity.id!));
                            }
                          }
                        },
                        itemCount: state.posts.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (state.posts[index]?.author == Post.empty.author) {
                            return PostSingleView(
                              isLiked: false,
                              post: null,
                              adWidget: AdWidget(ad: _bannerAd),
                              recentlyLiked: false,
                              onLike: () {},
                            );
                          } else {
                            final Post? post = state.posts[index];
                            if (post != null) {
                              // ignore: non_constant_identifier_names
                              final LikedPostState =
                                  context.watch<LikedPostCubit>().state;
                              final isLiked = LikedPostState.likedPostsIds
                                  .contains(post.id!);
                              final recentlyLiked = LikedPostState
                                  .recentlyLikedPostIds
                                  .contains(post.id!);

                              return PostSingleView(
                                isLiked: isLiked,
                                post: post,
                                // adWidget: AdWidget(ad: _bannerAd),
                                recentlyLiked: recentlyLiked,
                                onLike: () {
                                  if (isLiked) {
                                    context
                                        .read<LikedPostCubit>()
                                        .unLikePost(post: post);
                                  } else {
                                    context
                                        .read<LikedPostCubit>()
                                        .likePost(post: post);
                                  }
                                },
                              );
                            }
                            return SizedBox.shrink();
                          }
                        }),
                  )
                : Center(
                    child: Text("Your Community's post will show here"),
                  ));
      },
    );
  }
}
