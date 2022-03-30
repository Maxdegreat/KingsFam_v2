//uses the calls home cubit
import 'package:flutter/material.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/models/call_model.dart';
import 'package:kingsfam/models/church_model.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/screens/commuinity/screens/commuinity_calls/cubit/calls_home_cubit.dart';
import 'package:kingsfam/widgets/profile_image.dart';

class BuildCallScreenArgs {
  final CallModel call;
  final Church commuinity;
  BuildCallScreenArgs({required this.call, required this.commuinity});
}

class BuildCallScreen extends StatefulWidget {
  final Church commuinity;
  final CallModel call;
  const BuildCallScreen({ required this.commuinity, required this.call});

  static const String routeName = "buildCallScreen";
  static Route route({required BuildCallScreenArgs args}) {
    return PageRouteBuilder(
        settings: const RouteSettings(name: routeName),
        pageBuilder: (context, animation, secondaryAnimation) => BuildCallScreen(commuinity: args.commuinity, call: args.call));
  }

  @override
  _Build_call_screenState createState() => _Build_call_screenState();
}


// ignore: camel_case_types
class _Build_call_screenState extends State<BuildCallScreen> {
  //final TextEditingController _textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.commuinity.name} • ${widget.call.name}"),
        actions: [
          IconButton(onPressed: () async {
             final currFollowing = await context.read<CallshomeCubit>().inviteToCallReturn(); 
             inviteUsersBottomSheet(context, currFollowing);
          }, icon: Icon(Icons.person_add_rounded),)
        ],
      ),
      // will split into different widgets pending on weather camera is on or other stuff so be ready to split the work
      body: callScreenState()
      
    );
  }
  Widget callScreenState() => Container(
    child: Center(child: Text("Waiting for others to join...")),
  );


  Future<dynamic> inviteUsersBottomSheet(BuildContext context, List<Userr> currFollowing ) {
    return showModalBottomSheet(context: context, builder: (context) => StatefulBuilder(
      builder: (BuildContext context, setState) =>
       Container(
         color: Colors.black,
        height: MediaQuery.of(context).size.height / 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            children: [
              Text("Invite The Fam You Are Following To The Call Room", style: Theme.of(context).textTheme.bodyText1,),
              SizedBox(height: 15.0),
              //child 2: this should be a list view builder based on the the followers
              Expanded(
                child: ListView.builder(
                  itemCount: currFollowing.length ,
                  itemBuilder: (BuildContext context, int index) {
                    final user = currFollowing[index];
                    // Map<String, bool> isCalled = {};
                    // isCalled[user.id] = false;
                    return Column(
                      children: [
                         ListTile(leading: ProfileImage(pfpUrl: user.profileImageUrl, radius: 25,), title: Text(user.username, style: Theme.of(context).textTheme.bodyText1,), 
                          trailing: GestureDetector(onTap: ()async=> inviteUserWidget(conctext: context, call: widget.call, commuinity: widget.commuinity, user: user) , child: Icon(Icons.add))
                        ),
                        Divider( height: 5, thickness: 1, indent: 10, endIndent: 5, color: Colors.white),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Future<void> inviteUserWidget({required BuildContext conctext, required CallModel call, required Church commuinity, required Userr user}) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: Container(
                height: 250,
                width: 250,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Invite ${user.username} To ${call.name}?"),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                           // at this point we will send a message to the selected user Ids noty modle. if the accept then they will join, else we will show a snack bar that they did not join.
                           context.read<CallshomeCubit>().sendRing(call: call, invitedID: user.id, commuinity: commuinity);
                           Navigator.pop(context);
                          },
                          child: Text('YeZirr'),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.green),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Whoops... nvm", style: TextStyle(color: Colors.black),),
                          style:ElevatedButton.styleFrom(primary: Colors.white),
                        )
                      ],
                    )
                  ],
                )),
          );
        });
  }
}
