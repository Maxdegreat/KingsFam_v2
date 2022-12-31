import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/church/church_repository.dart';
import 'package:kingsfam/roles/role_types.dart';
import 'package:kingsfam/screens/commuinity/bloc/commuinity_bloc.dart';
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

class _CreateRoomState extends State<CreateRoom> {
  // with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {

  //@override
  //bool get wantKeepAlive => true;

  late TextEditingController _txtController;

  String selectedMode = "chat";
  String rollesAllowed = Roles.Member;

  // ---------------- state ------------------

  @override
  void initState() {
    _txtController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _txtController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).iconTheme.color,
              )),
          title: Text(
            "Creating Room",
            style: Theme.of(context).textTheme.bodyText1,
          ),
          actions: [
             Padding(
               padding: const EdgeInsets.all(8.0),
               child: TextButton(
                      style:
                          ElevatedButton.styleFrom(primary: Colors.greenAccent),
                      onPressed: () async {
                        if (_txtController.value.text.length == 0) {
                          snackBar(
                              snackMessage:
                                  "be sure you add a name for the room you are making",
                              context: context,
                              bgColor: Colors.red[400]);
                        } else if (_txtController.value.text.length > 17) {
                          snackBar(
                              snackMessage:
                                  "Less than or equal to 17 chars please and thanks",
                              context: context,
                              bgColor: Colors.red[400]);
                        } else {
                          await ChurchRepository().newKingsCord2(
                              currUserId: context.read<AuthBloc>().state.user!.uid,
                              ch: widget.cm,
                              cordName: _txtController.value.text,
                              mode: selectedMode,
                              rolesAllowed: null);
                          Navigator.of(context).pop();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          "Create",
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      )),
             )
          ],
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
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // child 1 will be the title as a textField
                        _textField(context),
                        // child 2 will be the chat room type
                        _createRoomContainerDisplay(context, "chat", "Chat room",
                            "A chat room allows for communication via text messages. You can share GIF's, images, videos, text, and react to messages"),
                        // child 3 will be the says room type
                        _createRoomContainerDisplay(context, "says", "Says room",
                            "A says room allows for users to share announcements or just say what is on their minds")
                        // child 4 will be the documents room type
                        //TODO
                      ],
                    ),
                  ));
            },
          ),
        ),
      ),
    );
  }

  Widget _createRoomContainerDisplay(
      BuildContext context, String selectedType, String type, String disction) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMode = selectedType;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          height: 111,
          width: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            border: selectedType == selectedMode ? Border.all(color: Colors.amber, width: 1) : null,
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // child 1 will be the title as room type
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(type, style: Theme.of(context).textTheme.bodyText1),
                ),
                // child 2 will be the discription
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child:
                      Text(disction, style: Theme.of(context).textTheme.caption),
                )
              ],
            ),
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
          TextField(
              decoration: InputDecoration(
                  hintText: "Enter a room name",
                  fillColor: Theme.of(context).colorScheme.secondary,
                  filled: true,
                  focusColor: Theme.of(context).colorScheme.secondary,
                  focusedBorder: UnderlineInputBorder()),
              onChanged: (value) => _txtController.text = value),
        ],
      ),
    );
  }

}
