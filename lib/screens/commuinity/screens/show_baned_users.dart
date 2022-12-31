import 'package:flutter/material.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/commuinity/bloc/commuinity_bloc.dart';
import 'package:kingsfam/widgets/widgets.dart';

class ShowBanedUsersArgs {
  final String cmId;
  final CommuinityBloc cmBloc;
  ShowBanedUsersArgs({required this.cmId, required this.cmBloc});
}

class ShowBanedUsers extends StatefulWidget {
  final String cmId;
  final CommuinityBloc cmBloc;
  const ShowBanedUsers({Key? key, required this.cmId, required this.cmBloc})
      : super(key: key);

  static const String routeName = "showBanedUsers";
  static Route route(ShowBanedUsersArgs args) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => ShowBanedUsers(
              cmId: args.cmId,
              cmBloc: args.cmBloc,
            ));
  }

  @override
  State<ShowBanedUsers> createState() => ShowBanedUsersState();
}

class ShowBanedUsersState extends State<ShowBanedUsers> {
  late ScrollController _scrollCtrl;
  List<Userr> banedUsers = [];

  grabBanedUsers() async {
    List<Userr> x = [];
    if (banedUsers.length > 0) {
      x = await ChurchRepository()
          .getBanedUsers(cmId: widget.cmId, lastDocId: banedUsers.last.id);
    } else {
      x = await ChurchRepository()
          .getBanedUsers(cmId: widget.cmId, lastDocId: null);
    }

    for (int i = 0; i < x.length; i++) {
      banedUsers.add(x[i]);
    }
    setState(() {});
  }

  void listenToScrolling() {
    if (_scrollCtrl.position.atEdge) {
      if (_scrollCtrl.position.pixels != 0.0 &&
          _scrollCtrl.position.maxScrollExtent == _scrollCtrl.position.pixels) {
        grabBanedUsers();
      }
    }
  }

  @override
  void initState() {
    grabBanedUsers();
    _scrollCtrl = ScrollController();
    _scrollCtrl.addListener(() {
      listenToScrolling();
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).iconTheme.color,
              )),
          title: Text("Baned Users",  style: Theme.of(context).textTheme.bodyText1,),
        ),
        body: Container(
            height: MediaQuery.of(context).size.height / 2,
            child: ListView.builder(
              controller: _scrollCtrl,
              itemCount: banedUsers.length,
              itemBuilder: (context, index) {
                Userr banedUser = banedUsers[index];
                return ListTile(
                    leading: ProfileImage(
                      pfpUrl: banedUser.profileImageUrl,
                      radius: 30,
                    ),
                    title: Text(banedUser.username),
                    trailing: TextButton(
                        onPressed: () {
                          widget.cmBloc
                              .unBan(cmId: widget.cmId, usr: banedUser);
                          banedUsers.remove(banedUser);
                          setState(() {});
                          snackBar(
                              snackMessage:
                                  banedUser.username + " has been unbaned.",
                              context: context);
                        },
                        child: Text("Unban")));
              },
            )));
  }
}
