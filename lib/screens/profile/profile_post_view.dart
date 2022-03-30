// a postview display made for the profile screen!
// this should eliminate any wierd bugs since data can be given only from one screen

import 'package:flutter/material.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/widgets/widgets.dart';

class ProfilePostViewArgs {
  final List<Post?> posts;
  final int? indexAt;
  // for likes
  final bool isLiked;
  final bool recentlyLiked;
  
  final VoidCallback onLike;
  ProfilePostViewArgs({required this.posts, this.indexAt, required this.isLiked, required this.onLike, required this.recentlyLiked});
}

class ProfilePostView extends StatelessWidget {
  final List<Post?> posts;
  final int? indexAt;

  // for likes
  final bool isLiked;
  final bool recentlyLiked;
  final VoidCallback onLike;

  ProfilePostView({Key? key, required this.posts, required this.indexAt, required this.isLiked, required this.recentlyLiked, required this.onLike})
      : super(key: key);

  static const String routeName = '/profilePostView';

  static Route route(ProfilePostViewArgs args) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => ProfilePostView(
              posts: args.posts,
              indexAt: args.indexAt,
              isLiked: args.isLiked,
              onLike: args.onLike,
              recentlyLiked: args.recentlyLiked,
            ));
  }

  //fix
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${this.posts[0]!.author.username}\'s posts")),
      body: ListView.builder(
          itemCount: posts.length,
          //itemScrollController: itemScrollController,
          itemBuilder: (context, index) {
            print("we are at $indexAt");
            final post = posts[index];
            return ColumnOfPost(posts: posts, post: post, isLiked: isLiked, onLike: onLike, recentlyLiked: recentlyLiked,);
          }),
    );
  }
}
