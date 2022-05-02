// todo:
// I need a list of post. the post will contain data on user and commuinity because it has references
//

import 'package:flutter/material.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/screens/commuinity/screens/feed/bloc/feed_bloc.dart';
import 'package:kingsfam/screens/edit_profile/cubit/edit_profile_cubit.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:kingsfam/cubits/cubits.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/post/post_repository.dart';
import 'package:kingsfam/screens/feed_new/bloc/feedpersonal_bloc.dart';
import 'package:kingsfam/widgets/widgets.dart';

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

  const FeedNewScreen({Key? key, required this.startIndex});

  final int startIndex;

  @override
  State<FeedNewScreen> createState() => FeedNewState();
}


class FeedNewState extends State<FeedNewScreen> {

  ItemScrollController itemController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    scrollToHelper();
  }
  
  Future scrollToItem() async {
    itemController.jumpTo(index: widget.startIndex);
  }
  Future scrollToHelper() async {
    Future.delayed(const Duration(milliseconds: 85)).then((_) => scrollToItem());
  }
  //bool loaded = false;


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocConsumer<FeedpersonalBloc, FeedpersonalState>(
      listener: (context, state) {

      },
      builder: (context, state) {

        return Scaffold(
            appBar: AppBar(
              title: Text("Fam's Posts"),
              //actions: [TextButton(onPressed: () => print(state.jumpTo), child: Text("Scroll"))],
            ),
            body: ScrollablePositionedList.builder(
              itemScrollController: itemController,
              itemCount: state.posts.length,
              itemBuilder: (BuildContext context, int index) {
               
                // if (loaded != true) {
                //   loaded = true;
                //   scrollToHelper();
                // }
                if (index == state.posts.length) {
                  // TODO call paginate post 
                }
                final Post? post = state.posts[index];
                if (post != null)
                  return PostSingleView(post: post,);
                print(post);
                return Text("post is null");
              },
            ));
      },
    );
  }
}


