import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/roles/role_types.dart';
import 'package:kingsfam/screens/commuinity/actions.dart' as cmActions;

class CommunityUpdateRoleArgsScreen {
  CommunityUpdateRoleArgsScreen({required this.role, required this.cm});
  final String role;
  final Church cm;
}

class CommunityUpdateRoleScreen extends StatefulWidget {
  CommunityUpdateRoleScreen({required this.role, required this.cm});
  final String role;
  final Church cm;
  static const String routeName = 'CommunityUpdateRoleRouteNameScreen';
  static Route route({required CommunityUpdateRoleArgsScreen args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (_) => CommunityUpdateRoleScreen(role: args.role, cm: args.cm),
            );
  }

  @override
  State<CommunityUpdateRoleScreen> createState() =>
      _CommunityUpdateRoleStateScreen();
}

class _CommunityUpdateRoleStateScreen extends State<CommunityUpdateRoleScreen> {


  @override
  Widget build(BuildContext context) {
    // e.g. newPermissions[role] = [action0, action1, action2, action4]
    Map<String, List<String>> newPermissions = {};
    newPermissions[widget.role] = [];
    return
      Scaffold(
          appBar: AppBar(
            title: Text(
              'Updating ${widget.role} : Community',
              overflow: TextOverflow.fade,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            // actions: [
            //   TextButton(
            //       onPressed: () {
            //         Navigator.of(context).pop();
            //       },
            //       child: Text("Save Changes"))
            // ],
          ),
          body: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: 
                [Text("Coming Soon")]
                ),
          ),
        );
      }
}

    // an ownwer always has all permissions. This can not be changed



