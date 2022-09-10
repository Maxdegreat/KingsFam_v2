// KINGSFAM COPYRIGHTS - WE WLL SUE...

// --- SUMMARY ---
// This page is the onboarding page consisting of a pageView that will have
// several screens allowing a user to have some customization in the app
// early on!
import 'package:flutter/material.dart';

import '../models/user_model.dart';

class OnboardingNewUserPagViewScreenArgs {
  final Userr userr;
  OnboardingNewUserPagViewScreenArgs({required this.userr});
}

class OnboardingNewUserPagViewScreen extends StatefulWidget {
  const OnboardingNewUserPagViewScreen({Key? key, required this.userr}) : super(key: key);
  final Userr userr;
  static const String routeName = "/onboardingNewUserPagViewScreen";
  static Route route({required OnboardingNewUserPagViewScreenArgs args}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => OnboardingNewUserPagViewScreen(userr: args.userr,)
    );
  }
  @override
  State<OnboardingNewUserPagViewScreen> createState() => _OnboardingNewUserPagViewScreenState();
}

class _OnboardingNewUserPagViewScreenState extends State<OnboardingNewUserPagViewScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: size.height,
          width: size.width,
          child: SizedBox.shrink(),
        ),
      ),
    );
  }
}
