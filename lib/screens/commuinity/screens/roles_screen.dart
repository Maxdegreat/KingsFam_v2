import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/roles/roles_definition.dart';
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
      body: Expanded(
        flex: 1,
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

        Text("Hey Fam! Just a quick heads up on how roles work. You can assign different members of ${community.name} differet roles to help you manage the community!"),
        SizedBox(height: 7),
        Text("Be click on a role to give it certian permissions. Be carful anf only give roles to prople you think are good fits"),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: ListTile(
            leading: Text(RoleDefinitions.Owner, style: Theme.of(context).textTheme.bodyText1,),
            onTap: () {},
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: ListTile(
            leading: Text(RoleDefinitions.Admin, style: Theme.of(context).textTheme.bodyText1,),
            onTap: () {},
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: ListTile(
            leading: Text(RoleDefinitions.Elder, style: Theme.of(context).textTheme.bodyText1,),
            onTap: () {},
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: ListTile(
            leading: Text(RoleDefinitions.Member, style: Theme.of(context).textTheme.bodyText1,),
            onTap: () {},
          ),
        )
      ];
    }
}
