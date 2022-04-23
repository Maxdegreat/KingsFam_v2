import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/cubits/cubits.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/post/post_repository.dart';
import 'package:kingsfam/screens/commuinity/screens/feed/bloc/feed_bloc.dart';
import 'package:kingsfam/screens/feed_new/feed_new.dart';
import 'package:kingsfam/widgets/widgets.dart';

class CommuinityFeedScreenArgs {
  final Church commuinity;
  CommuinityFeedScreenArgs({required this.commuinity});
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
          likedPostCubit: context.read<LikedPostCubit>()
        )..add(FeedCommuinityFetchPosts(commuinityId: args.commuinity.id!)),
        child: CommuinityFeedScreen(commuinity: args.commuinity,),
    ));
  }


  // class data 
  final Church commuinity;
  const CommuinityFeedScreen({required this.commuinity});


  @override
  _CommuinityFeedScreenState createState() => _CommuinityFeedScreenState();
}

class _CommuinityFeedScreenState extends State<CommuinityFeedScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocConsumer<FeedBloc, FeedState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        return Scaffold(
            appBar: AppBar(title: Text("${widget.commuinity.name}\'s Content", overflow: TextOverflow.fade, style: Theme.of(context).textTheme.bodyText1,),),
            body: ListView.builder(
                  itemCount: state.posts!.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Post? post = state.posts![index];
                    if (post != null)
                      return PostSingleView(post: post,);
                    return Text("Error, Post is null");


                  },
                )
            );
      },
    );
  }
}
