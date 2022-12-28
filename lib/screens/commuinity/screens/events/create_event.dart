import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/event_model.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/screens/commuinity/bloc/commuinity_bloc.dart';
import 'package:kingsfam/widgets/snackbar.dart';

class CreateEventArgs {
  final CommuinityBloc cmBloc;
  final Church cm;

  const CreateEventArgs({required this.cmBloc, required this.cm});
}

class CreateEvent extends StatefulWidget {
  final CommuinityBloc cmBloc;
  final Church cm;
  const CreateEvent({Key? key, required this.cmBloc, required this.cm})
      : super(key: key);

  static const String routeName = "/createEventScreen";
  static Route route({required CreateEventArgs args}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) {
        return CreateEvent(cmBloc: args.cmBloc, cm: args.cm);
      },
    );
  }

  @override
  State<CreateEvent> createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  late TextEditingController _eTitle;
  late TextEditingController _eDiscription;
  Timestamp? startTimeStamp;
  Timestamp? endTimestamp;
  bool submitting = false;

  @override
  void initState() {
    _eTitle = TextEditingController();
    _eDiscription = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _eTitle.dispose();
    _eDiscription.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(),
            body: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.5),
                      child: TextField(
                        controller: _eTitle,
                        decoration: InputDecoration(
                                            fillColor: Theme.of(context).colorScheme.secondary,
                  filled: true,
                  focusColor: Theme.of(context).colorScheme.secondary,
                          labelText: "Event Title",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.5),
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
                        initialValue: "",
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        icon: Icon(Icons.event),
                        dateLabelText: 'Start Date',
                        timeLabelText: "Hour",
                        onChanged: (val) {
                          DateTime? time;
                          //          year                 month                day                    hour                   second
                          var timelst = [
                            val.substring(0, 4),
                            val.substring(5, 7),
                            val.substring(8, 10),
                            val.substring(11, 13),
                            val.substring(14, 16)
                          ];
                          time = DateTime(
                              int.parse(timelst[0]),
                              int.parse(timelst[1]),
                              int.parse(timelst[2]),
                              int.parse(timelst[3]),
                              int.parse(timelst[4]));
                          var local = time.toLocal();
                          startTimeStamp = Timestamp.fromDate(local.toUtc());
                          log("start timestamp plain in UTC: " +
                              time.toUtc().toString());
                          log("start timestamp plain in local: " +
                              time.toLocal().toString());
                          log("start timestamp plain in ____: " +
                              time.toString());
                          log("start timestamp from UTC: " +
                              DateTime.fromMicrosecondsSinceEpoch(
                                      startTimeStamp!.microsecondsSinceEpoch)
                                  .toString());
                          // Timestamp.fromDate(DateTime(year))
                        },
                        validator: (val) {},
                        onSaved: (val) {}),
                    DateTimePicker(
                        type: DateTimePickerType.dateTimeSeparate,
                        dateMask: 'd MMM, yyyy',
                        initialValue: "",
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        icon: Icon(Icons.event),
                        dateLabelText: 'End Date',
                        timeLabelText: "Hour",
                        onChanged: (val) {
                          DateTime? time;
                          //          year                 month                day                    hour                   second
                          var timelst = [
                            val.substring(0, 4),
                            val.substring(5, 7),
                            val.substring(8, 10),
                            val.substring(11, 13),
                            val.substring(14, 16)
                          ];
                          time = DateTime(
                              int.parse(timelst[0]),
                              int.parse(timelst[1]),
                              int.parse(timelst[2]),
                              int.parse(timelst[3]),
                              int.parse(timelst[4]));
                          var local = time.toLocal();
                          endTimestamp = Timestamp.fromDate(
                              local.toUtc()); // storing the time stamp in utc

                          log("end timestamp plain in UTC: " +
                              time.toUtc().toString());
                          log("end timestamp plain in local: " +
                              time.toLocal().toString());
                          log("end timestamp plain in ____: " +
                              time.toString());
                          log("end timestamp from UTC: " +
                              DateTime.fromMicrosecondsSinceEpoch(
                                      endTimestamp!.microsecondsSinceEpoch)
                                  .toString());
                          // Timestamp.fromDate(DateTime(year))
                        },
                        validator: (val) {
                          return null;
                        },
                        onSaved: (val) {}),
                    SizedBox(height: 10),
                    ElevatedButton(
                        onPressed: () async {
                          if (startTimeStamp == null ||
                              endTimestamp == null ||
                              _eDiscription.value.text.isEmpty ||
                              _eTitle.value.text.isEmpty) {
                            snackBar(
                                snackMessage:
                                    "Make sure all values are full, yezirr",
                                context: context,
                                bgColor: Colors.red[400]);
                          } else {
                            DateTime t1 = DateTime.fromMicrosecondsSinceEpoch(
                                startTimeStamp!.microsecondsSinceEpoch);
                            DateTime t2 = DateTime.fromMicrosecondsSinceEpoch(
                                endTimestamp!.microsecondsSinceEpoch);
                            // log("using doc to see if isbefore: " + t1.isBefore(t2).toString());
                            if (t1.isBefore(DateTime.now())) {
                              snackBar(
                                  snackMessage:
                                      "Your start time must be after or on this current date",
                                  context: context,
                                  bgColor: Colors.red[400]);
                            }
                            if (_eDiscription.value.text.isNotEmpty &&
                                _eTitle.value.text.isNotEmpty &&
                                startTimeStamp != null &&
                                endTimestamp != null &&
                                submitting == false) {
                              submitting = true;
                              if (t1.isAfter(t2)) {
                                snackBar(
                                    snackMessage:
                                        "Hey, starting time can not be after the ending time",
                                    context: context,
                                    bgColor: Colors.red[400]);
                              } else {
                                Event event = Event(
                                    eventTitle: _eTitle.value.text,
                                    eventDescription: _eDiscription.value.text,
                                    startDate: startTimeStamp!,
                                    endDate: endTimestamp!);
                                FirebaseFirestore.instance
                                    .collection(Paths.church)
                                    .doc(widget.cm.id)
                                    .collection(Paths.events)
                                    .add(event.toDoc());
                                snackBar(
                                    snackMessage: "Creating your Event",
                                    context: context,
                                    bgColor: Colors.white);
                                widget.cmBloc.onAddEvent(event: event);
                                await Future.delayed(Duration(
                                  seconds: 1,
                                )).then((value) => Navigator.of(context).pop());
                              }
                            }
                          }
                        },
                        child: Text("Create Event"))
                  ],
                ),
              ),
            )));
  }
}
