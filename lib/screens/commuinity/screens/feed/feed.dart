import 'package:flutter/material.dart';
import 'package:kingsfam/widgets/column_of_posts.dart';

class CommuinityFeedScreen extends StatefulWidget {
  // make the route name
  static const String routeName = '/CommuinityFeedScreen';
  // make the route function
  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => CommuinityFeedScreen(),
    );
  }
  const CommuinityFeedScreen({ Key? key }) : super(key: key);

  @override
  _CommuinityFeedScreenState createState() => _CommuinityFeedScreenState();
}

class _CommuinityFeedScreenState extends State<CommuinityFeedScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(),
      body: Container()//ColumnOfPost(posts: posts, post: post, isLiked: isLiked, onLike: onLike, recentlyLiked: recentlyLiked),
    );
  }
}