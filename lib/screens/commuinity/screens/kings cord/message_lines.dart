import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kingsfam/extensions/hexcolor.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/extensions/extensions.dart';


class MessageLines extends StatelessWidget {
  //class data
  final Map<String, dynamic> kingsCord;
  final Message message;

  const MessageLines({ required this.kingsCord, required this.message});

  // if i send the message.
  _buildText() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      child: Text(message.text!,
          style: TextStyle(color: Colors.grey[400], fontSize: 17.0, fontWeight: FontWeight.w800)),
    );
  }

  //for an image
  _buildImage(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.2,
      width: size.width * 0.6,
      decoration: BoxDecoration(
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
                //FancyListTile(username: '${kingsCord.memberInfo[message.senderId]['username']}', imageUrl: '${kingsCord.memberInfo[message.senderId]['profileImageUrl']}', onTap: null, isBtn: false, BR: 18, height: 18, width: 18),
                kingsCordAvtar(context),
                SizedBox(
                  width: 5.0,
                ),
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Text('${kingsCord[message.senderId]['username']}', 
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(hexcolor.hexcolorCode('${kingsCord[message.senderId]['colorPref']}'))
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
                  maxWidth: MediaQuery.of(context).size.width ,
                ),
                child:
                    message.text != null ? _buildText() : _buildImage(context)),
          ],
        ));
  }
  Widget kingsCordAvtar(BuildContext context) {
    HexColor hexcolor = HexColor();
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Positioned(
          top: 7.5,
          right: 5.5,
          child: Container(
            height: size.height / 18.5,
            width: size.width / 8,
            decoration: BoxDecoration(
              color: Color(hexcolor.hexcolorCode('${kingsCord[message.senderId]['colorPref']}')),
              borderRadius: BorderRadius.circular(25)
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: '${kingsCord[message.senderId]['pfpImageUrl']}' != "null" ? kingsCordProfileImg() : kingsCordProfileIcon(),
        )
      ],
    );

  }
  Widget? kingsCordProfileImg() => CircleAvatar(backgroundColor: Colors.grey[400], backgroundImage:  CachedNetworkImageProvider('${kingsCord[message.senderId]['pfpImageUrl']}') );
  Widget? kingsCordProfileIcon() => Container(child: Icon(Icons.account_circle));
  
}
