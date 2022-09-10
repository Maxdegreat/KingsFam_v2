import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';

import '../screens.dart';

class SplashScreen extends StatelessWidget {
  static const String routeName = '/splash';

  static Route route() {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (_) => SplashScreen());
  }

//implement auth bloc
// wrap scaffold in a bloc listener
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (prevState, state) => prevState.status != state.status, // Prevent listener from triggering if status did not change
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenicated) {
          //go to login Screen
          Navigator.pushNamed(context, LoginScreen.routeName);
        } else if (state.status == AuthStatus.authenticated) {
          // if (state.user != null && state.userr!.username[0] == "!") {
          //   log("Working intergration of new user checking +=================================");
          //   log(state.userr!.username);
          // } else {
          //   log("SO NOT A WORKING MODAL???? -=================================");
          //   log(state.userr.toString());
          // }
          //go to Nav screen
          Navigator.pushNamed(context, NavScreen.routeName);
        } 
      },
      builder: (context, state) {
        return Scaffold(
            body: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.red,
        ));
      },
    );
  }
}
