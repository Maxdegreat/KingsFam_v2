import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/role_modal.dart';
import 'package:kingsfam/screens/commuinity/actions.dart';
import 'package:provider/single_child_widget.dart';

class RolePermissionsArgs {
  final role;
  final String cmId;
  const RolePermissionsArgs({required this.role, required this.cmId});
}

class RolePermissions extends StatefulWidget {
  final Role role;
  final String cmId;
  const RolePermissions({Key? key, required this.role, required this.cmId}) : super(key: key);

  @override
  State<RolePermissions> createState() => _RolePermissionsState();

  static const String routeName = "RolePermissions";
  static Route route({required RolePermissionsArgs args}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) {
        return RolePermissions(
          cmId: args.cmId,
          role: args.role,
        );
      },
    );
  }
}

class _RolePermissionsState extends State<RolePermissions>
    with SingleTickerProviderStateMixin {
  late TabController _tabC;
  bool isOwner = false;
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _tabC = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {

    if (widget.role.permissions.contains("*")) {
      isOwner = true;
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.role.roleName),
          actions: [
            TextButton(onPressed: () async {
              isLoading = true;
              setState(() {});
              await FirebaseFirestore.instance.collection(Paths.communityMembers).doc(widget.cmId).collection(Paths.communityRoles).doc(widget.role.id).update(widget.role.toDoc());
              Navigator.of(context).pop();
            }, child: Text("Save"))
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TabBar(
              controller: _tabC,
              tabs: [Text("Permissions"), Text("Members")],
            ),
            Flexible(
              child: TabBarView(
                controller: _tabC,
                children: [
                  // child 1 permissions
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Container(
                        height: MediaQuery.of(context).size.height / 1.5,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                            itemCount: permissionsUi.length,
                            itemBuilder: (context, index) {
                              String action = permissionsUi[index];
                              return ListTile(
                                title: Text(action),
                                trailing: Checkbox(
                                  value: isOwner ? true : widget.role.permissions.contains(action),
                                  onChanged: (bool? value) {
                                    if (isOwner) return ;
                                    if (widget.role.permissions.contains(action)) {
                                      // remove the action and update value
                                      widget.role.permissions.remove(action);
                                    } else {
                                      widget.role.permissions.add(action);
                                    }
                                    setState(() {});
                                  },
                                ),
                              );
                            })),
                  ),
                    
                  // child 2 members
                  Container(child: Text("Show members with the role"),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  List<String> permissionsUi = [
    // child 1
    CmActions.makeRoom, CmActions.makeEvent, CmActions.accessToSettings,
    CmActions.canChangeRoles,
    CmActions.updatePrivacy, CmActions.kickAndBan,
  ];

  // if wid.role contains an Id the add a check mark on it. if not then no check mark.

}
