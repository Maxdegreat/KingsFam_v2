// todo:
// I need a list of post. the post will contain data on user and commuinity because it has references
//

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/global_keys.dart';
import 'package:kingsfam/cubits/buid_cubit/buid_cubit.dart';
import 'package:kingsfam/enums/bottom_nav_items.dart';
import 'package:kingsfam/helpers/ad_helper.dart';
import 'package:kingsfam/screens/commuinity/screens/feed/bloc/feed_bloc.dart';

import 'package:kingsfam/cubits/cubits.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/post/post_repository.dart';
import 'package:kingsfam/screens/nav/cubit/bottomnavbar_cubit.dart';
import 'package:kingsfam/widgets/widgets.dart';

class FeedNewScreen extends StatefulWidget {
  static const String routeName = '/feedNewScreen';
  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => BlocProvider<FeedBloc>(
          create: (_) => FeedBloc(
              postsRepository: context.read<PostsRepository>(),
              authBloc: context.read<AuthBloc>(),
              likedPostCubit: context.read<LikedPostCubit>(),
              buidCubit: context.read<BuidCubit>()),
          child: FeedNewScreen()),
    );
  }

  const FeedNewScreen();

  @override
  State<FeedNewScreen> createState() => FeedNewState();
}

class FeedNewState extends State<FeedNewScreen> {

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

  bool hasSeen = false;

  void _initFeedBloc() {
    context.read<FeedBloc>()..add(FeedFetchPosts(context: context));
    log("called init from feed p screen");
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
        if (!hasSeen && context.read<BottomnavbarCubit>().state.selectedItem == BottomNavItem.feed) {
          _initFeedBloc();
          hasSeen = true;
        }

        return Scaffold(
            backgroundColor: Colors.black,
            body: state.posts.length > 0
                ? SafeArea(
                    child: Stack(
                      children: [

                          
                          PageView.builder(
                            scrollDirection: Axis.vertical,
                            onPageChanged: (pageNum) {
                              _paginate(pageNum, state);
                    
                              // load next ad
                              // _loadNextAd(pageNum, state);
                              // load next vid
                            },
                            itemCount: state.posts.length,
                            itemBuilder: (BuildContext context, int index) {
                              // if next post is empty then display an ad (empty post)
                              // are added in bloc programatically as placeholders for ads
                              if (state.posts[index]!.author == Userr.empty) {
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
                                  return state.postContainer[index]!;
                                }
                                return SizedBox.shrink();
                              }
                            }),
                          Positioned(child: IconButton(onPressed: ()=> scaffoldKey.currentState!.openDrawer(), icon: Icon(Icons.menu))),
                          Positioned(top: 0, right: 0, child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Text("Discover", style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.white),),
                                Icon(Icons.map_sharp)
                              ],
                            ),
                          )),
                          
                          ],
                    ),
                  )
                : Center(
                    child: Text("Loading ..."),
                  ));
      },
    );
  }

  void _paginate(pageNum, state) {
    if (pageNum == state.posts.length - 1) {
      if (state.posts.length != 0) {
        context.read<FeedBloc>()..add(FeedPaginatePosts());
      }
    }
  }

  void _loadNextAd(pageNum, state) {
    if (state.posts.length > pageNum + 1 || state.posts.length == pageNum + 1) {
      if (state.posts[pageNum + 1]!.author == Post.empty.author) {
        _ceateBanneAd();
      }
    }
  }
}
