import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:kingsfam/extensions/hexcolor.dart';
import 'package:kingsfam/screens/chats/bloc/chatscreen_bloc.dart';

class ChatsDropDownButton extends StatefulWidget {
  final TabController tabctrl;
  final bool stateUnreadChats;
  const ChatsDropDownButton({Key? key, required this.tabctrl, required this.stateUnreadChats})
      : super(key: key);

  @override
  State<ChatsDropDownButton> createState() => _ChatsDropDownButtonState();
}

class _ChatsDropDownButtonState extends State<ChatsDropDownButton> {
  int defaultValue = 0;

  @override
  void initState() {
    tabControllerListener();
    super.initState();
  }

  tabControllerListener() {
    if (widget.tabctrl.indexIsChanging) {
      defaultValue = widget.tabctrl.index;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    HexColor hc = HexColor();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 155,
        height: 30,
        decoration: BoxDecoration(
            color: Color(hc.hexcolorCode('#141829')),
            borderRadius: BorderRadius.circular(7)),
        child: Row(
          children: [
            SizedBox(
              width: 7,
            ),
            CircleAvatar(
              radius: 3,
              backgroundColor: widget.stateUnreadChats ? Colors.amber : Colors.transparent,
            ),
            SizedBox(
              width: 7,
            ),
            Center(
              child: DropdownButton(
                underline: SizedBox.shrink(),
                value: defaultValue,
                items: [
                  DropdownMenuItem(
                    child: Text(
                      "Communitys",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    value: 0,
                  ),
                  DropdownMenuItem(
                    child: Text("Chats"),
                    value: 1,
                  )
                ],
                onChanged: (int? value) {
                  if (value != null && value <= widget.tabctrl.length - 1) {
                    widget.tabctrl.index = value;
                    defaultValue = widget.tabctrl.index;
                    setState(() {});
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
