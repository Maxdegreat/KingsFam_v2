import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/church/church_repository.dart';
import 'package:kingsfam/roles/role_types.dart';
import 'package:kingsfam/screens/commuinity/bloc/commuinity_bloc.dart';
import 'package:kingsfam/screens/create_chat/create_chat_screen.dart';
import 'package:kingsfam/widgets/widgets.dart';
import 'package:date_time_picker/date_time_picker.dart';

class CreateRoomArgs {
  final CommuinityBloc cmBloc;
  final Church cm;
  const CreateRoomArgs({required this.cmBloc, required this.cm});
}

class CreateRoom extends StatefulWidget {
  const CreateRoom({Key? key, required this.cmBloc, required this.cm})
      : super(key: key);
  final CommuinityBloc cmBloc;
  final Church cm;

  static const String routeName = "createRoom_kc";
  static Route route({required CreateRoomArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) {
          return CreateRoom(cmBloc: args.cmBloc, cm: args.cm);
        });
  }

  @override
  State<CreateRoom> createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom>
    with SingleTickerProviderStateMixin {
  late TextEditingController _txtController;
  late TabController _tabController;

  String selectedMode = "chat";
  String rollesAllowed = Roles.Member;

  late TextEditingController _eTitle;
  late TextEditingController _eDiscription;
  Timestamp? startTimeStamp;
  Timestamp? endTimestamp;

  @override
  void initState() {
    _txtController = TextEditingController();
    _eTitle = TextEditingController();
    _eDiscription = TextEditingController();

    _tabController = TabController(vsync: this, length: 2);
    super.initState();
  }

  @override
  void dispose() {
    _txtController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Creating Room"),
        ),
        body: BlocProvider.value(
          value: widget.cmBloc,
          child: BlocConsumer<CommuinityBloc, CommuinityState>(
            listener: (context, state) {
              // TODO: implement listener
            },
            builder: (context, state) {
              return GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TabBar(
                        controller: _tabController,
                        tabs: [
                          Tab(text: "Add Event"),
                          Tab(text: "Create Room"),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child:
                            TabBarView(controller: _tabController, children: [
                          SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.5),
                                  child: TextField(
                                    controller: _eTitle,
                                    decoration: InputDecoration(
                                      labelText: "Event Title",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.5),
                                  child: TextField(
                                    controller: _eDiscription,
                                    decoration: InputDecoration(
                                      labelText: "Event Discription",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                DateTimePicker(
                                  type: DateTimePickerType.dateTimeSeparate,
                                  dateMask: 'd MMM, yyyy',
                                  initialValue: '',
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  icon: Icon(Icons.event),
                                  dateLabelText: 'Start Date',
                                  timeLabelText: "Hour",
                                  onChanged: (val) {
                                    DateTime? time;
                                    print(val);
                                    //          year                 month                day                    hour                   second
                                    var timelst = [val.substring(0, 4), val.substring(5,7), val.substring(8, 10), val.substring(11, 13), val.substring(14, 16)];
                                    time = DateTime( int.parse(timelst[0]),     int.parse(timelst[1]),   int.parse(timelst[2]), int.parse(timelst[3]), int.parse(timelst[4]));
                                    
                                    startTimeStamp = Timestamp.fromDate(time.toUtc());
                                    //log("start timestamp plain in utc: " + DateTime(year));
                                    log("start timestamp in utc: " + DateTime.fromMicrosecondsSinceEpoch(startTimeStamp!.microsecondsSinceEpoch).toString());
                                    // Timestamp.fromDate(DateTime(year))

                                    // keep start time and end time
                                    // do timestamp.fromdate
                                    // after 1 day form the start date del
                                    // the event
                                    // can order by date
                                  },
                                  validator: (val) {
                                    print(val);
                                    print("Timestmap" +
                                        Timestamp.now().toString());
                                    return null;
                                  },
                                  onSaved: (val) => print(val),
                                ),
                                DateTimePicker(
                                  initialValue: '',
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  dateLabelText: 'End Date',
                                  onChanged: (val) => print(val),
                                  validator: (val) {
                                    // endTimestamp = val;
                                    return null;
                                  },
                                  onSaved: (val) => print(val),
                                ),
                                SizedBox(height: 10),
                                ElevatedButton(
                                    onPressed: () {
                                      // if (_eDiscription.value.text.isNotEmpty && _eTitle.value.text.isNotEmpty && startTimeStamp != null && endTimestamp != null) {
                                      //   Event event = Event(
                                      //     eventTitle: _eTitle.value.text, eventDecription: _eDiscription.value.text, startDate: startDate, endDate: endDate)
                                      //   FirebaseFirestore.instance.collection(Paths.church).doc(widget.cm.id).collection(Paths.event).add(data)
                                      // }
                                    },
                                    child: Text("Create Event"))
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Text("Room type"),
                              _pickRoomType(),
                              _textField(context)
                            ],
                          )
                        ]),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _textField(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: TextField(
                decoration: InputDecoration(hintText: "Enter a name"),
                onChanged: (value) => _txtController.text = value),
          ),
          SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
                width: (double.infinity * .70),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.white),
                    onPressed: () async {
                      if (_txtController.value.text.length == 0) {
                        snackBar(
                            snackMessage:
                                "be sure you add a name for the Chat Room you are making",
                            context: context,
                            bgColor: Colors.red[400]);
                      } else if (_txtController.value.text.length > 17) {
                        snackBar(
                            snackMessage:
                                "Yo, Fam less than or equal to 17 chars please nd thanks",
                            context: context,
                            bgColor: Colors.red[400]);
                      } else {
                        log("making channle");
                        await ChurchRepository().newKingsCord2(
                            ch: widget.cm,
                            cordName: _txtController.value.text,
                            mode: selectedMode,
                            rolesAllowed: null);
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(
                      "Done",
                      style: TextStyle(color: Colors.black),
                    ))),
          )
        ],
      ),
    );
  }

  Widget _pickRoomType() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedMode = "chat";
                });
              },
              child: Text("Chat Room"),
              style: ButtonStyle(
                  foregroundColor: selectedMode == "chat"
                      ? MaterialStateProperty.all<Color>(Colors.white)
                      : MaterialStateProperty.all<Color>(Colors.grey),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.transparent),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                          side: BorderSide(
                              color: selectedMode == "chat"
                                  ? Colors.white
                                  : Colors.grey)))),
            ),
            SizedBox(
              width: 7,
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedMode = "says";
                });
              },
              child: Text("Says"),
              style: ButtonStyle(
                  foregroundColor: selectedMode == "says"
                      ? MaterialStateProperty.all<Color>(Colors.white)
                      : MaterialStateProperty.all<Color>(Colors.grey),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.transparent),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                          side: BorderSide(
                              color: selectedMode == "says"
                                  ? Colors.white
                                  : Colors.grey)))),
            )
          ],
        ),
        SizedBox(height: 3),
        Text(
          selectedMode == "chat"
              ? "This will be a chat room"
              : "This will be a says room",
          style: TextStyle(color: Colors.grey),
        )
      ],
    );
  }

  // Widget _rolesAllowed() {
  //   VoidCallback func1 = () {
  //     setState(() {
  //       setState(() {

  //       });
  //     });
  //   };
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.start,
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [btntransparent()],
  //   );
  // }

  // Widget btntransparent(
  //   VoidCallback func,
  //   Color c1,
  //   String displayTxt,
  // ) {
  //   return Container(
  //       width: (double.infinity * .70),
  //       child: ElevatedButton(
  //           style: ElevatedButton.styleFrom(primary: c1),
  //           onPressed: () {
  //             if (_txtController.value.text.length == 0) {
  //               snackBar(
  //                   snackMessage:
  //                       "be sure you add a name for the Chat Room you are making",
  //                   context: context,
  //                   bgColor: Colors.red[400]);
  //             } else if (_txtController.value.text.length > 17) {
  //               snackBar(
  //                   snackMessage:
  //                       "Yo, Fam less than or equal to 17 chars please nd thanks",
  //                   context: context,
  //                   bgColor: Colors.red[400]);
  //             } else {
  //               // make a new channel
  //               widget.cmBloc.makeNewKc(
  //                   commuinity: widget.cm,
  //                   cordName: _txtController.value.text,
  //                   ctx: context,
  //                   mode: selectedMode,
  //                   rolesAllowed: null);
  //               Navigator.of(context).pop();
  //             }
  //           },
  //           child: Text(
  //             displayTxt,
  //             style: TextStyle(color: Colors.black),
  //           )));
  // }
}
