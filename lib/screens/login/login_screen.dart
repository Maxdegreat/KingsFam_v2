import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kingsfam/repositories/auth/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/widgets/videos/asset_video.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';


class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  static Route route() {
    return PageRouteBuilder(
        settings: const RouteSettings(name: routeName),
        transitionDuration: const Duration(seconds: 0),
        pageBuilder: (_, __, ___) =>
            LoginScreen()); //buildcontext, animaitons ;
  }

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late VideoPlayerController vc;
  @override
  void initState() {
    vc = VideoPlayerController.asset('assets/animations/kingsfam_logo_animated.mp4', videoPlayerOptions: VideoPlayerOptions( mixWithOthers: true))
    ..addListener(() => setState(() {}))
      ..setLooping(true) // -------------------------------- SET PERKED LOOPING TO TRUE
      ..initialize().then((_) {
        vc.play();
        vc.setVolume(0);
      });
    super.initState();
  }

  @override
  void dispose() {
    vc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SafeArea(
            child: Column(
          children: [
            Spacer(),
            Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Column(
                          children: [
                            Text('Welcome To ',
                                style: Theme.of(context).textTheme.headline2),
                            Text('KING\'S FAM',
                                style: Theme.of(context).textTheme.headline3)
                          ],
                        )),
                        SizedBox(height: 10),
                        Container(
                          height: 250,
                          width: 250,
                          child: VisibilityDetector(
                            key: ObjectKey(vc),
                            onVisibilityChanged: (vis) {
                              vis.visibleFraction > 0 ? vc.play() : vc.pause();
                            },
                            child: AssetVideoPlayer(controller: vc, height: 200, width: 250)),
                        )
                  ],
                )),
            //Spacer(),
            SizedBox(height: 17),
            Center(child: Text("Find Communities And Make Christian Friendships :)",
            textAlign: TextAlign.center,)),
            SizedBox(height: 15),
            Container(
              width: size.width / 1.2,
              child: TextButton.icon(
                onPressed: () =>
                    context.read<AuthRepository>().signInWithGoogle(),
                icon: FaIcon(
                  FontAwesomeIcons.google,
                  color: Colors.amber[400],
                ),
                label: Text('Continue With Google',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    )),
                style: TextButton.styleFrom(backgroundColor: Colors.white),
              ),
            ),
            // ------------------------------------------------------ manuel sign in methods
            //  SizedBox(height: 20),
            //  Container(
              //  width: size.width / 1.2,
              //  child: TextButton(
                  //  onPressed: () {
                    // 
                    //  Navigator.of(context).pushNamed(SignupFormScreen.routeName);
                  //  },
                  //  child: Text('Sign Up',
                      //  style: Theme.of(context).textTheme.bodyText1),
                  //  style: TextButton.styleFrom(backgroundColor: Colors.amber[400])),
            //  ),
            //  SizedBox(height: 20.0),
              Container(
                width: size.width / 1.2,
                child: TextButton(
                    onPressed: () {

                      Navigator.of(context).pushNamed(LoginFormScren.routeName);
                    },
                    child: Text('Login In',
                        style: Theme.of(context).textTheme.bodyText1),
                    style: TextButton.styleFrom(backgroundColor: Colors.amber[400])),
              ),
            // ----------------------------------------------------------------------------------------------
            SizedBox(height: 20),
            Platform.isIOS ? Container(
                width: size.width / 1.2,
                child: TextButton.icon(
                  onPressed: () => context.read<AuthRepository>().signInWithApple(context),
                  icon: Icon(Icons.apple, color: Colors.amber,),
                  label: Text("Sign In With Apple", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700)),
                  style: TextButton.styleFrom(backgroundColor: Colors.white),
                )) : SizedBox.shrink(),
                Spacer()
          ],
        )),
      ),
    );
  }
}
