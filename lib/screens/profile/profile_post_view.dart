// a postview display made for the profile screen!
// this should eliminate any wierd bugs since data can be given only from one screen

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/cubits/cubits.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/prayer_repo/prayer_repo.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/profile/bloc/profile_bloc.dart';
import 'package:kingsfam/widgets/post_widgets/post_img_screen.dart';
import 'package:kingsfam/widgets/post_widgets/post_vid_screen.dart';
import 'package:kingsfam/widgets/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../widgets/post_single_view_pfp.dart';

class ProfilePostViewArgs {
  final int startIndex;
  final List<Post?> posts;
  final bool? isFromPfpScreen;
  final String? currUsrId;
  ProfilePostViewArgs(
      {required this.startIndex,
      required this.posts,
      required this.currUsrId,
      this.isFromPfpScreen = false});
}

class ProfilePostView extends StatefulWidget {
  final List<Post?> posts;
  final int? startingIndex;
  final String? currUsrId;

  // // for likes
  // final bool isLiked;
  // final bool recentlyLiked;
  // final VoidCallback onLike;

  ProfilePostView(
      {Key? key,
      required this.posts,
      required this.startingIndex,
      required this.currUsrId});

  static const String routeName = '/profilePostView';

  static Route route(ProfilePostViewArgs args) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => BlocProvider<ProfileBloc>(
              create: (_) => ProfileBloc(
                prayerRepo: context.read<PrayerRepo>(),
                chatRepository: context.read<ChatRepository>(),
                churchRepository: context.read<ChurchRepository>(),
                authBloc: context.read<AuthBloc>(),
                likedPostCubit: context.read<LikedPostCubit>(),
                postRepository: context.read<PostsRepository>(),
                userrRepository: context.read<UserrRepository>(),
              )..add(ProfileUpdatePost(post: args.posts)),
              child: ProfilePostView(
                posts: args.posts,
                startingIndex: args.startIndex,
                currUsrId: args.currUsrId,
              ),
            ));
  }

  @override
  _ProfilePostViewState createState() => _ProfilePostViewState();
}

class _ProfilePostViewState extends State<ProfilePostView> {
  ItemScrollController itemController = ItemScrollController();
  late PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: widget.startingIndex!);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool loaded = false;
  bool showPost = false;
  @override
  Widget build(BuildContext context) {
    Set<String?> seenIds = {};
    String? lastPostId = context.read<ProfileBloc>().state.post.length > 0
        ? context.read<ProfileBloc>().state.post.last!.id
        : null;

    final String userId = context.read<AuthBloc>().state.user!.uid;
    void paginatePosts() {
      log("this is most def a not a snack bar");
      snackBar(snackMessage: "This is a snackbar", context: context);
      context.read<ProfileBloc>()..add(ProfilePaginatePosts(userId: userId));
    }

    updateSeenIds() {
      var p = context.read<ProfileBloc>().state.post;
      var subList = p.sublist(p.length - 8, p.length);
      for (var sp in subList) {
        if (sp != null) seenIds.add(sp.id);
        lastPostId = p.last!.id;
      }
    }

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.loaded && loaded == false) {
          loaded = true;
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: loaded
                ? Text("${state.post[0]!.author.username}\'s posts")
                : Text("posts"),
            actions: [],
          ),
          body: loaded
              ? PageView.builder(
                  scrollDirection: Axis.vertical,
                  controller: _pageController,
                  itemCount: state.post.length,
                  onPageChanged: (pageNum) {
                    if (pageNum == state.post.length - 1) {
                      context.read<ProfileBloc>()
                        ..add(ProfilePaginatePosts(userId: widget.currUsrId!));
                    }
                  },
                  itemBuilder: (context, index) {
                    final Post? post = state.post[index];
                    if (post != null) {
                      if (post.imageUrl != null) {
                        return ImgPost1_1(post: post);
                      } else if (post.videoUrl != null) {
                        return PostFullVideoView16_9(post: post);
                      } else 
                        return SizedBox.shrink();
                    }
                    return Text("post is null");
                  },
                )
              : Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

