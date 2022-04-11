// todo:
// I need a list of post. the post will contain data on user and commuinity because it has references
// 
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kingsfam/models/models.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:kingsfam/widgets/commuinity_pf_image.dart';

class FeedNewScreenArgs {
  final List<Post?> posts;
  FeedNewScreenArgs({required this.posts});
}

class FeedNewScreen extends StatefulWidget {
  
  
  static const String routeName = '/feedNewScreen';
  static Route route({required FeedNewScreenArgs args}) {
    return MaterialPageRoute(
     settings: const RouteSettings(name: routeName),
      builder: (context) => FeedNewScreen(posts: args.posts ),
    );
  }



  const FeedNewScreen({ Key? key, required this.posts }) : super(key: key);
  final List<Post?> posts;


  @override
  State<FeedNewScreen> createState() => FeedNewState();
}

class FeedNewState extends State<FeedNewScreen> {
  @override
  Widget build(BuildContext context) { 
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: Text("${widget.posts[0]!.author.username}\s posts"),),
    body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: MediaQuery.of(context).size.height / 1.5,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              mainAxisExtent: 320.0,
            ),
            itemCount: widget.posts.length,
            itemBuilder: (BuildContext context, int index) {
              Post? post = widget.posts[index];
              return Column(
                children: [
                  Container(
                    height: 240, width: 300, 
                    decoration: BoxDecoration(
                      color: Colors.green,
                      image: DecorationImage(image: CachedNetworkImageProvider(post!.imageUrl!), fit: BoxFit.cover),
                      borderRadius: BorderRadius.circular(18)
                    ),
                  ),
                  SizedBox(height: 10),
                  ListTile(leading: commuinity_pf_img(post.author.profileImageUrl, 40, 40), title: Text(post.author.username, style: Theme.of(context).textTheme.bodyText1,),)
                ],
              );
            },

          ),
        )
      ],
    ),
  );}
}