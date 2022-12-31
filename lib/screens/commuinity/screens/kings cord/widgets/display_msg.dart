import 'package:flutter/material.dart';
import 'package:kingsfam/models/message_model.dart';

class DisplayMsg extends StatelessWidget {
  final Message m;
  const DisplayMsg({Key? key, required this.m}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle s = Theme.of(context).textTheme.caption!;
    Size size = MediaQuery.of(context).size;
    if (m.text == welcomeMsgEncoded) {
      return Text("Hi");
    } else if (m.text == firstMsgEncoded) {
      return _newRoom(size, s);
    } else {
      return _msg(size, s);
    }
  }

  _welcomMsg(Size size, TextStyle s) {
    return Container(
      height: (size.height / 9) / 2.5,
      width: (size.width / 1.3) / 1.4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: Color.fromARGB(46, 255, 193, 7),
      ),
      child: Center(
        child: Text(
          "Welcome " + m.sender!.username,
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.fade,
          style: s,
        ),
      ),
    );
  }

  _newRoom(Size size, TextStyle s) {
    return Container(
      height: (size.height / 9) / 2,
      width: (size.width / 1.3) / 1.4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: Color.fromARGB(45, 36, 255, 7),
      ),
      child: Center(
        child: Text(
          m.sender!.username + " created This room",
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.fade,
          style: s,
        ),
      ),
    );
  }

  _msg(Size size, TextStyle s) {
    String msg = m.text != null ? m.text! : " shared something";
    return Container(
      height: (size.height / 9) / 2,
      width: (size.width / 1.3) / 1.4,
      decoration: BoxDecoration(),
      child: Center(
        child: Text(
          m.sender!.username + ": " + msg,
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.fade,
          style: s,
        ),
      ),
    );
  }
}
