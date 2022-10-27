import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
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

  _getPreview() async {
    await Future.delayed(Duration(seconds: 1));
    _preview = await SimpleLinkPreview.getPreview(widget.link);
   
      String _url = _preview!.url;
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
    return _preview != null ? Container(
      height: 170,
      width: 190,
      decoration: _decoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _preview != null
            ? [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_title!, overflow: TextOverflow.ellipsis, maxLines: 2, style: TextStyle(fontStyle: FontStyle.italic)),
                ),
                SizedBox(
                  height: 4,
                ),
                _imageUrl != null ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image:
                                CachedNetworkImageProvider(_imageUrl))),
                  ),
                ) : SizedBox.shrink(),
              ]
            : [],
      ),
    ) : Container(height: 18, child: Text("Loading..."));
  }

  BoxDecoration _decoration() {
    return BoxDecoration(
        
        border: Border(left: BorderSide(color: Colors.amber, width: 3)),
        //borderRadius: BorderRadius.circular(7)
    );
  }
}
