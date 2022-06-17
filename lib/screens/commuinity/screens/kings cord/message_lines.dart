import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kingsfam/extensions/hexcolor.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/extensions/extensions.dart';


class MessageLines extends StatelessWidget {
  //class data
  final Message message;

  const MessageLines({ required this.message});

  // if i send the message.
  _buildText() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.grey[400], fontSize: 17.0, fontWeight: FontWeight.w800),
          children: [
            message.text!.contains('@')  ?
            TextSpan(text: message.text!, style: TextStyle(color: Colors.blueGrey, fontSize: 17.0, fontWeight: FontWeight.w800)) : 
            TextSpan(text: message.text!)
          ]
        )
      )
    );
  }

  //for an image
  _buildImage(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.2,
      width: size.width * 0.6,
      decoration: BoxDecoration(
        border: Border.all(width: 2.0, color: const Color(0xFFFFFFFF)), // Color(hexcolor.hexcolorCode(message.sender!.colorPref))
          borderRadius: BorderRadius.circular(20.0),
          image: DecorationImage(
              fit: BoxFit.cover,
              image: CachedNetworkImageProvider(message.imageUrl!))),
    );
  }

  @override
  Widget build(BuildContext context) {
      // final bool isMe =
    //     context.read<AuthBloc>().state.user!.uid == message.senderId;

    // this is for the hex color
    HexColor hexcolor = HexColor();
    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // a row displaying imageurl of member and name
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                //FancyListTile(username: '${kingsCordMemInfo.memberInfo[message.senderId]['username']}', imageUrl: '${kingsCordMemInfo.memberInfo[message.senderId]['profileImageUrl']}', onTap: null, isBtn: false, BR: 18, height: 18, width: 18),
                kingsCordAvtar(context),
                SizedBox(
                  width: 5.0,
                ),
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Text(message.sender!.username, 
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: message.sender!.colorPref == "" ? Colors.red : Color(hexcolor.hexcolorCode(message.sender!.colorPref))
                  ),
                ), 
                 Text('${message.date.timeAgo()}', 
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white, 
                  ),
                )
                 ],
               )
              ],
            ),
            SizedBox(height: 5.0),
            Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                child:
                    message.text != null ? _buildText() : _buildImage(context)),
          ],
        ));
  }
  Widget kingsCordAvtar(BuildContext context) {
    
    HexColor hexcolor = HexColor();
    Size size = MediaQuery.of(context).size;
    return Container(
            height: size.height / 18.5,
            width: size.width / 8,
            child: message.sender!.profileImageUrl != "null" ? kingsCordProfileImg() : kingsCordProfileIcon(),
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: message.sender!.colorPref == "" ? Colors.red : Color(hexcolor.hexcolorCode(message.sender!.colorPref))),
              color: message.sender!.colorPref == "" ? Colors.red : Color(hexcolor.hexcolorCode(message.sender!.colorPref)),
              borderRadius: BorderRadius.circular(25)
            ),
          );

  }
  Widget? kingsCordProfileImg() => CircleAvatar(backgroundColor: Colors.grey[400], backgroundImage:  CachedNetworkImageProvider(message.sender!.profileImageUrl) );
  Widget? kingsCordProfileIcon() => Container(child: Icon(Icons.account_circle));
  
}
