import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FancyListTile extends StatelessWidget {
  final String username;
  final String imageUrl;
  final GestureTapCallback? onTap;
  final bool isBtn;
  final double BR;
  final double height;
  final double width;
  const FancyListTile(
      {Key? key,
      required this.username,
      required this.imageUrl,
      required this.onTap,
      required this.isBtn,
      required this.BR,
      required this.height,
      required this.width})
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
            width: 35.0,
          ),
          Text('$username.',
              overflow: TextOverflow.fade,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, color: Colors.white)),
          SizedBox(width: 0),
          isBtn ? Icon(Icons.check_circle) : SizedBox.shrink()
        ],
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(BR), bottomLeft: Radius.circular(BR)),
      ),
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
