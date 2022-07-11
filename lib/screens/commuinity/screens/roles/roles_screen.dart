import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/roles/role_types.dart';
import 'package:kingsfam/screens/commuinity/screens/roles/update_role.dart';
class RoleScreenArgs {
  RoleScreenArgs({required Church this.community});
  final Church community;
}

class RolesScreen extends StatelessWidget {
  const RolesScreen(Church this.community);
  final Church community;
  static const String routeName = "roleScreen";
  static Route route ({required RoleScreenArgs args}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => RolesScreen(args.community)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          this.community.name,
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _roleListTile(this.community, context),
        ),
      ),
    );
  }
    List<Widget> _roleListTile(Church cm, BuildContext context) {

      return [

        Text("Hey Fam! Just a quick heads up the ability to update roles is currently not available. Atm you can view the power of each role"),
        SizedBox(height: 7),
        Text("To promote or demote a member go to the participants view and click the 3 dots. you must be a admin or owner"),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: ListTile(
            leading: Text(Roles.Owner, style: Theme.of(context).textTheme.bodyText1,),
            onTap: () => Navigator.of(context).pushNamed(CommunityUpdateRoleScreen.routeName, arguments: CommunityUpdateRoleArgsScreen(role: Roles.Owner, cm: this.community)),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: ListTile(
            leading: Text(Roles.Admin, style: Theme.of(context).textTheme.bodyText1,),
            onTap: () => Navigator.of(context).pushNamed(CommunityUpdateRoleScreen.routeName, arguments: CommunityUpdateRoleArgsScreen(role: Roles.Admin, cm: this.community)),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: ListTile(
            leading: Text(Roles.Elder, style: Theme.of(context).textTheme.bodyText1,),
            onTap: () => Navigator.of(context).pushNamed(CommunityUpdateRoleScreen.routeName, arguments: CommunityUpdateRoleArgsScreen(role: Roles.Elder, cm: this.community)),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: ListTile(
            leading: Text(Roles.Member, style: Theme.of(context).textTheme.bodyText1,),
            onTap: () => Navigator.of(context).pushNamed(CommunityUpdateRoleScreen.routeName, arguments: CommunityUpdateRoleArgsScreen(role: Roles.Member, cm: this.community)),
          ),
        )
      ];
    }
}
