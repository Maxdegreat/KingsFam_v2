
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:kingsfam/blocs/auth/auth_bloc.dart';
// import 'package:kingsfam/cubits/cubits.dart';
// import 'package:kingsfam/models/models.dart';
// import 'package:kingsfam/repositories/post/post_repository.dart';
// import 'package:kingsfam/screens/commuinity/screens/feed/bloc/feed_bloc.dart';
// import 'package:kingsfam/widgets/widgets.dart';


// class FeedScreenWidget extends StatefulWidget {
//   const FeedScreenWidget({Key? key}) : super(key: key);

//   @override
//   _FeedScreenWidgetState createState() => _FeedScreenWidgetState();
// }

// class _FeedScreenWidgetState extends State<FeedScreenWidget> with AutomaticKeepAliveClientMixin  {
//   @override
//   bool get wantKeepAlive => true;
//   @override


//   Widget build(BuildContext context) {
//     super.build(context);
//     Size size = MediaQuery.of(context).size;
//     return BlocProvider<FeedBloc>(
//       create: (_) => FeedBloc(
//         authBloc: context.read<AuthBloc>(),
//         likedPostCubit: context.read<LikedPostCubit>(),
//         postsRepository: context.read<PostsRepository>(),
//       )..add(FeedFetchPosts()),
//       child: _buildBody(size: size),
//     );
//   }
// }


// class _buildBody extends StatefulWidget {
//   const _buildBody({ Key? key,  required this.size,}) : super(key: key);

//   final Size size;

//   @override
//   __buildBodyState createState() => __buildBodyState();
// }

// class __buildBodyState extends State<_buildBody> {
//     @override
//     ScrollController scrollController = ScrollController();
//   void initState() {
//         scrollController.addListener(listenToScrolling);
//     super.initState();
//   }

//   void listenToScrolling() {
//     //TODO you need to add this later make it a p1 requirment
//      if (scrollController.position.atEdge) {
//        if (scrollController.position.pixels != 0.0 && scrollController.position.maxScrollExtent == scrollController.position.pixels) {
//         //  const snackBar = SnackBar(content: Text('Yay! A SnackBar!'));
//         //  ScaffoldMessenger.of(context).showSnackBar(snackBar);
//          context.read<FeedBloc>()..add(FeedPaginatePosts());
//        }
//      }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<FeedBloc, FeedState>(
//       listener: (context, state) {
//       },
//       builder: (context, state) {
//         switch (state.status) {
//           case FeedStatus.loading:
//             return Column(
//               children: [
//                 const LinearProgressIndicator(color: Colors.red),
//               ],
//             );
//           default: 
//             return RefreshIndicator(
//               onRefresh: () async {
//                 context.read<FeedBloc>().add(FeedFetchPosts());
//                 context.read<LikedPostCubit>().clearAllLikedPosts();
//               },
//               child:  listviewsinglePost(state));
//         }
//       },
//     );
//   }

//   ListView listviewsinglePost(FeedState state) {
//     return ListView.builder(
//       shrinkWrap: false,
//       controller: scrollController ,
//       itemCount: state.posts!.length,
//       itemBuilder: (BuildContext context, int index) {
//         if (index == state.posts!.length) {
//           // TODO call paginate post 
//         }
//         final Post? post = state.posts![index];
//        final Post? posts = state.posts![index];
//         if (post != null) {
//             final LikedPostState = context.watch<LikedPostCubit>().state;
//             final isLiked = LikedPostState.likedPostsIds.contains(post.id!);
//             final recentlyLiked = LikedPostState.recentlyLikedPostIds.contains(post.id!);
//           return PostSingleView(
//             isLiked: isLiked,
//             post: post,
//             recentlyLiked: recentlyLiked,
//             onLike: () {
              
//               if (isLiked) {
//                context.read<LikedPostCubit>().unLikePost(post: post);
//              } else {
//                context.read<LikedPostCubit>().likePost(post: post);
//              }
//             },
//           );
//             }
//         return SizedBox.shrink();
//       },
//     );
//   }

// }
