import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kingsfam/models/event_model.dart';
import 'package:kingsfam/screens/commuinity/bloc/commuinity_bloc.dart';

class EventViewArgs {
  final CommuinityBloc cmBloc;
  final Event event;
  const EventViewArgs({required this.cmBloc, required this.event});
}

class EventView extends StatefulWidget {
  const EventView({Key? key, required this.cmBloc, required this.event})
      : super(key: key);

  final CommuinityBloc cmBloc;
  final Event event;

  static const String routeName = "EventView";

  static Route route({required EventViewArgs args}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) {
        return EventView(cmBloc: args.cmBloc, event: args.event);
      }
    );
  }

  @override
  State<EventView> createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  @override
  Widget build(BuildContext context) {
    return  SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Event View ~ ${widget.event.eventTitle}", overflow: TextOverflow.ellipsis),
        ),
        body: Container(
          
        ),
      ),
    );
  }
}
