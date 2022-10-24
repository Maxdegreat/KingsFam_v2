import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:helpers/helpers.dart';
import 'package:kingsfam/extensions/date_time_extension.dart';
import 'package:kingsfam/config/constants.dart';
import 'package:kingsfam/models/says_model.dart';
import 'package:kingsfam/screens/says_extra/says_pop_up.dart';
import 'package:kingsfam/widgets/widgets.dart';

class SaysContainer extends StatefulWidget {
  final Says says;
  final BuildContext? context;
  final double? height;
  final int? taps;
  const SaysContainer(
      {Key? key,
      required this.says,
      required this.context,
      this.height,
      this.taps})
      : super(key: key);

  @override
  State<SaysContainer> createState() => _SaysContainerState();
}

class _SaysContainerState extends State<SaysContainer> {
  @override
  Widget build(BuildContext context) {
    int taped = widget.taps ?? 0 + 1;
    TextStyle title = TextStyle(
      fontSize: 18,
      color: Color(hc.hexcolorCode(widget.says.author!.colorPref)),
      fontWeight: FontWeight.bold,
    );
    TextStyle title2 = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );
    return GestureDetector(
      onTap: () {
        if (taped > 1) return;
        Navigator.of(context).pushNamed(SaysPopUp.routeName,
            arguments: SaysPopUpArgs(
                says: widget.says));
      },
      child: Card(
        margin: Margin.all(4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: Color(hc.hexcolorCode('#1b2136')),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileImage(
                      radius: 25,
                      pfpUrl:
                          "https://firebasestorage.googleapis.com/v0/b/kingsfam-9b1f8.appspot.com/o/images%2Fchurches%2FchurchAvatar_eb0c7061-a124-41b4-b948-60dcb0dffc49.jpg?alt=media&token=7e2fc437-9448-48bd-95bc-78e977fbcad8"),
                  SizedBox(width: 5),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 35),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // cm name as title
                          Row(
                            children: [
                              Text(
                                widget.says.author!.username,
                                style: title,
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                              ),
                              Text(
                                " ~ " + widget.says.cmName,
                                style: title2,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Text(
                            widget.says.contentTxt,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 7),
                          // dynamic code based on  extra content
                          footer(),
                          SizedBox(height: 1),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  // creation of the footer
  Widget footer() {
    return Row(
      children: [
        widget.says.contentImgUrl != null
            ?
            // show the img or vid thumbnail
            imgRow()
            : oneLineReactions()
      ],
    );
  }

  Widget oneLineReactions() {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.keyboard_double_arrow_up_outlined),
            Text(widget.says.likes.toString()),
            SizedBox(width: 7),
            Icon(Icons.mode_comment_outlined),
            SizedBox(width: 1),
            Text(widget.says.commentsCount.toString()),
            SizedBox(width: 7),
            Text(widget.says.date.timeAgo())
          ],
        ),
      ],
    );
  }

  Row imgRow() {
    return Row(
      children: [
        Container(
          height: 30,
          width: 40,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image:
                      CachedNetworkImageProvider(widget.says.contentImgUrl!))),
        ),
        SizedBox(width: 5),
        oneLineReactions()
      ],
    );
  }
}
