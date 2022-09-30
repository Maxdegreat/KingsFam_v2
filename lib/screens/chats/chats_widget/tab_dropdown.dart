import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:kingsfam/screens/chats/bloc/chatscreen_bloc.dart';

class ChatsDropDownButton extends StatefulWidget {
  final TabController tabctrl;
  const ChatsDropDownButton({Key? key, required this.tabctrl})
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
      setState(() {
        
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(7)
      ),
      child: Center(
        child: DropdownButton(
          underline: SizedBox.shrink(),
          value: defaultValue,
          items: [
            DropdownMenuItem(
              child: Text("Communitys", style: TextStyle(fontWeight: FontWeight.w500),),
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
    );
  }
}
