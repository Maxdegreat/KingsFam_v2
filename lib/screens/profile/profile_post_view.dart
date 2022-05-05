// a postview display made for the profile screen!
// this should eliminate any wierd bugs since data can be given only from one screen

import 'package:flutter/material.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/cubits/cubits.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/post/post_repository.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/profile/bloc/profile_bloc.dart';
import 'package:kingsfam/widgets/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

// class ProfilePostViewArgs {
//   final List<Post?> posts;
//   final int? indexAt;
//   // for likes
//   final bool isLiked;
//   final bool recentlyLiked;

//   final VoidCallback onLike;
//   ProfilePostViewArgs({required this.posts, this.indexAt, required this.isLiked, required this.onLike, required this.recentlyLiked});
// }

class ProfilePostViewArgs {
  final int startIndex;
  final List<Post?> posts;
  ProfilePostViewArgs({required this.startIndex, required this.posts});
}

class ProfilePostView extends StatefulWidget {
  final List<Post?> posts;
  final int? startingIndex;

  // // for likes
  // final bool isLiked;
  // final bool recentlyLiked;
  // final VoidCallback onLike;

  ProfilePostView({Key? key, required this.posts, required this.startingIndex});
      

  static const String routeName = '/profilePostView';

  static Route route(ProfilePostViewArgs args) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => BlocProvider<ProfileBloc>(
              create: (_) => ProfileBloc(
                authBloc: context.read<AuthBloc>(),
                likedPostCubit: context.read<LikedPostCubit>(),
                postRepository: context.read<PostsRepository>(),
                userrRepository: context.read<UserrRepository>(),
              ),
              child: ProfilePostView(
                posts: args.posts,
                startingIndex: args.startIndex,
              ),
            ));
  }

  @override
  _ProfilePostViewState createState() => _ProfilePostViewState();
}

class _ProfilePostViewState extends State<ProfilePostView> {
  
  ItemScrollController itemController = ItemScrollController();



  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>()..add(ProfileUpdatePost(post: widget.posts));
  }

  @override
  void dispose() {
    super.dispose();

  }

  


  scrollToItem()  {
    itemController.scrollTo(index: widget.startingIndex!, duration: Duration(milliseconds: 1 ));
  }

  Future scrollToHelper() async => await Future.delayed(const Duration(milliseconds: 20)).then((_) => scrollToItem());

 
  bool loaded = false;
  bool showPost = false;
  @override
  Widget build(BuildContext context) {
  Set<String?> seenIds = {};
  String? lastPostId = context.read<ProfileBloc>().state.post.length > 0 ? context.read<ProfileBloc>().state.post.last!.id : null;
  final String userId = context.read<AuthBloc>().state.user!.uid;
  void paginatePosts() => context.read<ProfileBloc>()..add(ProfilePaginatePosts(userId: userId));
  updateSeenIds() {
    var p = context.read<ProfileBloc>().state.post;
    var subList = p.sublist(p.length - 8, p.length);
    for (var sp in subList) {
      if (sp != null)
        seenIds.add(sp.id);
      lastPostId = p.last!.id;
      
    }
    
  }
    print("in the build");
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.loaded && loaded == false) {
          loaded = true;
          scrollToHelper();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: loaded ? Text("${state.post[0]!.author.username}\'s posts") : Text("posts"),
          actions: [
            IconButton(
              icon: Icon(Icons.ac_unit), 
              onPressed: () => scrollToHelper(),
            )],
          ),
          body: loaded ?  ScrollablePositionedList.builder(
              itemScrollController: itemController,
              itemCount: state.post.length,
              itemBuilder: (BuildContext context, int index) {
               

                print("we are at index: $index ()()()()()()()()()())()()()()()()()()()()()()()()");
                if (index >= (state.post.length) -1  && !seenIds.contains(lastPostId)) {
                  paginatePosts();
                  seenIds.add(lastPostId);
                  updateSeenIds();
                }
                
                final Post? post = state.post[index];
                if (post != null) {
                    final ctx = context.read<ProfileBloc>();
                    final likedPost = context.read<ProfileBloc>().state.likedPostIds;

                  return GestureDetector(
                    onDoubleTap: () {
                     if (likedPost.contains(post.id)) {
                       // todo unlike
                     } else {
                       context.read<ProfileBloc>()..add(ProfileLikePost(lkedPost: post));
                     }
                    },
                    child: PostSingleView(post: post, recentlyLiked: likedPost.contains(post.id))
                  );
                    }
                print(post);
                return Text("post is null");
              },
            ) : Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

            // this is kinda usefule bc TODO: look at how I had done dynamic posts
            //ColumnOfPost(posts: posts, post: post, isLiked: isLiked, onLike: onLike, recentlyLiked: recentlyLiked,);