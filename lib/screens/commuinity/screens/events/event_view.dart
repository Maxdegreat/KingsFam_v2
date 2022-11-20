import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kingsfam/config/constants.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/event_model.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/screens/commuinity/bloc/commuinity_bloc.dart';
import 'package:kingsfam/widgets/snackbar.dart';

class EventViewArgs {
  final CommuinityBloc cmBloc;
  final Event event;
  final Church cm;
  const EventViewArgs({required this.cmBloc, required this.event, required this.cm});
}

class EventView extends StatefulWidget {
  const EventView({Key? key, required this.cmBloc, required this.event, required this.cm})
      : super(key: key);

  final CommuinityBloc cmBloc;
  final Event event;
  final Church cm;


  static const String routeName = "EventView";

  static Route route({required EventViewArgs args}) {
    return MaterialPageRoute(
        settings: const RouteSettings(name: routeName),
        builder: (context) {
          return EventView(cmBloc: args.cmBloc, event: args.event, cm: args.cm);
        });
  }

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  String? updatedEventName;
  String? updatedEventAbout;
  bool editingView = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text("Event View ~ ${widget.event.eventTitle}",
                overflow: TextOverflow.ellipsis),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: !editingView
                  ? // when false show the non-editingView else show the editingView

                  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Title: " + widget.event.eventTitle,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        //                      month                             day                                   year
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Start date: " +
                                widget.event.startDateFrontEnd![1] +
                                "/" +
                                widget.event.startDateFrontEnd![2] +
                                "/" +
                                widget.event.startDateFrontEnd![0],
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "End date: " +
                                widget.event.endDateFrontEnd![1] +
                                "/" +
                                widget.event.endDateFrontEnd![2] +
                                "/" +
                                widget.event.endDateFrontEnd![0],
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Description: "),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 250,
                            width: double.infinity,
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    child: Text(widget.event.eventDescription)),
                              ),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              color: Color(hc.hexcolorCode('141829')),
                            ),
                          ),
                        ),
                        

                        // show only if the permission is correct.

                        widget.cmBloc.state.role["permissions"].contains("#") ||
                        widget.cmBloc.state.role["permissions"].contains("*") 

                            ? Align(
                              alignment: Alignment.bottomCenter,
                              child: ElevatedButton(
                                  onPressed: () {
                                    editingView = !editingView;
                                    setState(() {});
                                  }, child: Text("Edit")
                                ),
                            )
                            : SizedBox.shrink()
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          initialValue: widget.event.eventDescription,
                          validator: (val) {
                            if (val != null && val.length > 120) {
                              return "Description must be less than 120 chars";
                            } else
                              return null;
                          },
                          onChanged: (val) {
                            if (val.length > 18) {
                              updatedEventAbout = val;
                            }
                          },
                          decoration: InputDecoration(
                            labelText: "Event Description",
                          ),
                        ),
                        TextFormField(
                          initialValue: widget.event.eventTitle,
                          validator: (val) {
                            if (val != null && val.length > 18) {
                              return "title must be less than 18 chars";
                            } else
                              return null;
                          },
                          onChanged: (val) {
                            if (val.length > 18) {
                              updatedEventName = val;
                            }
                          },
                          decoration: InputDecoration(
                            labelText: "Event Title",
                          ),
                        ),

                         ElevatedButton(
                          onPressed: () {
                              Event newE = Event(
                                eventDescription: updatedEventAbout?? widget.event.eventDescription,
                                eventTitle: updatedEventName?? widget.event.eventTitle,
                                endDate: widget.event.endDate,
                                startDate: widget.event.startDate,
                                id: widget.event.id,
                              );
                             FirebaseFirestore.instance.collection(Paths.church).doc(widget.cm.id).collection(Paths.events).doc(widget.event.id).update(newE.toDoc());
                          }, 
                          child: Text("Save Changes"),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                            shape: StadiumBorder()
                          ),
                        ),


                        ElevatedButton(
                          onPressed: () {
                            editingView =! editingView;
                            setState(() {});
                          }, 
                          child: Text("Cancel Changes"),
                           style: ElevatedButton.styleFrom(
                            primary: Colors.black87,
                            shape: StadiumBorder()
                          ),
                        ),
                        
                        // this is a delete button
                        ElevatedButton(
                          onPressed: ()  {
                            // delete
                            FirebaseFirestore.instance.collection(Paths.church).doc(widget.cm.id).collection(Paths.events).doc(widget.event.id!).delete().then((_) {

                            // pop back
                            snackBar(snackMessage: "Deleted", context: context, bgColor: Colors.red);
                            Navigator.of(context).pop();
                            });
                          },
                          child: Text("Delete This Event"),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red[400],
                            shape: StadiumBorder()
                          ),
                        ),
                      ],
                    ),
            ),
          )),
    );
  }
}
