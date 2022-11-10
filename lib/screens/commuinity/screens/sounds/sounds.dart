/*
    This is the sounds sounds screen and i am most excited for it. what is this screen?
    This screen will show: podcasts and playlists or links to songs. if we can we will try and get 15 second clips of each song.
    also we can get links To ppls podcast streaming services too.
*/
//import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kingsfam/models/models.dart';
// import 'package:kingsfam/repositories/sounds/sound_player_repository.dart';
// import 'package:kingsfam/repositories/sounds/sounds_recorder_repository.dart';

class SoundsArgs {
  final Church commuinity;
  SoundsArgs({required this.commuinity});
}

class SoundsScreen extends StatefulWidget {
 
  final Church commuinity;
  const SoundsScreen({Key? key, required this.commuinity}) : super(key: key);

  static const String routeName = 'SoundsScreen';
  static Route route({required SoundsArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => SoundsScreen(commuinity: args.commuinity));
  }

  @override
  _SoundsScreenState createState() => _SoundsScreenState();
}

class _SoundsScreenState extends State<SoundsScreen> {
   @override
   Widget build(BuildContext context) => Scaffold();
}

// So I plan to come back to this ... maybe implement it in a different way. however this is P1 not P0
// and i need this out for the kingdom. not even for money or me so lets just make it like danggg.