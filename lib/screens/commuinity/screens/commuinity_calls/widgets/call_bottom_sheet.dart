import 'package:flutter/material.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/screens/commuinity/screens/commuinity_calls/build_call/build_call_screen.dart';
import 'package:kingsfam/screens/commuinity/screens/commuinity_calls/cubit/calls_home_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/widgets/widgets.dart';
Future<dynamic> callBottomSheet({required CallModel call, required CallshomeState state, required BuildContext context, required Church commuinity, required String currId}) async {
  notActiveCallBottomSheet(call, state, context, currId, commuinity);
}

 Future<dynamic> notActiveCallBottomSheet ( CallModel call,  CallshomeState state, BuildContext context, String currId, Church commuinity) {
   return showModalBottomSheet(
     context: context, 
     builder: (context) {
       return StatefulBuilder(
         builder: (BuildContext context, setState) {
           return Stack(
         children: [
           Container(
             color: Colors.black,
             height: (200),
             child: Column(
               children: [
                 Container(
                   height: 50,
                   color: Colors.grey[900],
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.start,
                     children: [
                       SizedBox(width: 10),
                       Icon(Icons.volume_up),
                       SizedBox(width: 15),
                       SizedBox(
                         width: (MediaQuery.of(context).size.width / 1.8),
                         child: Text(
                         call.name,
                         style: Theme.of(context).textTheme.bodyText1,
                         overflow: TextOverflow.ellipsis,
                         )
                       ),
                        GestureDetector(
                         onTap: () => showModalBottomSheet(
                         context: context,
                         builder: (BuildContext context) {
                         BorderRadius.circular(20.0);
                         return Container(
                           height:
                           MediaQuery.of(context).size.height *.80,
                           child: SingleChildScrollView(
                             child: addPersonMethod(context, state)
                           ),
                         );
                       }),
                       child: Icon(Icons.person_add))
                     ],
                   ),
                 ),
                 Padding(
                   padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                   child: Container(
                     width: 300,
                     child: ElevatedButton(
                       onPressed: () async {
                         print("joined room");
                         context.read<CallshomeCubit>().joinCall(currId: currId, call: call, commuinity: commuinity);
                         Navigator.of(context).pop();
                           setState(() {
                             Navigator.of(context).pushNamed(BuildCallScreen.routeName, arguments: BuildCallScreenArgs(call: call, commuinity: commuinity));
                           });
                         
                         print("outa if statment");
                       }, child: Text("Join Room w/ Aduio")
                     ),
                   ),
                 ),
               ],
             ),
           )
         ],
       );
         },
       );
     }
   );
 }

// Future<dynamic> activeInCall(CallModel call, CallshomeState state, BuildContext context, String currId) async {
//   return showModalBottomSheet(
//         context: context,
//         builder: (BuildContext context) {
//           return Container(
//             height: MediaQuery.of(context).size.height,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 //child 1
//                 Container(
//                   color: Colors.grey[900],
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       SizedBox(width: 10),
//                       Icon(Icons.volume_up),
//                       SizedBox(width: 15),
//                       SizedBox(
//                           width: MediaQuery.of(context).size.width / 2,
//                           child: Text(
//                             call.name,
//                             style: Theme.of(context).textTheme.bodyText1,
//                             overflow: TextOverflow.ellipsis,
//                           )),
//                       IconButton(
//                         onPressed: () => _inviteToCall(call: call,id: currId, state: state, context: context),
//                         icon: Icon(Icons.person_add)
//                       ),
//                     ],
//                   ),
//                 ),
//                 //child 2
//                 Container(
//                   width: double.infinity,
//                   height: (MediaQuery.of(context).size.height / 2.5),
//                   //color: Colors.green,
//                   child: ListView.builder(
//                     itemCount: call.allMembersIds.length,
//                     itemBuilder: (BuildContext context, int index) {
//                       final user = state.currFollowing[index];
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 5),
//                         child: ListTile(
//                             leading: ProfileImage(
//                                 radius: 25, pfpUrl: user.profileImageUrl),
//                             title: Text(user.username)),
//                       );
//                     },
//                   ),
//                 ),
//                 //child 3
//                 Align(
//                   alignment: Alignment.bottomCenter,
//                   child: Container(
//                     height: 42,
//                     color: Colors.grey[900],
//                     width: double.infinity,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         IconButton(onPressed: () {}, icon: Icon(Icons.video_call)),
//                         IconButton(onPressed: () {}, icon: Icon(Icons.mic_off)),
//                         IconButton(onPressed: () {}, icon: Icon(Icons.call_end, color: Colors.red[700],)),
//                       ],
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           );
//         });
// }

// Future<dynamic> _inviteToCall({required CallModel call, required String id, required CallshomeState state, required BuildContext context}) {
//     return showModalBottomSheet(
//         context: context,
//         builder: (context) {
//           return Container(
//             height: MediaQuery.of(context).size.height,
//             child: addPersonMethod(context, state),
//           );
//         });
//   }

 Column addPersonMethod(BuildContext context, CallshomeState state) {
     context.read<CallshomeCubit>().inviteToCall();
     return Column( 
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding( 
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Expanded(
             child: Align( 
               alignment: Alignment.topCenter,
                    child: ElevatedButton(
                       style: ElevatedButton.styleFrom( primary: Colors.teal ),
                        onPressed: () {},
                        child: Text("lauch call")
                      )
                    )
                  ),
          ),
          Padding( 
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Text(
              "Following",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
            child: Container(
              height:(MediaQuery.of(context).size.height /3),
                child: ListView.builder(
                  itemCount: state.currFollowing.length,
                  itemBuilder:(BuildContext context, int index) {
                    final Userr item = state.currFollowing[index];
                    return ListTile(
                      leading: ProfileImage(pfpUrl: item.profileImageUrl, radius: 25),
                      title: Text(item.username),
                      trailing: TextButton(
                          onPressed: () {},
                          child: Text(
                            "Invite",
                            style: TextStyle(color: Colors.teal,fontWeight:FontWeight.bold),
                          )
                        ),
                    );
                  },
                )
              ),
          )
        ],
      );
   }

