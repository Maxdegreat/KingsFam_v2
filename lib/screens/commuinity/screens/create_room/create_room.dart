import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/mode.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/church/church_repository.dart';
import 'package:kingsfam/roles/role_types.dart';
import 'package:kingsfam/screens/commuinity/bloc/commuinity_bloc.dart';
import 'package:kingsfam/widgets/widgets.dart';

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
  late PageController _pageController;
  String selectedMode = "";
  Set roles = {"Member"};
  String chatPriority = "Passive Chat";


  // ---------------- state ------------------

  @override
  void initState() {
    log("from the create room the badges len is: ");

    _txtController = TextEditingController();
    _pageController = PageController();

    context.read<CommuinityBloc>().addBadge("Member");

    super.initState();
  }

  @override
  void dispose() {
    _txtController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                if (_pageController.positions.isNotEmpty &&
                    _pageController.page == 1)
                  _pageController.previousPage(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.ease);
                else
                  Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).iconTheme.color,
              )),
          title: Text(
            "Creating Room",
            style: Theme.of(context).textTheme.bodyText1,
          ),
          actions: [
            if (_pageController.positions.isNotEmpty) ...[
              if (_pageController.page == 0) ...[
                TextButton(
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
                      } else if (selectedMode.length < 1) {
                        snackBar(
                            snackMessage: "Oh, please select a room type :)",
                            context: context,
                            bgColor: Colors.red[400]);
                      } else {
                        _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.ease);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text("Continue",
                          style: Theme.of(context).textTheme.bodyText1),
                    ))
              ] else ...[
                TextButton(
                    onPressed: () async {
                      await ChurchRepository().newKingsCord2(
                          currUserId: context.read<AuthBloc>().state.user!.uid,
                          ch: widget.cm,
                          cordName: _txtController.value.text,
                          mode: selectedMode,
                          rolesAllowed: null,
                          metaData: roles.isNotEmpty
                              ? {
                                  "roles": roles.toList(),
                                  selectedMode == Mode.chat ? "chatPriority": chatPriority : null
                                }
                              : null);
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Done",
                      style: Theme.of(context).textTheme.bodyText1,
                    ))
              ]
            ]
          ],
        ),
        body: BlocProvider.value(
          value: widget.cmBloc,
          child: BlocConsumer<CommuinityBloc, CommuinityState>(
            listener: (context, state) {},
            builder: (context, state) {
              return GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: PageView(
                        physics: NeverScrollableScrollPhysics(),
                        onPageChanged: (int val) {
                          Future.delayed(Duration(milliseconds: 502))
                              .then((value) {
                            setState(() {});
                          });
                        },
                        controller: _pageController,
                        scrollDirection: Axis.vertical,
                        children: [child1(), child2()],
                      )));
            },
          ),
        ),
      ),
    );
  }

  child1() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // child 1 will be the title as a textField
        _textField(context),
        // child 2 will be the chat room type
        _createRoomContainerDisplay(context, "chat", "Chat room",
            "A chat room allows for communication via text messages. You can share GIF's, images, videos, text, and react to messages."),
        // _createRoomContainerDisplay(context, "link", "Link Room",
        //     "Use this room to share important information with your community. only members with certain roles of your choice can add information and links"),

        // _createRoomContainerDisplay(context, "event", "Event Room",
        //     "Use this room to share epic events with your community! everyone or members with certain badges can come and view events "),

        // child 3 will be the says room type
        _createRoomContainerDisplay(context, "says", "Forum room",
            "A Form room allows for your fam to share information or just say what is on their minds."),
        // child 4 vc room
        // _createRoomContainerDisplay(context, "attendance", "Attendance room", "Lead, Admins and Mods can use this room to keep track of their fellowship attendance.")
        // _createRoomContainerDisplay(context, "vc", 'VC', "A VC room stands for voice chat. This room also alloWs for video calls.")
      ],
    );
  }

  child2() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_txtController.text, style: Theme.of(context).textTheme.bodyLarge),
        SizedBox(
          height: 10,
        ),
                            // who can write based on role
                    Text("Below shows the roles of people who are allowed to add to this room (type, share links, images, gifs ect...)", style: Theme.of(context).textTheme.caption),
                    SizedBox(
                      height: 7,
                    ),
                    rowOfRoles(),
                                        SizedBox(
                      height: 7,
                    ),
                    // who can write based on role
                    Text("Below shows the how notifications will be sent out for this chat room.)", style: Theme.of(context).textTheme.caption),
                    SizedBox(
                      height: 7,
                    ),
                    rowOfPriority(),

      ],
    );
  }

  Widget rowOfRoles() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          textForRR("Member", false),
          textForRR("Mod, Admin, Lead", false),
          textForRR("Admin, Lead", false),
        ],
      ),
    );
  }

  Widget rowOfPriority() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          textForRR("Passive Chat", true),
          textForRR("Notify For All Messages", true),
        ],
      ),
    );
  }

  textForRR(String text, bool? isForChatPriority) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            if (isForChatPriority == null || !isForChatPriority) {
              if (roles.isNotEmpty) {
                roles.clear();
                roles.add(text);
              } else {
                roles.add(text);
              }
            } else {
              chatPriority = text;
            }
            



            setState(() {});
          },
          child: Container(
              decoration: BoxDecoration(
                  border: roles.contains(text) || chatPriority == text
                      ? Border.all(color: Colors.greenAccent, width: .7)
                      : null,
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(7)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.caption,
                ),
              )),
        ),
      );

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
            border: selectedType == selectedMode
                ? Border.all(color: Colors.amber, width: 1)
                : null,
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
                  child:
                      Text(type, style: Theme.of(context).textTheme.bodyText1),
                ),
                // child 2 will be the discription
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(disction,
                      style: Theme.of(context).textTheme.caption),
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
