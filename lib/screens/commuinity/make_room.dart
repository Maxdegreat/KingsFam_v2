import 'package:flutter/material.dart';

makeRoomPopUp({required BuildContext context}) {
  // a pop up that has a text field for a title and a list of possible rooms to create

  return showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        TextEditingController _txtCtrl = TextEditingController();
        String? selectedType; // types are "chat", "says", "documents",

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // child 1 will be the title as a textField
            TextField(
              decoration: InputDecoration(
                                  fillColor: Theme.of(context).colorScheme.secondary,
                  filled: true,
                  focusColor: Theme.of(context).colorScheme.secondary,
                label: Text("Room name")),
              controller: _txtCtrl,
              minLines: 1,
            ),

            // child 2 will be the chat room type
            createRoomContainerDisplay(context, "Chat room", "A chat room allows for communication via text messages. You can share GIF's, images, videos, text, and react to messages"),
            // child 3 will be the says room type
            createRoomContainerDisplay(context, "Says room", "A says room allows for users to share announcements or just say what is on their minds")
            // child 4 will be the documents room type
          ],
        );
      });
}

Widget createRoomContainerDisplay(BuildContext context, String type, String disction) {
  return Container(
    height: 100,
    width: MediaQuery.of(context).size.height,
    decoration: BoxDecoration(
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
            child: Text(disction, style: Theme.of(context).textTheme.caption),
          )
        ],
      ),
    ),
  );
}
