import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FancyListTile extends StatelessWidget {
  final String username;
  final bool? newNotification;
  final String imageUrl;
  final GestureTapCallback? onTap;
  final bool isBtn;
  final double BR;
  final double height;
  final double width;
  final bool? isMentioned;
  final String? location;
  const FancyListTile(
      {Key? key,
      required this.username,
      this.newNotification = false,
      required this.imageUrl,
      required this.onTap,
      required this.isBtn,
      required this.BR,
      required this.height,
      required this.width,
      this.location, 
      this.isMentioned,
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      
      height: MediaQuery.of(context).size.height / height,
      width: double.infinity,
      child: Row(
        //mainAxisAlignment: MainAxisAlignment.start,
        children: [
          leadingImageWidget(
            url: imageUrl,
            BR: BR,
            height: height,
            width: width,
          ), //leading is taking the same value that was passed into thh fancy
          SizedBox(
            width: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$username.',
                  overflow: TextOverflow.fade,
                  style: newNotification == null  || newNotification == false ? TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, color: Colors.white) :  TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, color: Colors.amber[200])), 
              SizedBox(height: 3),
              location != null || location == "" ? Text('$location.', overflow: TextOverflow.fade,
                  style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600, color: Colors.grey[700])) : Text('Remote.', overflow: TextOverflow.fade,
                  style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600, color: Colors.grey[700])),
            ],
          ),
          SizedBox(width: width - (width*.10)),
          isBtn ? Icon(Icons.check_circle) : isMentioned!=null&&isMentioned==true? Icon(Icons.alternate_email_outlined, color: Colors.amber,) : SizedBox.shrink()

        ],
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only( topLeft: Radius.circular(BR), bottomLeft: Radius.circular(BR)),
        border: Border.all(color: isMentioned== null || isMentioned==false? Colors.transparent:Colors.amber)
          
          )
          
      
    );
  }
}

class leadingImageWidget extends StatelessWidget {
  final String url;
  final double BR;
  final double height;
  final double width;
  const leadingImageWidget(
      {Key? key,
      required this.url,
      required this.BR,
      required this.height,
      required this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height / height,
        width: MediaQuery.of(context).size.width / 5,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BR),
            color: Colors.black,
            image: url.isNotEmpty
                ? DecorationImage(
                    fit: BoxFit.cover, image: CachedNetworkImageProvider(url))
                : null),
        child: url.isEmpty ? Icon(Icons.account_circle_outlined) : null);
  }
}
