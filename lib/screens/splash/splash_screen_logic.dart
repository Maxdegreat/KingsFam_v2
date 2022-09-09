import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';


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
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prevState, state) => prevState.status != state.status, // Prevent listener from triggering if status did not change
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenicated) {
          //go to login Screen
          Navigator.pushNamed(context, LoginScreen.routeName);
        } else if (state.status == AuthStatus.authenticated) {
          if (state.isUserNew == true) {
            log("Working intergration of new user checking +=================================");
            log(state.isUserNew.toString());
          } else {
            log("SO NOT A WORKING MODAL???? -=================================");
            log(state.isUserNew.toString());
          }
          //go to Nav screen
          Navigator.pushNamed(context, NavScreen.routeName);
        } 
      },
      child: Scaffold(
        body: Container(height: double.infinity, width: double.infinity, color:  Colors.red,)
    ));
  }
}
