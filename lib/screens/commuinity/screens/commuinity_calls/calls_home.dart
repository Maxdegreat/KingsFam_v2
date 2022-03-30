import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/repositories.dart';
import 'package:kingsfam/screens/commuinity/screens/commuinity_calls/build_call/build_call_screen.dart';
import 'package:kingsfam/widgets/error_dialog.dart';
import 'package:rive/rive.dart';

import 'cubit/calls_home_cubit.dart';
import 'widgets/call_bottom_sheet.dart';

//args to recieve the commuinity
class CallsHomeArgs {
  final Church commuinity;
  const CallsHomeArgs({required this.commuinity});
}

//main class for the calls home screen
class CallsHome extends StatefulWidget {
  //only data is the commuinity
  final Church commuinity;
  const CallsHome({required this.commuinity});

  //routename and route
  static const String routeName = "callsHome";
  static Route route({required CallsHomeArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) => BlocProvider<CallshomeCubit>(
              create: (context) => CallshomeCubit(
                callRepository: context.read<CallRepository>(), 
                userrRepository: context.read<UserrRepository>(), 
                authBloc: context.read<AuthBloc>(), 
              ),
              child: CallsHome(commuinity: args.commuinity),
            ) // come back and add the blocprovider
        );
  }

  @override
  _CallsHomeState createState() => _CallsHomeState();
}

class _CallsHomeState extends State<CallsHome> {
  TextEditingController _txtController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.commuinity.name),
        actions: [
          TextButton(
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 8.0),
                          Center(
                              child: Text(
                            "Name For New Call Room",
                            style: TextStyle(color: Colors.green[400]),
                          )),
                          SizedBox(height: 8.0),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: TextField(
                                decoration:
                                    InputDecoration(hintText: "Enter a name"),
                                onChanged: (value) =>
                                    _txtController.text = value),
                          ),
                          SizedBox(height: 8.0),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              width: (double.infinity * .70),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.green[400]),
                                  onPressed: () {
                                    if (_txtController.value.text.length !=0) {
                                      context.read<CallshomeCubit>().onNameCallChanged(_txtController.text);
                                      context.read<CallshomeCubit>().submitNewCall(commuinity: widget.commuinity);
                                      Navigator.of(context).pop();
                                      _txtController.clear();
                                    } else {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                                //title
                                                title: const Text("mmm, err my boi"),
                                                //content
                                                content: const Text("be sure you add a name for the call room you are making"),
                                                //actions
                                                actions: [
                                                  TextButton(
                                                    child: Text("Ok",style: TextStyle(color: Colors.green[400]),),
                                                    onPressed: () =>Navigator.of(context).pop(),
                                                  )
                                                ],
                                              ));
                                    }
                                  },
                                  child: Text("Done"))),
                          )
                        ],
                      ),
                    );
                  });
            },
            child: Text("New call channel"),
            style: TextButton.styleFrom(primary: Colors.tealAccent),
          )
        ],
      ),
      body: BlocConsumer<CallshomeCubit, CallshomeState> (
        listener: (context, state) {
          if (state.status == CallsHomeStatus.error) 
            showDialog(context: context,
             builder: (context) => ErrorDialog(content: state.failure.message)
            );
        },
          builder: (context, state) {
            final curruid = context.read<AuthBloc>().state.user!.uid;
            final ctx = context.read<CallshomeCubit>();
            return SingleChildScrollView(
              child: Column(
                children: [
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                    .collection(Paths.church)
                    .doc(widget.commuinity.id)
                    .collection(Paths.call)
                    .snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.data != null) {
                        return snapshot.data!.docs.length <= 0 ?
                          Container(
                            height: 200,
                            child: RiveAnimation.asset('assets/phone_idle/phone_idle.riv')) 
                        :
                        Container(
                          //color: Colors.green,
                          height: (MediaQuery.of(context).size.height  / 1.5),
                          width: double.infinity,
                          child: ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (BuildContext context, int index) {
                              final CallModel call = CallModel.fromDoc(snapshot.data!.docs[index]);
                              return GestureDetector(
                                onLongPress: () => deleteCallWidget(call: call,conctext: context),
                                onTap: () async {
                                  var activeInCall =
                                  await ctx.isActiveInCallReturn(commuinity: widget.commuinity, call: call, currId: curruid);
                                  print("while in the calls screen curractive is ${state.currActive}");
                                 if (activeInCall)
                                   Navigator.of(context).pushNamed(BuildCallScreen.routeName, arguments: BuildCallScreenArgs(call: call, commuinity: widget.commuinity));
                                 else {
                                  ctx.inviteToCall();
                                  callBottomSheet(state: state, call: call, context: context, commuinity: widget.commuinity, currId: curruid);
                                 }
                                },
                                child: callListTile(call: call) ,
                              );
                            },
                          ),
                        );
                      } 
                      else {
                        return Container(
                          height: 200,
                          child: RiveAnimation.asset('assets/phone_idle/phone_idle.riv'));
                      }
                        
                    },
                  ),
                ],
              ),
            );
          }
      ),
    );
  }
    Future<void> deleteCallWidget({required BuildContext conctext, required CallModel call}) {
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
                    Text("Delete The Call Room ${call.name}?"),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                           if (call.allMembersIds.length == 0) {
                              Navigator.pop(context);
                            context.read<CallshomeCubit>().onDeleteCall(CommuinityId: widget.commuinity.id!, call: call);
                           } else {
                             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Call must have no users to delete")));
                             Navigator.of(context).pop();
                           }
                          },
                          child: Text('DELETE'),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.red[700]),
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
  Widget callListTile({required CallModel call}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Stack(
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(5.0)),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 10.0),
                  SizedBox(
                    width: (MediaQuery.of(context).size.width / 1.8),
                    child: Text(
                      call.name,
                      style: Theme.of(context).textTheme.bodyText1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 5.0),
                  Text("${call.allMembersIds.length.toString()}/5 In Call")
                ],
              ),
            ),
          ),
          PositionedDirectional(
              end: 0,
              child: Container(
                height: 50,
                width: 30,
                decoration: BoxDecoration(
                    color: call.hasDilled ? Colors.green[400] : Colors.red[700],
                    borderRadius: BorderRadius.circular(5.0)),
              ))
        ],
      ),
    );
  }
}
