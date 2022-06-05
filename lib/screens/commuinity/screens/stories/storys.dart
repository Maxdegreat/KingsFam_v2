import 'package:flutter/material.dart';
import 'package:kingsfam/models/models.dart';

class StoryCommuinityArgs {
  final Church commuinity;
  StoryCommuinityArgs({required this.commuinity});
}

class StorysCommuinityScreen extends StatefulWidget {
  final Church commuinity;
  const StorysCommuinityScreen({Key? key, required this.commuinity})
      : super(key: key);

  static const String routeName = "storyCommuinityScreen";
  static Route route({required StoryCommuinityArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) =>
            StorysCommuinityScreen(commuinity: args.commuinity));
  }

  @override
  _StorysCommuinityScreenState createState() => _StorysCommuinityScreenState();
}

class _StorysCommuinityScreenState extends State<StorysCommuinityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.add_box_outlined))
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
          ],
        ));
  }
}
