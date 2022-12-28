import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kingsfam/screens/snack_time/cm_theme_list.dart';
import 'package:simple_link_preview/simple_link_preview.dart';

class LinkPreviewContainer extends StatefulWidget {
  final String link;
  const LinkPreviewContainer({Key? key, required this.link}) : super(key: key);

  @override
  State<LinkPreviewContainer> createState() => LinkPreviewContainerState();
}

class LinkPreviewContainerState extends State<LinkPreviewContainer> {
  LinkPreview? _preview;

  @override
  void initState() {
    _getPreview();
    super.initState();
  }

  _getPreview() {
    // await Future.delayed(Duration(seconds: 1));
    SimpleLinkPreview.getPreview(widget.link).then((link) {
      _preview = link;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    //log(_preview!.toString());
    String? _title;
    String? _imageUrl;
    if (_preview != null) {
      _title = _preview!.title != null ? _preview!.title : "";
      _imageUrl = _preview!.image != null ? _preview!.image : null;
    }
    return _preview != null
        ? Container(
            height: 200,
            width:  MediaQuery.of(context).size.width/ 1.5,
            decoration: BoxDecoration(
              color: Color.fromARGB(110, 255, 193, 7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _preview != null
                  ? [
                      Padding(
                        padding: const EdgeInsets.only(top:8.0, bottom:4.0, right:4.0, left:4.0,),
                        child: Text(_title!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: Theme.of(context).textTheme.caption!.copyWith(fontStyle: FontStyle.italic, color: Colors.blue)),
                      ),

                      _imageUrl != null
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 140,
                                width: MediaQuery.of(context).size.width/ 1.7,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0),
                                    image: DecorationImage( fit: BoxFit.cover,
                                        image: CachedNetworkImageProvider(
                                            _imageUrl))),
                              ),
                            )
                          : SizedBox.shrink(),
                    ]
                  : [],
            ),
          )
        : Container(
            height: 130,
            width: 200,
            child: Center(child: Text("Loading...")),
            decoration: BoxDecoration(
              color: Color.fromARGB(110, 255, 193, 7),
              borderRadius: BorderRadius.circular(4),
              
            ));
  }

  BoxDecoration _decoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(7),
      color: Color.fromARGB(22, 255, 193, 7),
      border: Border(left: BorderSide(color: Colors.amber, width: 3)),
      //borderRadius: BorderRadius.circular(7)
    );
  }
}
