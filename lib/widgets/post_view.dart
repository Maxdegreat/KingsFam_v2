// import 'package:flutter/material.dart';
// import 'package:kingsfam/cubits/liked_post/liked_post_cubit.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'package:kingsfam/models/models.dart';
// import 'package:kingsfam/widgets/post_view_display.dart';
// import 'package:kingsfam/widgets/widgets.dart';

// class PostViewAgrs {
//   final List<Post?> post;
//   final bool isTitle;

//   PostViewAgrs({
//     required this.post,
//     required this.isTitle,
//   });
// }

// class PostView extends StatelessWidget {
//   static const String routeName = '/PostView';

//   static Route route(PostViewAgrs args) {
//     return MaterialPageRoute(
//         settings: const RouteSettings(name: routeName),
//         builder: (_) => PostView(
//               post: args.post,
//               isTitle: args.isTitle,
//             ));
//   }

//   final List<Post?> post; //class data
//   final bool isTitle;

//   const PostView({Key? key, required this.post, required this.isTitle}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: isTitle ? AppBar(title: Text('posts')) : AppBar(title: SizedBox.shrink(),),
//       body: CustomScrollView(
//         slivers: [
//           SliverList(
//               delegate: SliverChildBuilderDelegate((context, index) {
//             final likedPostsState = context.watch<LikedPostCubit>().state;
//             final posts = post[index];
//             final isLiked = likedPostsState.likedPostsIds.contains(posts!.id);
//             final recentlyLiked =
//                 likedPostsState.recentlyLikedPostIds.contains(posts.id);

//             //posts!.elementAt()
//             return Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     PostViewDisplay(
              
//                       recentlyLiked: recentlyLiked,
//                       post: posts,
//                       isLiked: isLiked,
//                       onLike: () {
//                         if (isLiked)
//                           context
//                               .read<LikedPostCubit>()
//                               .unLikePost(post: posts);
//                         else
//                           context.read<LikedPostCubit>().likePost(post: posts);
//                       },
//                     ),
//                   ],
//                 ));
//           }, childCount: post.length))
//         ],
//       ),
//     );
//   }
// }

// //Navigator.of(context).pushNamed(ProfileScreen.routeName,
// //arguments: ProfileScreenArgs(userId: post.author.id)),
