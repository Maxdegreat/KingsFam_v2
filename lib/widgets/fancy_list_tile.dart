import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kingsfam/extensions/hexcolor.dart';
import 'package:kingsfam/widgets/widgets.dart';

import '../models/post_model.dart';

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
  final Post? post;
  final BuildContext context;
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
      required this.context,
      this.location,
      this.isMentioned,
      this.post})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    HexColor hc = HexColor();
    return Column(
      children: [
        child1(context, hc),
        SizedBox(
          height: 5,
        ),
        child2(context),
      ],
    );
  }

  Container child1(BuildContext context, HexColor hc) {
    
    return Container(
        
        height: MediaQuery.of(context).size.height / height,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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
                      style: newNotification == null || newNotification == false
                          ? Theme.of(context).textTheme.bodyText1
                          : Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.amber)),
                  SizedBox(height: 3),
                  location != null || location == ""
                      ? Text('$location.',
                          overflow: TextOverflow.fade,
                          style: Theme.of(context).textTheme.caption)
                      : Text('Remote.',
                          overflow: TextOverflow.fade,
                          style: Theme.of(context).textTheme.caption),
                ],
              ),
              SizedBox(width: width - (width * .10)),
              isBtn
                  ? Icon(Icons.check_circle)
                  : isMentioned != null && isMentioned == true
                      ? Icon(
                          Icons.alternate_email_outlined,
                          color: Colors.amber,
                        )
                      : SizedBox.shrink()
            ],
          ),
        ),
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomRight,
              colors: [
                        Theme.of(context).scaffoldBackgroundColor,
                        Theme.of(context).colorScheme.secondary,
                        // Theme.of(context).colorScheme.onPrimary,
              ]),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
                color: isMentioned == null || isMentioned == false
                    ? Colors.transparent//blue[900]!
                    : Colors.amber)));
  }

  Widget child2(BuildContext context) {
    if (post != null) {
      TextStyle s = TextStyle(color: Colors.grey, fontStyle: FontStyle.italic);
      String imgUrlPost =
          post!.imageUrl != null ? post!.imageUrl! : post!.thumbnailUrl!;
      String caption = post!.caption != null
          ? post!.caption!.length > 18
              ? post!.caption!.substring(0, 18) + "..."
              : post!.caption!
          : "";
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 35),
            ProfileImage(radius: 20, pfpUrl: imgUrlPost),
            SizedBox(width: 15),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(post!.author.username, style: s,), Text(caption, style: s,)],
            )
          ],
        ),
      );
    }
    return SizedBox.shrink();
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
    HexColor hc = HexColor();
    return Container(
        height: MediaQuery.of(context).size.height / height,
        width: MediaQuery.of(context).size.width / 5,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BR),
            color: Color(hc.hexcolorCode('#20263c')),
            image: url.isNotEmpty
                ? DecorationImage(
                    fit: BoxFit.cover, image: CachedNetworkImageProvider(url))
                : null),
        child: url.isEmpty ? Icon(Icons.account_circle_outlined) : null);
  }
}
