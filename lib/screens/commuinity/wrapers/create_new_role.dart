import 'package:flutter/material.dart';
import 'package:helpers/helpers/size.dart';
import 'package:kingsfam/screens/commuinity/actions.dart';

class CreateRoleArgs {
  final String cmId;
  const CreateRoleArgs({required this.cmId});
}

class CreateRole extends StatefulWidget {
  final String cmId;
  const CreateRole({Key? key, required this.cmId}) : super(key: key);

  static const String routeName = "CreateRole";
  static Route route({required CreateRoleArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: ((context) {
          return CreateRole(cmId: args.cmId);
        }));
  }

  @override
  State<CreateRole> createState() => _CreateRoleState();
}

class _CreateRoleState extends State<CreateRole> {
  // a controller for selecting the role name;
  late TextEditingController ctrl;

  // a list for selecting which actions will be in the role
  Set<String> permissions = {};

  @override
  void initState() {
    // TODO: implement
    super.initState();
    ctrl = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Create Role"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              // textForm field for a role name
              TextFormField(
                controller: ctrl,
                decoration: const InputDecoration(border: OutlineInputBorder(),),
              ),
              // listview horizontal of available actions to chose form
              SizedBox(
                height: 70,
                child: ListView.builder(
                  itemCount: permissionsUi.length,
                  itemBuilder: (context, index) {
                    String action = permissionsUi[index];
                    return GestureDetector(
                      onTap: () {
                        if (permissions.contains(action)) {
                          permissions.remove(action);
                        } else {
                          permissions.add(action);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          margin: Margin.all(5),
                          child: Text(action),
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              SizedBox(
                height: 70,
                child: ListView.builder(
                  itemCount: permissions.length,
                  itemBuilder: (context, index) {
                    String action = permissions.toList()[index];
                    return Container(
                          margin: Margin.all(5),
                          child: Text(action),
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(5.0)),
                        );
                  }),
              ),
                      
            ],
          ),
        ),
      ),
    );
  }

  // list of actons (PLEASE MAKE A STATIC VARSION OF THIS SO THAT WE DO NOT MISS ANYTHING)
  List<String> permissionsUi = [
    // child 1
    CmActions.makeRoom, CmActions.makeEvent, CmActions.accessToSettings,
    CmActions.canChangeRoles,
    CmActions.updatePrivacy, CmActions.kickAndBan,
  ];
}
