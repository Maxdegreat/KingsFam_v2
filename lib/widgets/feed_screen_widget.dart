import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/cubits/cubits.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/post/post_repository.dart';
import 'package:kingsfam/screens/commuinity/screens/feed/bloc/feed_bloc.dart';
import 'package:kingsfam/widgets/fancy_list_tile.dart';
import 'package:kingsfam/widgets/widgets.dart';

class FeedScreenWidget extends StatefulWidget {
  const FeedScreenWidget({Key? key}) : super(key: key);

  @override
  _FeedScreenWidgetState createState() => _FeedScreenWidgetState();
}

class _FeedScreenWidgetState extends State<FeedScreenWidget> with AutomaticKeepAliveClientMixin  {
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
      ),
      child: _buildBody(size: size),
    );
  }
}


class _buildBody extends StatelessWidget {
  const _buildBody({
    Key? key,
    required this.size,
  }) : super(key: key);

  final Size size;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeedBloc, FeedState>(
      listener: (context, state) {
        // TODO: implement listener
      },
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
              child: ListView.builder(
                itemCount: state.posts!.length,
                itemBuilder: (BuildContext context, int index) {
                  final Post? post = state.posts![index];
                  final likedPostsState = context.watch<LikedPostCubit>().state;
                  final isLiked = likedPostsState.likedPostsIds.contains(post!.id);
                  final recentlyLiked =
                  likedPostsState.recentlyLikedPostIds.contains(post.id);
                   final ctx = context.read<LikedPostCubit>();
                  return Column(
                    children: [
                      SizedBox(height: 7.0),
                      FancyListTile(
                        username: post.author.username, 
                        imageUrl: post.author.profileImageUrl, 
                        onTap: null, 
                        isBtn: false, 
                        BR: 5, 
                        height: 16, 
                        width: 18,
                      ),
                      SizedBox(height: 5.0),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: size.height / 2),
                        child: GestureDetector(
                          onDoubleTap: () {
                            if (isLiked){
                              ctx.unLikePost(post: post);
                              print("the likes are: ${post.likes}");
                            } 
                            else 
                            ctx.likePost(post: post);
                          },
                          child: Container(
                            child: // 1 if the post.imageUrl is not null
                              post.imageUrl != null
                              ? imageDisplay(post)
                           
                              // 2 if post.videoUrl is not null
                              : post.videoUrl != null
                              ? VidoeDisplay(videoUrl: post.videoUrl!)
                              // 3 else quote is not null
                              : SizedBox.shrink() // this will be for sounds later
                            ),
                        ),
                      ),
                      SizedBox(height: 5),
                       postBottom(isLiked, recentlyLiked, post, context)
                    ],
                  );
                },
              ),
            );
        }
      },
    );
  }


  Container postBottom(bool isLiked, bool recentlyLiked, Post post, BuildContext context) {
    return Container(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //add like and comment icons / functionality
                      Container(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                              onPressed: () {},
                              icon: isLiked
                                  ? Icon(
                                      Icons.favorite,
                                      color: Colors.deepPurple[700],
                                    )
                                  : Icon(Icons.favorite)),
                          Text(recentlyLiked
                              ? "${post.likes + 1}"
                              : "${post.likes}"),
                          SizedBox(
                              width: MediaQuery.of(context).size.width / 5),
                          IconButton(
                              onPressed: () {},
                              icon: FaIcon(FontAwesomeIcons.comment)),
                          SizedBox(
                              width: MediaQuery.of(context).size.width / 5),
                          //Text(post!.date.timeAgo())
                          Text("post columns")
                        ],
                      ))
                    ]));
  }
   Padding imageDisplay(Post post) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 900),
        child: Container(
            width: double.infinity,
            child: DecoratedBox(
              child: CachedNetworkImage(imageUrl: post.imageUrl!),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.contain,
                      //if error on loading image throw here
                      image: CachedNetworkImageProvider(post.imageUrl!))),
            )),
      ),
    );
  }
}
