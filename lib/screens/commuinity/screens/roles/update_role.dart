import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/roles/role_types.dart';
import 'package:kingsfam/screens/commuinity/actions.dart' as cmActions;
import 'package:kingsfam/screens/commuinity/screens/roles/cubit/role_cubit.dart';

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
        builder: (_) => BlocProvider<RoleCubit>(
              create: (context) => RoleCubit(),
              child: CommunityUpdateRoleScreen(role: args.role, cm: args.cm),
            ));
  }

  @override
  State<CommunityUpdateRoleScreen> createState() =>
      _CommunityUpdateRoleStateScreen();
}

class _CommunityUpdateRoleStateScreen extends State<CommunityUpdateRoleScreen> {
  @override
  void initState() {
    _initRoleCubit();
    super.initState();
  }

  _initRoleCubit() async {
    await context.read<RoleCubit>().getPermissions(doc: widget.cm.id!);
    context.read<RoleCubit>().onSetCommunity(community: widget.cm);
  }

  @override
  Widget build(BuildContext context) {
    // e.g. newPermissions[role] = [action0, action1, action2, action4]
    Map<String, List<String>> newPermissions = {};
    newPermissions[widget.role] = [];
    return BlocConsumer<RoleCubit, RoleState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        return Scaffold(
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
                cmActions.Actions.communityActions.map((a) {
                  context.read<RoleCubit>().onPopulateIsChecked(widget.role);
                  bool isChecked = widget.role == Roles.Owner ? true :  state.isChecked.length > 0 ?
                      context.read<RoleCubit>().state.isChecked[a]! : false;
                    
                  return ListTile(
                    title: Text(
                      a,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    trailing: isChecked ? Icon(Icons.check_box_outlined) : Icon(Icons.check_box_outline_blank_sharp),
                    onTap: () {}//=> context.read<RoleCubit>().onChanged(widget.role, a),
                  );
                }).toList()
                ),
          ),
        );
      },
    );
  }
}

    // an ownwer always has all permissions. This can not be changed



