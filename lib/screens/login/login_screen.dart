import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kingsfam/repositories/auth/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/screens/screens.dart';
import 'package:kingsfam/screens/snack_time/cm_theme_list.dart';
// import 'package:kingsfam/widgets/videos/asset_video.dart';
// import 'package:video_player/video_player.dart';
// import 'package:visibility_detector/visibility_detector.dart';

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
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Text('Welcome To 👑',
                    style: Theme.of(context).textTheme.headline2!),
                Text('KING\'S FAM',
                    style: Theme.of(context).textTheme.headline3),
                SizedBox(height: 15),
                Text(
                  "Christian Communities For This Generation!",
                  style: Theme.of(context)
                      .textTheme
                      .caption!
                      .copyWith(fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 25),
                Container(
                    width: size.width > 700 ? size.width / 7 : size.width / 1.2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.inversePrimary),
                      child: Text("Continue With Google",
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary)),
                      onPressed: () =>
                          context.read<AuthRepository>().signInWithGoogle(),
                    )),
                SizedBox(height: 5),
                if (!kIsWeb) ...[
                  // ------------------------------------------------------ manuel sign in methods

                  Container(
                      width:
                          size.width > 700 ? size.width / 7 : size.width / 1.2,
                      child: ElevatedButton(
                        onPressed: () => context
                            .read<AuthRepository>()
                            .signInWithApple(context),
                        child: Text("Sign In With Apple",
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.inversePrimary),
                      )),
                ],
                const SizedBox(height: 40),
                Container(
                  width: size.width / 1.2,
                  child: Text(
                    "not forsaking the assembling of ourselves together, as is the manner of some, but exhorting one another, and so much the more as you see the Day approaching. Hebrews 10:25",
                    style: Theme.of(context).textTheme.caption,
                    textAlign: TextAlign.start,
                  ),
                  
                )
              ],
            ),
          ),
        )),
      ),
    );
  }
}
