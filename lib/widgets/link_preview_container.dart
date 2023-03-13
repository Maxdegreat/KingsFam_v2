import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
    String? _description;
    if (_preview != null) {
      _title = _preview!.title != null ? _preview!.title : "";
      _imageUrl = _preview!.image != null ? _preview!.image : null;
      _description =
          _preview!.description != null ? _preview!.description : null;
    }
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      child: _preview != null
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: Theme.of(context).colorScheme.secondary,
                //       border: Border(
                //     left: BorderSide(
                //       color: Theme.of(context).colorScheme.inversePrimary,
                //       width: 3.0,
                //     ),
                //  )
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_title != null) ...[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _title,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(fontSize: 15),
                          maxLines: 3,
                        ),
                      )
                    ],
                    if (_description != null && _description.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _description,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(fontSize: 15, color: Colors.blueAccent),
                          maxLines: 3,
                        ),
                      )
                    ],
                    if (_imageUrl != null) ...[
                      // height: MediaQuery.of(context).size.width > 400 ? 200 : MediaQuery.of(context).size.width / 5,
                      // width: MediaQuery.of(context).size.width > 400 ? 200 : MediaQuery.of(context).size.width / 5,
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.network(
                            _imageUrl,
                            fit: BoxFit
                                .contain, // or BoxFit.cover, BoxFit.fill, BoxFit.fitWidth, etc.
                            alignment: Alignment
                                .center, // or Alignment.topLeft, Alignment.bottomRight, etc.
                          ))
                    ]
                  ],
                ),
              ),
            )
          : SizedBox.shrink(),
    );
  }
}
