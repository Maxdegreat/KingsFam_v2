import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kingsfam/repositories/auth/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/screens/screens.dart';


class LoginScreen extends StatelessWidget {
  static const String routeName = '/login';
  static Route route() {
    return PageRouteBuilder(
        settings: const RouteSettings(name: routeName),
        transitionDuration: const Duration(seconds: 0),
        pageBuilder: (_, __, ___) =>
            LoginScreen()); //buildcontext, animaitons ;
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
                alignment: Alignment.centerLeft,
                child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 35.0),
                    child: Column(
                      children: [
                        Text('Welcome To ',
                            style: Theme.of(context).textTheme.headline2),
                        Text('KING\'S FAM',
                            style: Theme.of(context).textTheme.headline1)
                      ],
                    ))),
            Spacer(),
            SizedBox(height: 20),
            Container(
              width: size.width / 1.2,
              child: TextButton.icon(
                onPressed: () =>
                    context.read<AuthRepository>().signInWithGoogle(),
                icon: FaIcon(
                  FontAwesomeIcons.google,
                  color: Colors.red[400],
                ),
                label: Text('Continue With Google',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    )),
                style: TextButton.styleFrom(backgroundColor: Colors.white),
              ),
            ),
            // ------------------------------------------------------ manuel sign in methods
            // SizedBox(height: 20),
            // Container(
            //   width: size.width / 1.2,
            //   child: TextButton(
            //       onPressed: () {
            //         //push route to sign up screen
            //         Navigator.of(context).pushNamed(SignupFormScreen.routeName);
            //       },
            //       child: Text('Sign Up',
            //           style: Theme.of(context).textTheme.bodyText1),
            //       style: TextButton.styleFrom(backgroundColor: Colors.red[400])),
            // ),
            // SizedBox(height: 20.0),
            // Container(
            //   width: size.width / 1.2,
            //   child: TextButton(
            //       onPressed: () {
            //         //push named route to login screen
            //         Navigator.of(context).pushNamed(LoginFormScren.routeName);
            //       },
            //       child: Text('Login In',
            //           style: Theme.of(context).textTheme.bodyText1),
            //       style: TextButton.styleFrom(backgroundColor: Colors.red[400])),
            // ),
            // ----------------------------------------------------------------------------------------------
            SizedBox(height: 20),
            Platform.isIOS ? Container(
                width: size.width / 1.2,
                child: TextButton.icon(
                  onPressed: () => context.read<AuthRepository>().signInWithApple(context),
                  icon: Icon(Icons.apple),
                  label: Text("Sign In With Apple"),
                  style: TextButton.styleFrom(backgroundColor: Colors.white),
                )) : SizedBox.shrink(),
                Spacer()
          ],
        )),
      ),
    );
  }
}
