// todo:
// I need a list of post. the post will contain data on user and commuinity because it has references
//
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/cubits/cubits.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/post/post_repository.dart';
import 'package:kingsfam/screens/feed_new/bloc/feedpersonal_bloc.dart';
import 'package:kingsfam/widgets/commuinity_pf_image.dart';
import 'package:kingsfam/widgets/profile_image.dart';

class FeedNewScreenArgs {
  final int startIndex;
  final List<Post?> posts;
  FeedNewScreenArgs({required this.startIndex, required this.posts});
}

class FeedNewScreen extends StatefulWidget {
  static const String routeName = '/feedNewScreen';
  static Route route({required FeedNewScreenArgs args}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => BlocProvider<FeedpersonalBloc>(
        create: (_) => FeedpersonalBloc(
          likedPostCubit: context.read<LikedPostCubit>(),
          authBloc: context.read<AuthBloc>(),
          postsRepository: context.read<PostsRepository>(),
        )..add(FeedLoadPostsInit(posts: args.posts, currIdx: args.startIndex)),
        child:FeedNewScreen(startIndex: args.startIndex,)
      ),
    );
  }

  const FeedNewScreen(
      {Key? key, required this.startIndex});

  final int startIndex;

  @override
  State<FeedNewScreen> createState() => FeedNewState();
}

class FeedNewState extends State<FeedNewScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocConsumer<FeedpersonalBloc, FeedpersonalState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        return Scaffold(
            appBar: AppBar(
              title: Text("..."),
            ),
            body: ListView.builder(
              itemCount: state.posts.length,
              itemBuilder: (BuildContext context, int index) {
                final Post? post = state.posts[index];
                return PostSingleView(post: post!,);
              },
            ));
      },
    );
  }
}

class PostSingleView extends StatelessWidget {
  const PostSingleView({required this.post});
  final Post post;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        userPicAndName(name: post.author.username, imgurl: post.author.profileImageUrl),
      ],
    );
  }

  Widget userPicAndName({required String name, required String imgurl}) {
    return Row(
      children: [
        ProfileImage(radius: 25, pfpUrl: imgurl),
        SizedBox(width: 10.0),
        Text(name, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),)
      ],
    );
  }

}
